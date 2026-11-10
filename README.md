# Dotfiles

Shared configuration for macOS workstations and Linux/HPC accounts. macOS uses
Homebrew, Kitty, and Fish; Linux uses Bash and existing site tools wherever
possible. Starship is the prompt. Neovim is preferred, with a standalone Vim
fallback. Shell startup never installs packages or downloads editor plugins.

## Install configuration

The normal checkout is `~/.config`. Clone **without** `--recurse-submodules`;
neither the shell nor the Vim fallback needs a submodule.

```sh
git clone https://github.com/mvondomaros/dotfiles.git ~/.config
~/.config/tools/install-dotfiles --host marc3a
```

If `~/.config` already exists, keep it and clone somewhere else, then run that
checkout's `tools/install-dotfiles`. The installer links the managed application
configurations into `$XDG_CONFIG_HOME` (default `~/.config`). It does not replace
existing files unless `--backup` is supplied. Review `skip:` messages. Backups
are stored under `$XDG_STATE_HOME/dotfiles/backups/`, default
`~/.local/state/dotfiles/backups/`. Existing site shell settings should be reviewed
and migrated rather than silently sourced from an old startup file.

The installer does not install packages, initialize submodules, change the login
shell, or modify the system profile. Run commands by their explicit paths: the
repository's `tools` directory is intentionally not added to PATH.

## Configuration layers

Each shell uses its native syntax, with this precedence:

1. Shared settings in `bash/` or `fish/` and application configuration files.
2. Platform hooks in `dotfiles/platforms/macos/` or `dotfiles/platforms/linux/`.
3. Tracked machine/cluster hooks in `dotfiles/hosts/<name>/`.
4. Private overrides in `dotfiles/local/`, which Git ignores.

Bash loads `env.sh` from each layer for every shell, and `bash.sh` only for
interactive shells. Fish uses `env.fish` and interactive `config.fish` hooks.
Keep environment hooks quiet and minimal: PATH entries and environment variables
only. Interactive hooks run after shared aliases/editor defaults, and before
prompt/history integrations, so private aliases and settings take precedence. To customize an application, use its
native configuration or select another config through its environment variable
in an environment hook; there is no generated configuration/merge framework.

`install-dotfiles --host NAME` writes a private selector to
`dotfiles/local/host`. Selection is explicit, not based on a compute node's
hostname: every node sharing a cluster home uses the same profile. Without a
selection, shared/platform settings still work. `DOTFILES_HOST` can override
selection for a shell session. Names contain only letters, digits, `_`, and `-`.

Examples of private files:

```text
dotfiles/local/env.sh       # Bash environment (also used by SSH/Slurm)
dotfiles/local/bash.sh      # Interactive Bash customizations
dotfiles/local/env.fish     # Fish environment
dotfiles/local/config.fish  # Interactive Fish customizations
dotfiles/local/gitconfig    # Git includes this after shared settings
dotfiles/local/vimrc        # Vim and basic Neovim customizations
```

The old `~/.bashrc.local` is no longer sourced. Migrate its contents deliberately.
On Linux, the interactive platform hook makes the site's module command available
when an initialization file is present; it does not purge or load modules.
Scientific environments belong in a project session or job script, for example:

```sh
#!/bin/bash
#SBATCH --job-name=example
# Source the site's module initialization here if the scheduler does not do it.
module load gnu12 openmpi4 gromacs/2025.4
# Run the job explicitly; dotfiles do not activate this environment for you.
```

Noninteractive shells load no prompt, history hooks, keybindings, completions, or
interactive overrides, and do not create cache directories. `/etc/profile` and
other site/scheduler policies remain the site's responsibility.

## Install CLI tools

```sh
~/.config/tools/install-tools
```

On macOS, install [Homebrew](https://brew.sh) first. The command applies
`brew/cli.Brewfile`: Pixi, Ruff, ty, lazygit, ripgrep, rsync, fd, Atuin, eza, Neovim, Starship,
Git, Fish, fzf, Kitty, and terminal fonts. Existing packages are not upgraded by
default. Kitty launches Fish; changing the account's login shell is unnecessary.
`brew/workstation.Brewfile` holds optional desktop/scientific applications; the
legacy `brew/brewfile` combines CLI, editor, and workstation dependencies when a
full workstation is wanted.
Vim and alternative browsers are not installed by these manifests. The small
Vim configuration remains available for the OS-provided fallback editor.
Tailscale is an optional desktop cask in the workstation manifest, never a core
or cluster dependency. Keep a single Tailscale distribution on a desktop: an
existing App Store installation should not be supplemented with the cask.

On Linux, the installer:

- Reuses working executables from the site/system or existing local installs.
- Uses `fdfind` as `fd` when available.
- Downloads missing tools from official, pinned GitHub releases in
  `tools/linux-releases.txt`, verifies SHA-256, and checks that they run.
- Keeps standalone binaries under `~/.local/share/dotfiles/tools/`, linked from
  `~/.local/bin/`. Neovim also retains its required runtime files.
- Deletes temporary archives and retains one installed version per managed tool.
- Reports download/compatibility failures, continues with other tools, and exits
  nonzero if any tool could not be installed. Existing unmanaged files are kept.

For a cluster without outbound HTTPS, transfer archives named
`<command>-<architecture><release-suffix>` to a temporary directory on that cluster and
run `DOTFILES_DOWNLOAD_DIR=/path/to/archives tools/install-tools`. The same pinned
checksums and executable checks apply. Remove the supplied archives afterward;
the installer does not maintain a download cache.

No sudo, `jq`, Python environment, Conda environment, compiler, or additional
package manager is needed for Linux installation. `curl`, `tar`, and a SHA-256
utility are needed for downloads. Linux x86_64 and aarch64 assets are listed;
x86_64 is exercised on the available clusters.
The optional editor profile also needs `unzip` for StyLua. Explicitly requested
Typst releases need xz-capable `tar`. Raw executables, gzip/xz tarballs, and ZIP releases use the same
checksum and executable checks.
Neovim x86_64 is pinned to the
older-glibc 0.12.5 build from `neovim/neovim-releases`, tested on marc3a's glibc
2.28 with the full configuration, all 33 existing parsers, and terminal rendering.
The standard upstream build previously failed on that cluster. The untested
Linux aarch64 pin remains at 0.11.5. Existing usable versions need not match pins.
Update pins/checksums deliberately rather than downloading a moving `latest` URL.

Local tool directories are appended to the site's PATH rather than replacing
its toolchain. No global library paths are added. An older runnable Neovim is
kept and uses the basic editor configuration if the full setup is unsupported.
Linux uses rsync from the OS or site modules; dotfiles do not build a separate
rsync toolchain on clusters.

Explicit updates are scoped to this tool set:

```sh
~/.config/tools/update-tools --check
~/.config/tools/update-tools
# Linux: preview or adopt every eligible user-installed tool:
~/.config/tools/update-tools --check --adopt-all
~/.config/tools/update-tools --adopt-all
# Or adopt/install/update a particular tool:
~/.config/tools/update-tools --adopt pixi
~/.config/tools/install-tools nvim
~/.config/tools/update-tools rg fd
```

On Linux, updates replace only installations managed by this installer. Existing
system tools and other local installations are reused. On macOS, updates apply
only the CLI Brewfile or the explicitly selected formulae. Pixi global/project
environments and unrelated Homebrew packages are not upgraded.

`--adopt-all` covers only the ten CLI tools listed in the Linux manifest; it
is not a scan of everything installed in your account. `--adopt TOOL ...` selects
a subset. Adoption is Linux-only: eligible executables must be user-owned and
resolve inside `~/.local/bin`, `~/.pixi/bin`, or `~/.opt`. System/module paths and
symlinks to them are protected. Newer-than-pinned versions are retained rather
than downgraded. `--check` reports installed/pinned versions, ownership, and the
planned action without installing tools. On macOS it uses `brew outdated` and
preserves Homebrew's exit status (which may be nonzero when updates exist).
With `--editor --adopt-all`, the selected set is the three Linux editor tools instead.

Adoption first downloads, verifies, and runs the replacement, then backs up the
original launcher entries under
`$XDG_STATE_HOME/dotfiles/tool-backups/<run>/<tool>/` and installs managed links.
The old command location is redirected too, so existing PATH ordering and scripts
using `~/.pixi/bin/pixi` continue to work. A failed replacement restores original
entries. `active.path` and optional `bin.path` record where their corresponding
`active`/`bin` backup entries belong; restore them with `mv` to those paths if
needed. Original installation trees, environments, and application databases are
not deleted. Review backups before removing them yourself.

Managed downloads are skipped when both the pinned URL and checksum match the
installed record. Updating pins/checksums remains an explicit repository change.

## Python toolchain

The global core is Pixi (project environments/dependencies), Ruff (linting and
formatting), and ty (type checking and Python language features). macOS uses
Homebrew; Linux uses the same verified standalone-release installer as the other
CLI tools. No global Python environment, uv, pipx, or additional type checker is
installed by core. Existing projects that explicitly require another manager can
keep it as a host/project exception until migrated.

Neovim starts ty when available and uses Ruff through Conform for formatting.
There is one semantic Python language server and one formatting provider; Ruff
linting is available with `ruff check` or Neovim's `:Lint`. No editor-specific package manager
installs a second copy of these tools. The ty client disables recursive client
file watches to avoid exhausting file handles on large environments/shared homes.

Python interpreters, scientific libraries, pytest, Jupyter, and project-specific
pinned tools belong in project environments. The editor detects an existing
`.pixi/envs/default` without activating it, and ty discovers ordinary `.venv`
environments. Explicitly activated environments take precedence; for a named
Pixi environment, use `pixi run -e NAME nvim`. There is no environment activation
or package installation during shell/editor startup.

Check the real language server, project import resolution, type diagnostics,
hover, lint, and format-on-save using the existing Python installation:

```sh
python3 ~/.config/tests/check_python.py
```

The check creates temporary isolated Python environments without pip or package
downloads and removes them afterward.

## Editors and shell integrations

Use `v` or `$EDITOR` for Neovim → Vim → vi selection. `vim` and `vi` remain usable
as explicit fallback commands. The Vim configuration needs no plugins/submodules.
Missing eza leaves ordinary ls aliases; missing Atuin leaves Bash history;
missing Starship leaves the shell prompt. Git, grep, and find remain available
when their optional interfaces/replacements are absent; incompatible command
arguments are not translated through aliases.

Neovim starts with a built-in configuration when its plugins have not been
provisioned. Neovim older than 0.11 uses the standalone Vim configuration.
Install the pinned full setup explicitly, after configuration installation:

```sh
~/.config/tools/setup-editor
# Optionally compile a small set of Tree-sitter parsers (requires a compiler):
~/.config/tools/setup-editor --parsers --spell
```

Already provisioned plugins at their pinned commits are reused without a fetch.
The optional parser set is Bash, Fish, Lua, Python, Markdown, TOML, and YAML.
On macOS it also includes BibTeX and Typst. LaTeX's parser is added on macOS only
when an existing `tree-sitter` generator is available; built-in LaTeX syntax
remains the fallback. More
parsers can be installed explicitly with `:TSInstall`. No parsers are installed
on file open, and plugin update checks are disabled. Use
`DOTFILES_NVIM_MODE=basic nvim` to force the basic configuration.
Global executables supply formatting; inspect them with `:ConformInfo`.

Provision editor tools separately from cluster shell tools:

```sh
~/.config/tools/install-tools --editor
~/.config/tools/update-tools --editor --check
~/.config/tools/update-tools --editor
```

On macOS this applies `brew/editor.Brewfile`: Texlab, Tinymist, Typst, ShellCheck,
shfmt, StyLua, and the Bash/Fish language servers. Linux installs only shfmt,
ShellCheck, and StyLua; it does not add Node, a Python environment, Fish, or
LaTeX/Typst tooling. Writing is a workstation workflow. Existing Bash/Fish
language servers are used when available. A binary
that cannot run against the site's glibc is skipped with a nonzero installer
status; other selected tools are still attempted. For a Linux workstation,
`install-tools texlab tinymist typst` explicitly requests writing tools. Texlab
5.26.0 needs a newer glibc than marc3a's 2.28; no compatibility libraries are installed.

Neovim uses native completion and one server per language: ty, Texlab, Tinymist,
and optionally bash-language-server/fish-lsp. LaTeX builds and PDF previews stay
external. Tinymist exports no PDFs; its integrated formatter needs no separate
Typst formatter. Texlab can reuse existing ChkTeX/latexindent without installing
them or a second TeX toolchain.

`<leader>cf` formats the buffer/selection. Python, Bash, Fish, Lua, and Typst
format on save when a formatter is available. LaTeX/BibTeX and prose format only
on demand, preserving authored line breaks on save. Missing formatters leave
editing/saving usable. Shell scripts use shfmt instead of Beautysh.

`:Lint` or `<leader>cl` checks unsaved Python, Bash/sh, or Fish buffer contents
using Ruff, ShellCheck, or Fish's native syntax checker. Findings open quickfix;
there is no second Python LSP or lint plugin. Native LSP keys include `K`
(hover), `grn` (rename), `grr` (references), `gra` (code action), and `<C-x><C-o>`
(completion); `<C-y>` accepts completion.

Text, Markdown, LaTeX, and Typst enable soft wrapping and spelling. English is
bundled with Neovim. `setup-editor --spell` explicitly downloads Vim's official
German dictionary with a pinned SHA-256; existing dictionaries are reused.
Without a German dictionary, English remains active until setup is run. No
dictionaries are downloaded while opening a document. Parserless buffers retain
indent folds rather than receiving an unusable Tree-sitter fold expression.

Pixi completion generation is also explicit:

```sh
~/.config/tools/setup-shell
```

This refreshes cached Bash/Fish completions, preserving each previous file if
generation fails. The shells only read those caches. Atuin's existing sync
configuration is retained; credentials/history live outside this repository.

## Colors

Ayu Light is the shared default. Kitty, Fish, Starship, Lazygit, Atuin, Eza, and
fzf use the palette of the pinned `neovim-ayu` light theme: background `#F8F9FA`,
foreground `#5C6166`, selection `#D3E1F5`. Native application files hold the colors;
there is no theme generator or startup dependency. The standalone Vim/basic
Neovim theme uses the same RGB values, with approximations in 256-color terminals.

Fish applies the tracked theme to session globals on every interactive startup,
so stale universal colors cannot freeze an old theme. Private interactive hooks
still run afterward. `FZF_DEFAULT_OPTS_FILE` points to `fzf/config`; explicit
user options and private environment overrides remain available. On clusters,
the terminal palette comes from the workstation's terminal emulator over SSH.

Reload Kitty with Ctrl+Shift+F5 and open a new shell to pick up all colors.
Restart TUIs/editors after updating their configuration.

Codex CLI and Claude Code are optional workstation casks in
`brew/workstation.Brewfile`; cluster provisioning does not install them. After
installing them, apply the tracked agent themes explicitly:

```sh
python3 ~/.config/tools/setup-assistants
```

This workstation setup needs Python 3.11+ to validate TOML. It installs the custom
Ayu Light theme into `$CODEX_HOME/themes/` (default `~/.codex/themes/`) and
`~/.claude/themes/`, and changes only Codex's `tui.theme` and Claude's `theme`
preferences. Existing configuration files are preserved and backed up under
`~/.local/state/dotfiles/backups/assistants-*/`; credentials, hooks, permissions,
models, and project trust settings are not imported into this repository.
`CLAUDE_CONFIG_DIR` is respected when set. Running the command again reuses
unchanged files. Codex's custom theme controls syntax highlighting; Kitty supplies
its terminal background. See the [Codex theme documentation](https://learn.chatgpt.com/docs/cli-customization)
and [Claude Code theme documentation](https://code.claude.com/docs/en/terminal-config#match-the-color-theme).

## Maintenance and verification

```sh
git -C ~/.config pull --rebase
python3 ~/.config/tests/check_dotfiles.py
```

The tests use disposable home directories and offline fixtures to check
installation/backups, configuration precedence, quiet noninteractive startup,
PATH handling, tool reuse, checksum failure recovery, and editor fallbacks.
Python is needed only for tests, not shell startup or package installation.
After provisioning the full editor, test a Neovim upgrade against its plugins,
installed parser binaries, filetypes, formatting, and file saving with:

```sh
cd ~/.config
nvim --headless -i NONE -c "lua dofile('tests/check_nvim.lua')"
# With editor tools and spelling provisioned:
nvim --headless -i NONE -c "lua dofile('tests/check_languages.lua')"
```

The editor check uses and removes its own temporary files.

The root `.gitignore` is an allowlist because this checkout can also be the live
XDG directory. Unmanaged application data, private overrides, and generated
completions stay out of Git. `nvim/lazy-lock.json` pins the plugin setup.
The historical `vim` and `lazy-idea` submodules are optional and are never cloned
by the installer. JetBrains integration requires explicitly initializing
`lazy-idea`; it is unnecessary on clusters.
