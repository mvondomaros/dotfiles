#!/usr/bin/env python3
"""Offline tests with disposable HOME, config, state, PATH, and release archives."""
import hashlib
import io
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tarfile
import tempfile
import unittest
import zipfile

REPO = Path(__file__).resolve().parents[1]
NVIM = shutil.which('nvim')
VIM = shutil.which('vim')
FISH = shutil.which('fish')

class DotfilesTests(unittest.TestCase):
    maxDiff = None
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='dotfiles test ')
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        self.home = self.root / 'home'
        self.home.mkdir()
        self.repo = self.root / 'checkout'
        self.repo.mkdir()
        for name in ['bash', 'fish', 'nvim', 'tools', 'dotfiles', 'git', 'atuin', 'eza', 'fzf', 'lazygit', 'pixi', 'kitty', 'ideavim', 'brew', 'vim-colors']:
            shutil.copytree(REPO / name, self.repo / name, ignore=shutil.ignore_patterns('local', '__pycache__'))
        for name in ['starship.toml', 'vimrc']:
            shutil.copy2(REPO / name, self.repo / name)
        self.bin = self.root / 'bin'
        self.bin.mkdir()
        self.env = dict(HOME=str(self.home), PATH=str(self.bin) + ':/usr/bin:/bin',
                        XDG_CONFIG_HOME=str(self.home / '.config'),
                        XDG_DATA_HOME=str(self.home / '.local/share'),
                        XDG_CACHE_HOME=str(self.home / '.cache'),
                        XDG_STATE_HOME=str(self.home / '.local/state'), TERM='xterm-256color')
        self.mock('uname', 'case "$1" in -m) echo x86_64 ;; *) echo Linux ;; esac')

    def mock(self, name, body):
        path = self.bin / name
        path.write_text('#!/bin/sh\n' + body + '\n')
        path.chmod(0o755)

    def run_command(self, args, code=0, extra=None):
        result = subprocess.run(args, env=dict(self.env, **(extra or {})), stdout=subprocess.PIPE,
                                stderr=subprocess.PIPE, universal_newlines=True, timeout=45)
        self.assertEqual(result.returncode, code, (args, result.stdout, result.stderr))
        return result

    def install(self, *args):
        return self.run_command([str(self.repo / 'tools/install-dotfiles')] + list(args))

    def bash(self, command, interactive=False):
        return self.run_command(['/bin/bash', '--noprofile', '--norc', '-ic' if interactive else '-c', command])

    def test_install_idempotence_and_private_selection(self):
        self.install('--host', 'marc3a')
        before = os.readlink(str(self.home / '.bashrc'))
        self.install('--host', 'marc3a')
        self.assertEqual(before, os.readlink(str(self.home / '.bashrc')))
        self.assertEqual((self.home / '.config/dotfiles/local/host').read_text(), 'marc3a\n')
        self.assertFalse((self.repo / 'dotfiles/local').exists())

    def test_existing_files_preserved_and_backup(self):
        original = self.home / '.bashrc'
        original.write_text('# site settings\n')
        self.install()
        self.assertEqual(original.read_text(), '# site settings\n')
        self.install('--backup')
        self.assertTrue(original.is_symlink())
        backups = list((self.home / '.local/state/dotfiles/backups').glob('*/.bashrc'))
        self.assertEqual(len(backups), 1)
        self.assertEqual(backups[0].read_text(), '# site settings\n')

    def test_layers_quiet_noninteractive_and_path(self):
        self.install('--host', 'marc3a')
        (self.repo / 'dotfiles/platforms/linux/env.sh').write_text('export LAYER=platform\n')
        (self.repo / 'dotfiles/hosts/marc3a/env.sh').write_text('export LAYER="$LAYER:host"\n')
        (self.home / '.config/dotfiles/local/env.sh').write_text('export LAYER="$LAYER:private"\n')
        (self.repo / 'dotfiles/hosts/marc3a/bash.sh').write_text('echo UNEXPECTED_INTERACTIVE\n')
        # Catch attempts to use network/install tools, including version probing.
        for tool in ['curl', 'git', 'pixi', 'atuin', 'starship']:
            self.mock(tool, 'echo UNEXPECTED_TOOL >&2; exit 9')
        (self.home / '.local/bin').mkdir(parents=True, exist_ok=True)
        before = set(self.home.rglob('*'))
        result = self.bash('source "$HOME/.bashrc"; source "$HOME/.bashrc"; printf "%s\\n%s\\n" "$LAYER" "$PATH"')
        self.assertEqual(result.stderr, '')
        lines = result.stdout.splitlines()
        self.assertEqual(lines[0], 'platform:host:private')
        self.assertEqual(lines[1].split(':').count(str(self.home / '.local/bin')), 1)
        self.assertNotIn(str(self.home / '.config/tools'), lines[1].split(':'))
        self.assertEqual(before, set(self.home.rglob('*')))

    def test_interactive_fallbacks_and_no_completion_generation(self):
        self.install()
        self.mock('pixi', 'echo UNEXPECTED_PIXI >&2; exit 9')
        result = self.bash('source "$HOME/.bashrc"; printf "EDITOR=%s\\n" "$EDITOR"; ! declare -F browse', True)
        self.assertIn('EDITOR=vim', result.stdout)
        self.assertNotIn('UNEXPECTED_PIXI', result.stderr)
        self.assertFalse((self.home / '.cache/dotfiles').exists())

    def test_reuse_without_download(self):
        for tool in ['pixi', 'lazygit', 'rg', 'fd', 'atuin', 'eza', 'nvim', 'starship', 'ruff', 'ty']:
            self.mock(tool, 'echo existing-version')
        self.mock('curl', 'echo UNEXPECTED_DOWNLOAD >&2; exit 9')
        result = self.run_command([str(self.repo / 'tools/install-tools')])
        self.assertEqual(result.stdout.count('reuse:'), 10)
        self.assertNotIn('UNEXPECTED_DOWNLOAD', result.stderr)
        self.assertFalse((self.home / '.local/share/dotfiles/tools').exists())

    def test_verified_install_failed_update_preserves_binary(self):
        archive = self.root / 'fixture.tar.gz'
        with tarfile.open(str(archive), 'w:gz') as out:
            content = b'#!/bin/sh\necho "test ripgrep"\n'
            item = tarfile.TarInfo('fixture/rg')
            item.size = len(content)
            item.mode = 0o755
            out.addfile(item, io.BytesIO(content))
        digest = hashlib.sha256(archive.read_bytes()).hexdigest()
        manifest = self.repo / 'tools/linux-releases.txt'
        manifest.write_text('rg x86_64 ' + digest + ' https://example.invalid/fixture.tar.gz\n')
        self.mock('curl', 'while [ "$#" -gt 0 ]; do if [ "$1" = -o ]; then shift; cp "$TEST_ARCHIVE" "$1"; exit; fi; shift; done; exit 1')
        # macOS has shasum; EL8 has sha256sum.
        extra = {'DOTFILES_DOWNLOAD_DIR': str(self.root)}
        shutil.copyfile(str(archive), str(self.root / 'rg-x86_64.tar.gz'))
        self.mock('curl', 'echo UNEXPECTED_DOWNLOAD >&2; exit 9')
        self.run_command([str(self.repo / 'tools/install-tools'), 'rg'], extra=extra)
        binary = self.home / '.local/bin/rg'
        self.assertTrue(binary.is_symlink())
        self.run_command([str(binary), '--version'])
        manifest.write_text('rg x86_64 ' + '0' * 64 + ' https://example.invalid/fixture.tar.gz\n')
        result = self.run_command([str(self.repo / 'tools/update-tools'), 'rg'], code=1, extra=extra)
        self.assertIn('Checksum mismatch', result.stderr)
        self.assertEqual(self.run_command([str(binary), '--version']).stdout.strip(), 'test ripgrep')
        self.assertFalse(list((self.home / '.local/share/dotfiles/tools').glob('.install-*')))

    def test_macos_provisioning_scope_and_reuse(self):
        self.mock('uname', 'echo Darwin')
        log = self.root / 'brew.log'
        self.mock('brew', 'printf "%s\\n" "$*" >> "$BREW_TEST_LOG"; test "$1" != install')
        extra = {'BREW_TEST_LOG': str(log)}
        self.run_command([str(self.repo / 'tools/install-tools')], extra=extra)
        self.assertIn('bundle --no-upgrade --file=', log.read_text())
        self.run_command([str(self.repo / 'tools/install-tools'), 'rg'], extra=extra)
        self.assertNotIn('install ripgrep', log.read_text())
        self.run_command([str(self.repo / 'tools/update-tools'), 'rg'], extra=extra)
        self.assertIn('upgrade ripgrep', log.read_text())
        self.assertNotIn('global', log.read_text())

    def test_editor_profile_is_explicit_and_scoped(self):
        result = self.run_command([str(self.repo / 'tools/install-tools'), '--editor', '--check'])
        for tool in ['shfmt', 'shellcheck', 'stylua']:
            self.assertIn(tool, result.stdout)
        for tool in ['pixi', 'nvim', 'bash-language-server', 'fish-lsp', 'texlab', 'tinymist', 'typst']:
            self.assertNotIn(tool, result.stdout)
        self.run_command([str(self.repo / 'tools/install-tools'), '--editor', 'rg'], code=2)
        self.mock('uname', 'echo Darwin')
        self.mock('brew', 'printf "%s\\n" "$*"')
        result = self.run_command([str(self.repo / 'tools/install-tools'), '--editor'])
        self.assertIn('bundle --no-upgrade --file=' + str(self.repo / 'brew/editor.Brewfile'), result.stdout)

    def test_verified_raw_zip_xz_editor_downloads(self):
        manifest = self.repo / 'tools/linux-releases.txt'
        manifest.write_text('')
        for tool, suffix in [('shfmt', ''), ('stylua', '.zip'), ('typst', '.tar.xz')]:
            archive = self.root / (tool + '-x86_64' + suffix)
            content = ('#!/bin/sh\necho "' + tool + ' 2.0.0"\n').encode()
            if suffix == '':
                archive.write_bytes(content)
            elif suffix == '.zip':
                with zipfile.ZipFile(str(archive), 'w') as out:
                    out.writestr(tool, content)
            else:
                with tarfile.open(str(archive), 'w:xz') as out:
                    item = tarfile.TarInfo('fixture/' + tool)
                    item.size = len(content)
                    out.addfile(item, io.BytesIO(content))
            digest = hashlib.sha256(archive.read_bytes()).hexdigest()
            with manifest.open('a') as out:
                out.write(tool + ' x86_64 ' + digest + ' https://example.invalid/releases/download/v2.0.0/' + tool + suffix + '\n')
        self.mock('curl', 'echo UNEXPECTED_DOWNLOAD >&2; exit 9')
        self.run_command([str(self.repo / 'tools/install-tools'), 'shfmt', 'stylua', 'typst'], extra={'DOTFILES_DOWNLOAD_DIR': str(self.root)})
        for tool in ['shfmt', 'stylua', 'typst']:
            result = self.run_command([str(self.home / '.local/bin' / tool), '--version'])
            self.assertIn(tool + ' 2.0.0', result.stdout)

    @unittest.skipUnless(sys.platform == 'darwin', 'Native macOS PATH check')
    def test_macos_bash_path_priority_and_repeat(self):
        prefix = next(p for p in ['/opt/homebrew', '/usr/local'] if Path(p, 'bin/brew').exists())
        hook = self.repo / 'dotfiles/platforms/macos/env.sh'
        result = self.bash('PATH="/usr/bin:/bin:' + prefix + '/bin"; source "' + str(hook) + '"; first=$PATH; source "' + str(hook) + '"; test "$PATH" = "$first"; printf "%s" "$PATH"')
        self.assertEqual(result.stdout, prefix + '/bin:/usr/bin:/bin')

    def test_private_interactive_overrides_shared_alias(self):
        self.install()
        local = self.home / '.config/dotfiles/local/bash.sh'
        local.write_text("alias ls='printf private'\n")
        result = self.bash('source "$HOME/.bashrc"; alias ls', True)
        self.assertIn("printf private", result.stdout)

    def release_fixture(self, tool, version='2.0.0'):
        archive = self.root / (tool + '-x86_64.tar.gz')
        with tarfile.open(str(archive), 'w:gz') as out:
            content = ('#!/bin/sh\necho "' + tool + ' ' + version + '"\n').encode()
            name = 'fixture/bin/nvim' if tool == 'nvim' else 'fixture/' + tool
            item = tarfile.TarInfo(name)
            item.mode = 0o755
            item.size = len(content)
            out.addfile(item, io.BytesIO(content))
            if tool == 'nvim':
                item = tarfile.TarInfo('fixture/share/nvim/runtime/sentinel')
                item.size = 1
                out.addfile(item, io.BytesIO(b'x'))
        digest = hashlib.sha256(archive.read_bytes()).hexdigest()
        manifest = self.repo / 'tools/linux-releases.txt'
        with manifest.open('a') as stream:
            stream.write(tool + ' x86_64 ' + digest + ' https://example.invalid/releases/download/v' + version + '/' + tool + '.tar.gz\n')
        return {'DOTFILES_DOWNLOAD_DIR': str(self.root)}

    def user_tool(self, tool, directory='.local/bin', version='1.0.0'):
        path = self.home / directory / tool
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text('#!/bin/sh\necho "' + tool + ' ' + version + '"\n')
        path.chmod(0o755)
        return path

    def test_bulk_adoption_preview_backups_aliases_and_repeat(self):
        tools = ['pixi', 'lazygit', 'rg', 'fd', 'atuin', 'eza', 'nvim', 'starship', 'ruff', 'ty']
        (self.repo / 'tools/linux-releases.txt').write_text('')
        originals = {}
        for tool in tools:
            extra = self.release_fixture(tool)
            originals[tool] = self.user_tool(tool, '.pixi/bin' if tool == 'pixi' else '.local/bin')
        self.mock('curl', 'echo UNEXPECTED_DOWNLOAD >&2; exit 9')
        before = set(self.home.rglob('*'))
        result = self.run_command([str(self.repo / 'tools/update-tools'), '--check', '--adopt-all'], extra=extra)
        self.assertEqual(set(self.home.rglob('*')), before)
        self.assertEqual(result.stdout.count('user'), 10)
        self.run_command([str(self.repo / 'tools/update-tools'), '--adopt-all'], extra=extra)
        for tool, original in originals.items():
            self.assertTrue(original.is_symlink())
            self.assertIn('2.0.0', self.run_command([str(original), '--version']).stdout)
        backups = list((self.home / '.local/state/dotfiles/tool-backups').glob('*/*/active'))
        self.assertEqual(len(backups), 10)
        self.assertTrue(all('1.0.0' in path.read_text() for path in backups))
        self.assertTrue((self.home / '.local/share/dotfiles/tools/nvim/share/nvim/runtime/sentinel').exists())
        # No archive/network access is necessary at an unchanged pin.
        for path in self.root.glob('*-x86_64.tar.gz'):
            path.unlink()
        repeated = self.run_command([str(self.repo / 'tools/update-tools'), '--adopt-all'])
        self.assertEqual(repeated.stdout.count('current:'), 10)
        self.assertEqual(len(list((self.home / '.local/state/dotfiles/tool-backups').glob('*/*/active'))), 10)

    def test_adopt_preserves_system_module_bridges_and_newer_versions(self):
        module = self.bin / 'rg'
        self.mock('rg', 'echo "module rg 1.0.0"')
        bridge = self.home / '.local/bin/rg'
        bridge.parent.mkdir(parents=True)
        bridge.symlink_to(module)
        self.env['PATH'] = str(bridge.parent) + ':' + self.env['PATH']
        self.mock('curl', 'echo UNEXPECTED_DOWNLOAD >&2; exit 9')
        self.run_command([str(self.repo / 'tools/update-tools'), '--adopt', 'rg'])
        self.assertEqual(os.readlink(str(bridge)), str(module))
        module.unlink()
        bridge.unlink()
        newer = self.user_tool('rg', version='1.0.0')
        module.symlink_to(newer)
        self.env['PATH'] = str(self.bin) + ':/usr/bin:/bin'
        preview = self.run_command([str(self.repo / 'tools/update-tools'), '--check', '--adopt', 'rg'])
        self.assertIn('protected', preview.stdout)
        self.run_command([str(self.repo / 'tools/update-tools'), '--adopt', 'rg'])
        self.assertTrue(module.is_symlink())
        self.assertFalse(newer.is_symlink())
        module.unlink()
        newer.write_text('#!/bin/sh\necho "rg 99.0.0"\n')
        result = self.run_command([str(self.repo / 'tools/update-tools'), '--adopt', 'rg'])
        self.assertIn('newer-than-pin', result.stdout)
        self.assertFalse(newer.is_symlink())
        self.assertFalse((self.home / '.local/state').exists())

    def test_failed_adoption_retains_original_and_rolls_back_publish(self):
        original = self.user_tool('rg')
        (self.repo / 'tools/linux-releases.txt').write_text('')
        extra = self.release_fixture('rg')
        # Force a failure after the verified release and original backup exist.
        self.mock('mv', 'case "$1" in -f) echo simulated-publish-failure >&2; exit 7 ;; esac; exec /bin/mv "$@"')
        self.run_command([str(self.repo / 'tools/update-tools'), '--adopt', 'rg'], code=1, extra=extra)
        self.assertFalse(original.is_symlink())
        self.assertIn('1.0.0', original.read_text())
        self.assertFalse((self.home / '.local/share/dotfiles/tools/rg').exists())
        self.assertFalse(list((self.home / '.local/share/dotfiles/tools').glob('.install-*')))

    def test_macos_check_does_not_upgrade_and_rejects_adoption(self):
        self.mock('uname', 'echo Darwin')
        log = self.root / 'brew.log'
        self.mock('brew', 'printf "%s\\n" "$*" >> "$BREW_TEST_LOG"')
        extra = {'BREW_TEST_LOG': str(log)}
        self.run_command([str(self.repo / 'tools/update-tools'), '--check'], extra=extra)
        self.assertIn('outdated --verbose', log.read_text())
        self.assertNotIn('upgrade', log.read_text())
        self.assertNotIn('update', log.read_text())
        self.run_command([str(self.repo / 'tools/update-tools'), '--adopt-all'], code=2, extra=extra)

    @unittest.skipUnless(NVIM, 'Neovim unavailable')
    def test_neovim_offline_basic_and_modern_fallback(self):
        self.install()
        self.mock('git', 'echo UNEXPECTED_NETWORK >&2; exit 9')
        for mode in ['basic', 'auto']:
            result = self.run_command([NVIM, '--headless', '-i', 'NONE',
                                       '+lua assert(vim.g.dotfiles_full == false)', '+qa'],
                                      extra={'DOTFILES_NVIM_MODE': mode})
            self.assertNotIn('Error', result.stderr)
            self.assertNotIn('UNEXPECTED_NETWORK', result.stderr)

    @unittest.skipUnless(VIM, 'Vim unavailable')
    def test_vim_standalone(self):
        self.install()
        self.run_command([VIM, '-Nu', str(self.home / '.vimrc'), '-n', '-es', '-i', 'NONE', '+qa!'])

    @unittest.skipUnless(FISH, 'Fish unavailable')
    def test_fish_layers_and_noninteractive_startup(self):
        self.install('--host', 'office')
        os.symlink(str(self.repo / 'fish'), str(self.home / '.config/fish'))
        (self.repo / 'dotfiles/platforms/linux/env.fish').write_text('set -gx LAYER platform\n')
        (self.repo / 'dotfiles/hosts/office/env.fish').write_text('set -gx LAYER "$LAYER:host"\n')
        (self.home / '.config/dotfiles/local/env.fish').write_text('set -gx LAYER "$LAYER:private"\n')
        for tool in ['curl', 'git', 'pixi', 'atuin', 'starship']:
            self.mock(tool, 'echo UNEXPECTED_TOOL >&2; exit 9')
        result = self.run_command([FISH, '-c', 'printf "%s\\n" "$LAYER"'])
        self.assertEqual(result.stdout.strip(), 'platform:host:private')
        self.assertEqual(result.stderr, '')

if __name__ == '__main__':
    unittest.main(verbosity=2)
