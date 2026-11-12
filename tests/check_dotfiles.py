#!/usr/bin/env python3
"""Offline tests with disposable HOME, config, state, PATH, and release archives."""
import hashlib
import gzip
import io
import json
import os
from pathlib import Path
import shlex
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
GIT = shutil.which('git')

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
        for name in ['starship.toml', 'vimrc', '.gitignore']:
            shutil.copy2(REPO / name, self.repo / name)
        self.bin = self.root / 'bin'
        self.bin.mkdir()
        self.env = dict(HOME=str(self.home), PATH=str(self.bin) + ':/usr/bin:/bin',
                        XDG_CONFIG_HOME=str(self.home / '.config'),
                        XDG_DATA_HOME=str(self.home / '.local/share'),
                        XDG_CACHE_HOME=str(self.home / '.cache'),
                        XDG_STATE_HOME=str(self.home / '.local/state'),
                        TMPDIR=str(self.root), TERM='xterm-256color')
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

    def updater_helpers(self, real_installer=False):
        self.update_log = self.root / 'update.log'
        self.env['DOTFILES_UPDATE_LOG'] = str(self.update_log)
        for name in ['update-tools', 'install-dotfiles', 'setup-shell', 'setup-editor']:
            if name == 'install-dotfiles' and real_installer:
                continue
            helper = self.repo / 'tools' / name
            helper.write_text('#!/bin/sh\nprintf "%s\\n" "' + name + ' $*" >> "$DOTFILES_UPDATE_LOG"\n')
            helper.chmod(0o755)
        self.mock('git', 'exec ' + shlex.quote(GIT) + ' "$@"')

    def updater_git_fixture(self):
        origin = self.root / 'upstream.git'
        self.run_command([GIT, 'init', '--bare', str(origin)])
        self.run_command([GIT, 'init', str(self.repo)])
        self.run_command([GIT, '-C', str(self.repo), 'checkout', '-b', 'main'])
        self.git_commit(self.repo, 'initial checkout')
        self.run_command([GIT, '-C', str(self.repo), 'remote', 'add', 'origin', str(origin)])
        self.run_command([GIT, '-C', str(self.repo), 'push', '-u', 'origin', 'main'])
        self.run_command([GIT, '-C', str(origin), 'symbolic-ref', 'HEAD', 'refs/heads/main'])
        return origin

    def git_commit(self, directory, message):
        self.run_command([GIT, '-C', str(directory), 'add', '.'])
        self.run_command([GIT, '-C', str(directory), '-c', 'user.name=Dotfiles Test',
                          '-c', 'user.email=dotfiles@example.invalid', 'commit', '-m', message])
        return self.run_command([GIT, '-C', str(directory), 'rev-parse', 'HEAD']).stdout.strip()

    def update_dotfiles(self, *args, code=0):
        return self.run_command([str(self.repo / 'tools/update-dotfiles')] + list(args), code=code)

    def bash(self, command, interactive=False):
        return self.run_command(['/bin/bash', '--noprofile', '--norc', '-ic' if interactive else '-c', command])

    @unittest.skipUnless(GIT, 'Git unavailable')
    def test_self_update_preview_reexec_and_old_git_link_migration(self):
        self.updater_helpers(real_installer=True)
        installer = self.repo / 'tools/install-dotfiles'
        current_installer = installer.read_text()
        original_installer = (REPO / 'tests/fixtures/install-dotfiles-b4dcc97').read_text()
        installer.write_text(original_installer)
        self.install('--host', 'marc3a')
        private = self.home / '.config/dotfiles/local/gitconfig'
        private.write_text('[dotfiles]\nprobe = preserved\n')
        git_dir = self.home / '.config/git'
        self.assertTrue(git_dir.is_symlink())
        origin = self.updater_git_fixture()
        original = self.run_command([GIT, '-C', str(self.repo), 'rev-parse', 'HEAD']).stdout.strip()
        release = self.root / 'release'
        self.run_command([GIT, 'clone', str(origin), str(release)])
        (release / 'tools/install-dotfiles').write_text(current_installer)
        updater = release / 'tools/update-dotfiles'
        updater.write_text(updater.read_text().replace('set -eu\n',
                           'set -eu\nprintf "new-updater\\n" >> "$DOTFILES_UPDATE_LOG"\n', 1))
        released = self.git_commit(release, 'migrate Git links and refresh updater')
        self.run_command([GIT, '-C', str(release), 'push'])
        profiles = ['--backup', '--all']
        result = self.update_dotfiles('--check', *profiles)
        self.assertIn('1 incoming commit', result.stdout)
        self.assertFalse(self.update_log.exists())
        self.assertTrue(git_dir.is_symlink())
        self.assertEqual(self.run_command([GIT, '-C', str(self.repo), 'rev-parse', 'HEAD']).stdout.strip(), original)
        self.update_dotfiles(*profiles)
        self.assertEqual(self.run_command([GIT, '-C', str(self.repo), 'rev-parse', 'HEAD']).stdout.strip(), released)
        self.assertEqual(self.update_log.read_text().splitlines(), [
            'new-updater', 'update-tools ', 'update-tools --editor', 'update-tools --agents',
            'setup-shell ', 'setup-editor --parsers --spell'])
        self.assertFalse(git_dir.is_symlink())
        self.assertTrue((git_dir / 'config').is_symlink())
        self.assertEqual(self.run_command([GIT, 'config', '--file', str(git_dir / 'config'),
                                           '--includes', '--get', 'dotfiles.probe']).stdout.strip(), 'preserved')
        self.assertEqual((self.home / '.config/dotfiles/local/host').read_text(), 'marc3a\n')
        self.assertEqual(len(list((self.home / '.local/state/dotfiles/backups').glob('*/.config/git'))), 1)

    @unittest.skipUnless(GIT, 'Git unavailable')
    def test_self_update_rejects_dirty_detached_and_untracked(self):
        self.updater_helpers()
        origin = self.updater_git_fixture()
        origin.rename(self.root / 'offline-origin')
        file = self.repo / 'vimrc'
        before = file.read_bytes()
        file.write_bytes(before + b'\n" local change\n')
        result = self.update_dotfiles(code=1)
        self.assertIn('Checkout has local changes', result.stderr)
        self.assertEqual(file.read_bytes(), before + b'\n" local change\n')
        self.run_command([GIT, '-C', str(self.repo), 'add', 'vimrc'])
        self.assertIn('Checkout has local changes', self.update_dotfiles(code=1).stderr)
        self.run_command([GIT, '-C', str(self.repo), 'reset', '--', 'vimrc'])
        file.write_bytes(before)
        unknown = self.repo / 'tools/untracked-file'
        unknown.write_text('preserve me\n')
        self.assertIn('Checkout has local changes', self.update_dotfiles(code=1).stderr)
        unknown.unlink()
        self.run_command([GIT, '-C', str(self.repo), 'checkout', '--detach'])
        self.assertIn('Detached HEAD', self.update_dotfiles(code=1).stderr)
        self.assertFalse(self.update_log.exists())

    @unittest.skipUnless(GIT, 'Git unavailable')
    def test_self_update_preserves_local_commits_and_divergence(self):
        self.updater_helpers()
        origin = self.updater_git_fixture()
        release = self.root / 'release'
        self.run_command([GIT, 'clone', str(origin), str(release)])
        (self.repo / 'vimrc').write_text('" local commit\n')
        local = self.git_commit(self.repo, 'local work')
        result = self.update_dotfiles(code=1)
        self.assertIn('1 local-only commits (0 incoming)', result.stderr)
        (release / 'vimrc').write_text('" upstream commit\n')
        self.git_commit(release, 'upstream work')
        self.run_command([GIT, '-C', str(release), 'push'])
        result = self.update_dotfiles(code=1)
        self.assertIn('1 local-only commits (1 incoming)', result.stderr)
        self.assertEqual(self.run_command([GIT, '-C', str(self.repo), 'rev-parse', 'HEAD']).stdout.strip(), local)
        self.assertFalse(self.update_log.exists())

    @unittest.skipUnless(GIT, 'Git unavailable')
    def test_self_update_requires_upstream_and_stops_on_fetch_failure(self):
        self.updater_helpers()
        origin = self.updater_git_fixture()
        head = self.run_command([GIT, '-C', str(self.repo), 'rev-parse', 'HEAD']).stdout.strip()
        self.run_command([GIT, '-C', str(self.repo), 'branch', '--unset-upstream'])
        self.assertIn('Configure an upstream', self.update_dotfiles(code=1).stderr)
        self.run_command([GIT, '-C', str(self.repo), 'branch', '--set-upstream-to=origin/main'])
        origin.rename(self.root / 'offline-origin')
        self.update_dotfiles(code=128)
        self.assertEqual(self.run_command([GIT, '-C', str(self.repo), 'rev-parse', 'HEAD']).stdout.strip(), head)
        self.assertFalse(self.update_log.exists())

    @unittest.skipUnless(GIT, 'Git unavailable')
    def test_self_update_catches_changes_created_during_fetch(self):
        self.updater_helpers()
        self.updater_git_fixture()
        self.env['DOTFILES_UPDATE_REPO'] = str(self.repo)
        self.mock('git', '''
case "$*" in *" fetch "*)
    ''' + shlex.quote(GIT) + ''' "$@" || exit
    printf '\\n" edited during fetch\\n' >> "$DOTFILES_UPDATE_REPO/vimrc"
    exit ;;
esac
exec ''' + shlex.quote(GIT) + ''' "$@"''')
        self.assertIn('Checkout has local changes', self.update_dotfiles(code=1).stderr)
        self.assertIn('edited during fetch', (self.repo / 'vimrc').read_text())
        self.assertFalse(self.update_log.exists())

    @unittest.skipUnless(GIT, 'Git unavailable')
    def test_self_update_profiles_are_explicit_and_failures_stop(self):
        self.updater_helpers()
        self.update_dotfiles('--no-pull', '--check', '--tools', '--editor', '--agents')
        self.assertFalse(self.update_log.exists())
        self.update_dotfiles('--no-pull')
        self.assertEqual(self.update_log.read_text(), 'install-dotfiles \n')
        self.update_log.unlink()
        self.update_dotfiles('--no-pull', '--editor', '--backup')
        self.assertEqual(self.update_log.read_text().splitlines(), [
            'update-tools nvim', 'update-tools --editor', 'install-dotfiles --backup',
            'setup-editor --parsers --spell'])
        self.update_log.unlink()
        self.update_dotfiles('--no-pull', '--all', '--backup')
        self.assertEqual(self.update_log.read_text().splitlines(), [
            'update-tools ', 'update-tools --editor', 'update-tools --agents',
            'install-dotfiles --backup', 'setup-shell ', 'setup-editor --parsers --spell'])
        self.update_log.unlink()
        helper = self.repo / 'tools/update-tools'
        helper.write_text(helper.read_text() + 'test "$*" != --editor || exit 9\n')
        self.update_dotfiles('--no-pull', '--tools', '--editor', '--agents', code=9)
        self.assertEqual(self.update_log.read_text().splitlines(), ['update-tools ', 'update-tools --editor'])
        self.update_dotfiles('--nonsense', code=2)

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

    @unittest.skipUnless(GIT, 'Git unavailable')
    def test_private_git_include_with_external_checkout(self):
        for config in [self.home / '.config', self.root / 'custom config']:
            with self.subTest(config=config):
                self.env['XDG_CONFIG_HOME'] = str(config)
                self.install()
                private = config / 'dotfiles/local/gitconfig'
                private.write_text('[dotfiles]\nprobe = private\n')
                result = self.run_command([GIT, 'config', '--file', str(config / 'git/config'),
                                           '--includes', '--get', 'dotfiles.probe'])
                self.assertEqual(result.stdout.strip(), 'private')

    @unittest.skipUnless(GIT, 'Git unavailable')
    def test_git_directory_symlink_migration_requires_backup(self):
        git_dir = self.home / '.config/git'
        git_dir.parent.mkdir(parents=True)
        git_dir.symlink_to(self.repo / 'git', target_is_directory=True)
        result = self.install()
        self.assertTrue(git_dir.is_symlink())
        self.assertIn('skip:', result.stderr)
        private = self.home / '.config/dotfiles/local/gitconfig'
        private.write_text('[dotfiles]\nprobe = migrated\n')
        self.install('--backup')
        self.assertFalse(git_dir.is_symlink())
        backups = list((self.home / '.local/state/dotfiles/backups').glob('*/.config/git'))
        self.assertEqual(len(backups), 1)
        self.assertEqual(os.readlink(backups[0]), str(self.repo / 'git'))
        result = self.run_command([GIT, 'config', '--file', str(git_dir / 'config'),
                                   '--includes', '--get', 'dotfiles.probe'])
        self.assertEqual(result.stdout.strip(), 'migrated')

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

    def test_marc3a_proxy_for_ssh_preserves_inherited_and_private_settings(self):
        self.install('--host', 'marc3a')
        proxy = self.root / 'site-proxy.sh'
        proxy.write_text('export http_proxy=http://site.invalid:3128\nexport https_proxy="$http_proxy"\n')
        hook = self.repo / 'dotfiles/hosts/marc3a/env.sh'
        hook.write_text(hook.read_text().replace('/etc/profile.d/proxy.sh', str(proxy)))
        command = 'source "$HOME/.bashrc"; printf "%s\\n%s\\n" "${http_proxy:-}" "${https_proxy:-}"'
        self.assertEqual(self.bash(command).stdout, 'http://site.invalid:3128\nhttp://site.invalid:3128\n')
        inherited = self.run_command(['/bin/bash', '--noprofile', '--norc', '-c', command],
                                     extra={'https_proxy': 'http://custom.invalid:8080'})
        self.assertEqual(inherited.stdout, '\nhttp://custom.invalid:8080\n')
        (self.home / '.config/dotfiles/local/env.sh').write_text('export https_proxy=http://private.invalid:8080\n')
        self.assertEqual(self.bash(command).stdout, 'http://site.invalid:3128\nhttp://private.invalid:8080\n')

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

    def test_release_snapshots_are_verified_complete_and_unique(self):
        entries = set()
        tools = {}
        for line in (self.repo / 'tools/linux-releases.txt').read_text().splitlines():
            if not line.strip() or line.startswith('#'):
                continue
            fields = line.split()
            self.assertEqual(len(fields), 4, line)
            tool, arch, digest, url = fields
            self.assertNotIn((tool, arch), entries)
            entries.add((tool, arch))
            self.assertIn(arch, ['x86_64', 'aarch64'])
            self.assertRegex(digest, r'^[0-9a-f]{64}$')
            if tool == 'claude':
                self.assertRegex(url, r'^https://downloads\.claude\.ai/claude-code-releases/\d+\.\d+\.\d+/linux-(x64|arm64)/claude$')
            elif tool == 'tree-sitter':
                self.assertRegex(url, r'^https://conda\.anaconda\.org/conda-forge/linux-(64|aarch64)/tree-sitter-cli-\d+\.\d+\.\d+-\w+\.conda$')
            else:
                self.assertRegex(url, r'^https://github\.com/[\w.-]+/[\w.-]+/releases/download/(rust-)?v?\d[^/]*/[^/]+$')
            tools.setdefault(tool, set()).add(arch)
        for tool in ['pixi', 'lazygit', 'rg', 'fd', 'atuin', 'eza', 'nvim', 'starship', 'ruff', 'ty']:
            self.assertIn(tool, tools)
        for tool, architectures in tools.items():
            self.assertEqual(architectures, {'x86_64', 'aarch64'}, tool)

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
        self.assertIn('upgrade --formula ripgrep', log.read_text())
        self.assertNotIn('global', log.read_text())

    def test_editor_profile_is_explicit_and_scoped(self):
        result = self.run_command([str(self.repo / 'tools/install-tools'), '--editor', '--check'])
        for tool in ['shfmt', 'shellcheck', 'stylua', 'tree-sitter', 'tinymist', 'typst', 'websocat']:
            self.assertIn(tool, result.stdout)
        for tool in ['pixi', 'nvim', 'bash-language-server', 'fish-lsp', 'texlab', 'codex', 'claude']:
            self.assertNotIn(tool, result.stdout)
        self.run_command([str(self.repo / 'tools/install-tools'), '--editor', 'rg'], code=2)
        self.mock('uname', 'echo Darwin')
        self.mock('brew', 'printf "%s\\n" "$*"')
        result = self.run_command([str(self.repo / 'tools/install-tools'), '--editor'])
        self.assertIn('bundle --no-upgrade --file=' + str(self.repo / 'brew/editor.Brewfile'), result.stdout)

    def test_agents_profile_scope_and_macos_casks(self):
        result = self.run_command([str(self.repo / 'tools/update-tools'), '--agents', '--check'])
        self.assertIn('codex', result.stdout)
        self.assertIn('claude', result.stdout)
        for tool in ['pixi', 'nvim', 'tinymist', 'typst']:
            self.assertNotIn(tool, result.stdout)
        self.run_command([str(self.repo / 'tools/install-tools'), '--editor', '--agents'], code=2)
        self.run_command([str(self.repo / 'tools/install-tools'), '--agents', 'codex'], code=2)
        self.mock('uname', 'echo Darwin')
        self.mock('brew', 'printf "%s\\n" "$*"')
        result = self.run_command([str(self.repo / 'tools/install-tools'), '--agents'])
        self.assertIn('/brew/agents.Brewfile', result.stdout)
        result = self.run_command([str(self.repo / 'tools/update-tools'), 'claude', 'codex'])
        self.assertIn('upgrade --cask claude-code', result.stdout)
        self.assertIn('upgrade --cask codex', result.stdout)

    def test_verified_gzip_parser_generator(self):
        content = b'#!/bin/sh\necho "tree-sitter 0.27.2"\n'
        archive = self.root / 'tree-sitter-x86_64.gz'
        archive.write_bytes(gzip.compress(content))
        digest = hashlib.sha256(archive.read_bytes()).hexdigest()
        (self.repo / 'tools/linux-releases.txt').write_text('tree-sitter x86_64 ' + digest + ' https://example.invalid/releases/download/v0.27.2/tree-sitter.gz\n')
        self.run_command([str(self.repo / 'tools/install-tools'), 'tree-sitter'], extra={'DOTFILES_DOWNLOAD_DIR': str(self.root)})
        self.assertIn('0.27.2', self.run_command([str(self.home / '.local/bin/tree-sitter'), '--version']).stdout)

    def test_private_parser_generator_install_update_and_rollback(self):
        archive = self.root / 'tree-sitter-x86_64.conda'
        manifest = self.repo / 'tools/linux-releases.txt'
        def pin(version):
            archive.write_text('#!/bin/sh\necho "tree-sitter ' + version + '"\n')
            digest = hashlib.sha256(archive.read_bytes()).hexdigest()
            manifest.write_text('tree-sitter x86_64 ' + digest +
                                ' https://conda.anaconda.org/conda-forge/linux-64/tree-sitter-cli-' + version + '-test_0.conda\n')
        self.mock('pixi', '''
printf '%s\\n%s\\n' "$PIXI_HOME" "$*" >> "$PIXI_TEST_LOG"
mkdir -p "$PIXI_HOME/bin"
test "${PIXI_TEST_FAIL:-0}" = 0 || exit 9
while [ "$#" -gt 0 ]; do
    if [ "$1" = --path ]; then
        shift
        cp "$1" "$PIXI_HOME/bin/tree-sitter" || exit
        chmod +x "$PIXI_HOME/bin/tree-sitter"
        exit
    fi
    shift
done
exit 8''')
        log = self.root / 'pixi.log'
        extra = {'DOTFILES_DOWNLOAD_DIR': str(self.root), 'PIXI_TEST_LOG': str(log)}
        store = self.home / '.local/share/dotfiles/tools'
        binary = self.home / '.local/bin/tree-sitter'
        pin('0.27.2')
        self.run_command([str(self.repo / 'tools/install-tools'), 'tree-sitter'], extra=extra)
        old_home = Path((store / 'tree-sitter/.pixi-home').read_text().strip())
        self.assertEqual(old_home.parent, store)
        self.assertFalse((self.home / '.pixi').exists())
        self.assertIn('--path ', log.read_text())
        self.assertIn('tree-sitter-cli-0.27.2-test_0.conda', log.read_text())
        self.assertIn('0.27.2', self.run_command([str(binary), '--version']).stdout)
        self.assertIn('0.27.2', self.run_command([str(self.repo / 'tools/update-tools'), '--check', 'tree-sitter']).stdout)

        pin('0.28.0')
        self.run_command([str(self.repo / 'tools/update-tools'), 'tree-sitter'], code=1,
                         extra=dict(extra, PIXI_TEST_FAIL='1'))
        self.assertTrue(old_home.is_dir())
        self.assertEqual(list(store.glob('.tree-sitter.*')), [old_home])
        self.assertIn('0.27.2', self.run_command([str(binary), '--version']).stdout)
        # Verification fails before Pixi sees the package or any launcher moves.
        prior_log = log.read_text()
        manifest.write_text(manifest.read_text().replace(hashlib.sha256(archive.read_bytes()).hexdigest(), '0' * 64))
        result = self.run_command([str(self.repo / 'tools/update-tools'), 'tree-sitter'], code=1, extra=extra)
        self.assertIn('Checksum mismatch', result.stderr)
        self.assertEqual(log.read_text(), prior_log)
        pin('0.28.0')
        self.run_command([str(self.repo / 'tools/update-tools'), 'tree-sitter'], extra=extra)
        self.assertFalse(old_home.exists())
        self.assertEqual(len(list(store.glob('.tree-sitter.*'))), 1)
        self.assertIn('0.28.0', self.run_command([str(binary), '--version']).stdout)

    def test_codex_package_retains_helpers_and_does_not_downgrade(self):
        archive = self.root / 'codex-x86_64.tar.gz'
        with tarfile.open(archive, 'w:gz') as out:
            for name in ['bin/codex', 'bin/codex-exec-server', 'codex-resources/bwrap']:
                content = b'#!/bin/sh\necho "codex 0.167.2"\n'
                item = tarfile.TarInfo(name)
                item.mode = 0o755
                item.size = len(content)
                out.addfile(item, io.BytesIO(content))
        digest = hashlib.sha256(archive.read_bytes()).hexdigest()
        (self.repo / 'tools/linux-releases.txt').write_text('codex x86_64 ' + digest + ' https://example.invalid/releases/download/rust-v0.167.2/codex-package.tar.gz\n')
        extra = {'DOTFILES_DOWNLOAD_DIR': str(self.root)}
        self.run_command([str(self.repo / 'tools/install-tools'), '--adopt', 'codex'], extra=extra)
        store = self.home / '.local/share/dotfiles/tools/codex'
        self.assertTrue((store / 'bin/codex-exec-server').is_file())
        self.assertTrue((store / 'codex-resources/bwrap').is_file())
        (store / 'bin/codex').write_text('#!/bin/sh\necho "codex 99.0.0"\n')
        (store / '.dotfiles-managed').write_text('previous pin')
        result = self.run_command([str(self.repo / 'tools/update-tools'), 'codex'], extra=extra)
        self.assertIn('newer-than-pin', result.stdout)

    def test_claude_launcher_keeps_updates_managed(self):
        binary = self.root / 'claude-x86_64'
        binary.write_text('#!/bin/sh\necho "claude 2.1.311 updater=${DISABLE_AUTOUPDATER:-unset}"\n')
        digest = hashlib.sha256(binary.read_bytes()).hexdigest()
        (self.repo / 'tools/linux-releases.txt').write_text('claude x86_64 ' + digest + ' https://downloads.claude.ai/claude-code-releases/2.1.311/linux-x64/claude\n')
        extra = {'DOTFILES_DOWNLOAD_DIR': str(self.root)}
        self.run_command([str(self.repo / 'tools/install-tools'), 'claude'], extra=extra)
        result = self.run_command([str(self.home / '.local/bin/claude'), '--version'])
        self.assertIn('updater=1', result.stdout)
        self.assertIn('current:', self.run_command([str(self.repo / 'tools/update-tools'), 'claude'], extra=extra).stdout)

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

    @unittest.skipUnless(NVIM and GIT, 'Neovim/Git unavailable')
    def test_editor_fetches_new_pin_and_reuses_it_offline(self):
        version = self.run_command([NVIM, '--headless', '-u', 'NONE', '-i', 'NONE',
                                    '+lua io.write(vim.fn.has("nvim-0.12"))', '+qa'])
        if version.stdout != '1':
            self.skipTest('Editor provisioning requires Neovim 0.12+')
        self.install()
        remote = self.root / 'lazy-origin'
        self.run_command([GIT, 'init', str(remote)])

        def commit(message):
            self.run_command([GIT, '-C', str(remote), '-c', 'user.name=Dotfiles Test',
                              '-c', 'user.email=dotfiles@example.invalid',
                              'commit', '--allow-empty', '-m', message])
            return self.run_command([GIT, '-C', str(remote), 'rev-parse', 'HEAD']).stdout.strip()

        original = commit('original pin')
        lazy_dir = self.home / '.local/share/nvim/lazy/lazy.nvim'
        self.run_command([GIT, 'clone', str(remote), str(lazy_dir)])
        pinned = commit('new pin')
        fixture = self.repo / 'nvim/lua/plugins/fixture.lua'
        fixture.write_text('return { "dotfiles-test/fixture-plugin", config = function() error("Do not run plugin config while restoring") end }\n')
        lock = self.repo / 'nvim/lazy-lock.json'
        lock.write_text(json.dumps({'lazy.nvim': {'commit': pinned}, 'fixture-plugin': {'commit': pinned}}))
        original_lock = lock.read_bytes()
        self.mock('nvim', 'exec ' + shlex.quote(NVIM) + ' "$@"')
        # Redirect only the missing fixture plugin to a local Git origin.
        self.env['DOTFILES_TEST_ORIGIN'] = str(remote)
        self.mock('git', 'case "$*" in *https://github.com/dotfiles-test/fixture-plugin.git*) exec ' +
                  shlex.quote(GIT) + ' clone --no-checkout "$DOTFILES_TEST_ORIGIN" "$5" ;; esac\nexec ' + shlex.quote(GIT) + ' "$@"')
        unavailable = self.root / 'unavailable-origin'
        remote.rename(unavailable)
        setup = [str(self.repo / 'tools/setup-editor')]
        self.run_command(setup, code=128)
        result = self.run_command([GIT, '-C', str(lazy_dir), 'rev-parse', 'HEAD'])
        self.assertEqual(result.stdout.strip(), original)
        unavailable.rename(remote)
        self.run_command(setup)
        result = self.run_command([GIT, '-C', str(lazy_dir), 'rev-parse', 'HEAD'])
        self.assertEqual(result.stdout.strip(), pinned)
        fixture_dir = lazy_dir.parent / 'fixture-plugin'
        result = self.run_command([GIT, '-C', str(fixture_dir), 'rev-parse', 'HEAD'])
        self.assertEqual(result.stdout.strip(), pinned)
        self.assertEqual(lock.read_bytes(), original_lock, 'Adding a plugin changed existing pins')
        remote.rename(unavailable)
        self.assertIn('reuse: pinned Neovim plugins', self.run_command(setup).stdout)

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
        project = self.root / 'project with spaces'
        project.mkdir()
        (project / 'fallback note.txt').write_text('Before edit\n')
        script = self.root / 'fallback.vim'
        script.write_text('''
execute 'cd ' . fnameescape($DOTFILES_VIM_TEST_DIR)
call feedkeys(" fffallback\\<Tab>\\<CR>", 'xt')
call assert_equal('fallback note.txt', expand('%:t'))
call setline(1, 'Saved through the fallback')
call feedkeys(' fs', 'xt')
call assert_equal(['Saved through the fallback'], readfile('fallback note.txt'))
call feedkeys(' wv', 'xt')
call assert_equal(2, winnr('$'))
call feedkeys(' wc', 'xt')
call assert_equal(1, winnr('$'))
call feedkeys(' fn', 'xt')
call assert_equal('', bufname('%'))
call feedkeys(' bb', 'xt')
call assert_equal('fallback note.txt', expand('%:t'))
call assert_match('Window', execute('FallbackHelp'))
call assert_equal(1, g:loaded_spellfile_plugin)
call assert_equal('', v:errmsg)
if !empty(v:errors)
  call writefile(v:errors, $DOTFILES_VIM_TEST_DIR . '/errors.txt')
  cquit 1
endif
qa!
''')
        extra = {'DOTFILES_VIM_TEST_DIR': str(project)}
        self.run_command([VIM, '-Nu', str(self.home / '.vimrc'), '-n', '-es', '-i', 'NONE', '-S', str(script)], extra=extra)
        self.assertFalse((project / 'errors.txt').exists())
        # An incomplete/offline checkout still starts with Vim's built-in theme.
        (self.repo / 'vim-colors/colors/ayu_light.vim').unlink()
        shutil.rmtree(self.home / '.local/state/vim/undo')
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
