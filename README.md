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
~/.config/tools/install-dotfiles --host marc3a --role server
```

If `~/.config` already exists, keep it and clone somewhere else, then run that
checkout's `tools/install-dotfiles`. The installer links the managed application
configurations into `$XDG_CONFIG_HOME` (default `~/.config`). It does not replace
existing files unless `--backup` is supplied. Review `skip:` messages. Backups
are stored under `$XDG_STATE_HOME/dotfiles/backups/`, default
`~/.local/state/dotfiles/backups/`. Existing site shell settings should be reviewed
and migrated rather than silently sourced from an old startup file.

Git uses a real `$XDG_CONFIG_HOME/git/` directory with only `config` linked, so its
relative include finds the installed private overrides even with an external
checkout. If an older installation linked the entire `git/` directory, rerun
`tools/install-dotfiles --backup` to preserve that link and migrate it.

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

Each home directory also selects a role with an ignored
`$XDG_CONFIG_HOME/dotfiles/local/role` file. Use the installer to set it:

```sh
~/.config/tools/install-dotfiles --role server
# For a workstation (also the default when no role file exists):
~/.config/tools/install-dotfiles --role workstation
```

| Role | Shared shell/editor/agent tools | Python tooling | Typst tooling |
| --- | --- | --- | --- |
| `server` | Available through the usual profiles | Excluded | Excluded |
| `workstation` | Available through the usual profiles | Ruff/ty and Python editing | Typst/Tinymist/preview |

The role controls both provisioning and Neovim integration, including plugins,
language servers, formatters, lint commands, parser selection, and health checks.
`--all` applies all profiles appropriate to that role. Existing installations
without a role file retain workstation behavior. `DOTFILES_ROLE=server` or
`DOTFILES_ROLE=workstation` overrides the file for a single session or command.
There is no central hostname inventory: an NFS-shared cluster home needs only
one role setting for all its nodes. The separate host selector below continues
to choose cluster-specific environment settings.

Role changes do not automatically uninstall existing programs. Only the selected
tools are installed/updated, and disabled editor integrations stay inactive even
if their executables are still on PATH. Project environments and system Python
are independent of these editor roles. Pixi remains available on servers as the
package manager used to provision the native Tree-sitter generator.

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
The `marc3a` host hook reads the site's `/etc/profile.d/proxy.sh` when no proxy
was inherited, so HTTPS tools also work in noninteractive SSH commands. Private
environment overrides still run afterward.
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

Ruff and ty come from the included `brew/python.Brewfile` on workstations;
the server role excludes that file. Linux CLI core likewise contains ten tools
on workstations and eight on servers.
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

No sudo, `jq`, Python environment, or compiler is needed for CLI core
installation on Linux. `curl`, `tar`, and a SHA-256
utility are needed for downloads. Linux x86_64 and aarch64 assets are listed;
x86_64 is exercised on the available clusters.
The optional editor profile also needs `unzip` for StyLua and xz-capable `tar`
for Typst. Tree-sitter's generator uses a verified conda-forge package in a
private Pixi home under the managed tool directory, with its own C runtime.
Pixi is installed from CLI core if needed. This supports the clusters' older
glibc without changing the user's Pixi globals or project environments.
Other editor tools use standalone releases with checksum and executable checks.
Neovim x86_64 is pinned to the
older-glibc 0.12.5 build from `neovim/neovim-releases`. That binary was previously tested on
marc3a's glibc 2.28, including parsers and terminal rendering.
The standard upstream build previously failed on that cluster. Linux aarch64
uses the standard 0.12.6 release; CI is configured to exercise it on a native ARM
runner. Existing usable versions need not match these snapshots.
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
only the selected Brewfile profile or explicitly selected packages. The private
Tree-sitter environment is replaced together with its managed generator;
user Pixi environments and unrelated Homebrew packages are not upgraded.

`--adopt-all` covers the selected CLI core (ten tools on workstations, eight on servers); it
is not a scan of everything installed in your account. `--adopt TOOL ...` selects
a subset. Adoption is Linux-only: eligible executables must be user-owned and
resolve inside `~/.local/bin`, `~/.pixi/bin`, or `~/.opt`. System/module paths and
symlinks to them are protected. Newer-than-pinned versions are retained rather
than downgraded. `--check` reports installed/pinned versions, ownership, and the
planned action without installing tools. On macOS it uses `brew outdated` and
preserves Homebrew's exit status (which may be nonzero when updates exist).
With `--editor --adopt-all`, the selected set is seven Linux editor tools on
workstations or four on servers;
`--agents --adopt-all` selects the two coding agents.

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

On workstations, the global core is Pixi (project environments/dependencies), Ruff (linting and
formatting), and ty (type checking and Python language features). macOS uses
Homebrew; Linux uses the same verified standalone-release installer as the other
CLI tools. No global Python environment, uv, pipx, or additional type checker is
installed by core. Existing projects that explicitly require another manager can
keep it as a host/project exception until migrated.

The server role excludes Ruff/ty and Python LSP, formatting, and linting. The
following Python workflow and validation commands apply to workstations.

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

Use `v` or `$EDITOR` for Neovim → Vim → vi selection. The full shared setup
requires Neovim 0.12+. Older versions and `DOTFILES_NVIM_MODE=basic` use the
standalone Vim configuration. Missing plugins leave a native editing setup;
opening the editor never downloads plugins, tools, parsers, or dictionaries.

The Vim fallback uses only the runtime shipped with Vim: syntax, filetype
indentation, netrw for directories, path completion, buffers, splits, and
quickfix. No plugin manager or extra Vim plugins are installed. `:FallbackHelp`
or `<Space>hk` shows its key reference. `/` and `n`/`N` search within a file;
`:vimgrep /pattern/j FILES` and `:copen` provide explicit multi-file search.
Insert-mode Ctrl+n/p completes words and Ctrl+x Ctrl+f completes filenames.
There are no project-wide scans, builds, formatters, or language servers in
the fallback. The local Ayu theme is optional, and persistent undo is enabled
when its state directory has been provisioned by `tools/install-dotfiles`.

Shared mnemonic keys use **subject + action** after Space:

| Key | Meaning | Vim fallback | Full Neovim |
| --- | --- | --- | --- |
| `ff` / `fo` | File find / open | `:find` / `:edit`, with Tab completion | Project file picker / `:edit` |
| `fe` / `fs` / `fn` | File explorer / save / new | netrw / write / new buffer | Explorer / write / new buffer |
| `bl` / `bb` | Buffer list / back | List and select / alternate buffer | Buffer picker / alternate buffer |
| `bn` / `bp` / `bd` | Buffer next / previous / delete | Native buffer commands | Native navigation / close buffer |
| `wh` / `wv` / `wc` | Window horizontal split / vertical split / close | Native window commands | Same |
| `hs` / `hk` | Help search / keys | Help-tag completion / key reference | Help picker / keybinding picker |
| `uw` / `us` | UI wrapping / spelling | Toggle for current window | Same |
| `qa` | Quit all | Quit all, confirming unsaved edits | Same |

The focused plugin set is Ayu, Snacks (files/search/explorer/terminals),
Which-key, Gitsigns, Conform, and modern Tree-sitter; workstations also use Typst Preview. Plugins are managed by
Lazy. Native Neovim supplies LSP, completion, snippets, commenting, diagnostics,
and buffer navigation. There is no second completion framework, editor package
manager, LaTeX integration, dashboard, or animation layer.

Provision tools, plugins, and parsers explicitly:

```sh
~/.config/tools/install-tools
~/.config/tools/install-tools --editor
~/.config/tools/install-tools --agents
~/.config/tools/setup-editor --parsers --spell
```

`--editor` installs shfmt, ShellCheck, StyLua, Tree-sitter CLI, Tinymist, Typst,
and websocat on Linux workstations. Servers select only shfmt, ShellCheck,
StyLua, and Tree-sitter CLI. macOS also installs the Bash and Fish language servers.
Workstation Python tools belong to CLI core. Node and Fish language servers
on Linux are optional existing site tools. No TeX distribution or PDF viewer
is installed. Both platforms use the same parsers and keybindings.

`--agents` installs Codex CLI and Claude Code: native Homebrew casks on macOS,
and verified release packages on Linux. Codex's helper executables and sandbox
resources are retained. The managed Linux Claude launcher disables its native
self-updater so `update-tools --agents` owns updates. Existing working agent
installations are reused; Linux adoption remains explicit with `--adopt` or
`--adopt-all`. Agent logins, credentials, settings, and approval controls remain
in the agents' native configuration locations.

Updates use the same profiles:

```sh
~/.config/tools/update-tools --editor --check
~/.config/tools/update-tools --editor
~/.config/tools/update-tools --agents --check
~/.config/tools/update-tools --agents
# After pulling a changed plugin lockfile:
~/.config/tools/setup-editor --parsers
```

Tree-sitter uses its current `main` API with a global generator (0.26.1+) and a C
compiler. Linux provisions the generator through an isolated Pixi environment;
macOS uses Homebrew's `tree-sitter-cli`. The shared parser set covers Bash, Fish, Lua, Python, JSON, Markdown,
regular expressions, TOML, YAML, and Typst. Servers omit Python and Typst, using
nine shared parsers instead of eleven. Setup preserves legacy parser directories in
`$XDG_STATE_HOME/dotfiles/backups/parsers-*` before compiling the shared set.
Additional grammars can be installed explicitly with `:TSInstall LANGUAGE`.
Missing grammars retain built-in syntax and indent folds.

`K`, `grn`, `grr`, `gra`, `gri`, `grt`, and `gO` use Neovim's native language
features; `gd` goes to a definition. Completion triggers automatically on server
trigger characters or manually with `<C-x><C-o>`. `<C-y>` accepts a candidate;
Tab/Shift-Tab move through an active native snippet. `[b` and `]b` switch buffers;
`gc` comments text. Ctrl+h/j/k/l moves between splits on all platforms.

Press Space and pause to discover grouped commands. Neovim adds these mnemonic
bindings to the common fallback keys above:

Document bindings apply to the workstation role.

| Key | Action |
| --- | --- |
| `<Space>st` | Search text in the project |
| `<Space>tt` | Terminal toggle in the project |
| `<Space>gs` / `<Space>gd` | Git status / diff |
| `<Space>cf` / `<Space>cl` | Format / lint current unsaved contents |
| `<Space>cd` / `<Space>cs` | Diagnostic details / document symbols |
| `<Space>db` | Build the current Typst file to PDF |
| `<Space>dv` / `<Space>df` / `<Space>ds` | Toggle preview / sync source to preview / stop preview |
| `<Space>du` | Show the running preview URL |
| `<Space>ap` | Agent picker: Codex or Claude |
| `<Space>hn` | History of notifications |

`:Agent [codex|claude]` opens a persistent terminal for that agent and project;
repeating it toggles the terminal. Agents start in the same project root used
by file search and the regular terminal. Codex and Claude use their existing
login and settings. Agent conversations are started by the user, not on editor
startup. Double Escape returns from a Snacks terminal to Normal mode.

The plugin set uses Lua/Vimscript, so Neovim's optional Node, Perl, Python, and
Ruby remote-plugin hosts are disabled. Python editing still uses native LSP
with ty and the project's interpreter; it needs no `pynvim` package. The complete
`:checkhealth` command also probes disabled Snacks features such as image/math
rendering; their optional dependencies are outside this setup.

Python uses ty for language features and Ruff for formatting/linting. Shells use
shfmt/ShellCheck or Fish's native tools. Typst uses Tinymist for language features
and formatting, Typst for explicit PDF builds, and Typst Preview with global
Tinymist/websocat for browser previews with source/preview cross-navigation.
Set `TYPST_MAIN` for a multi-file document's main file (absolute, or relative to
`TYPST_ROOT` when set, otherwise the detected project root). Set `TYPST_ROOT`
when imports need an explicit project root. Preview binaries are never downloaded by the plugin.
Local previews open in the default browser. Over SSH, start the preview and use
`<Space>du` or `:DocumentUrl` to see its URL. From a local terminal, forward that
port with `ssh -N -L PORT:127.0.0.1:PORT HOST`, then open the displayed URL in
your local browser. HTTP and WebSocket share that port. Keep the tunnel open
while previewing. The plugin uses an automatic port because its fixed-port
option is incompatible with current Tinymist. Remote sessions suppress browser
launches; `DOTFILES_PREVIEW_COMMAND` can override the browser command on either
platform. The editor and agents run on the remote machine.

Code and Typst format on save when a formatter is available; text and Markdown
preserve authored line breaks. Text, Markdown, Typst, and Git commits enable soft
wrapping and spelling. English is bundled; `setup-editor --spell` downloads a
checksum-verified German dictionary explicitly. `:checkhealth dotfiles` reports
which shared tools are available and which installer profile supplies them.

Missing eza leaves ordinary ls aliases, missing Atuin leaves Bash history, and
missing Starship leaves the shell prompt. Pixi completions are generated only
by `tools/setup-shell`, never by shell startup.

On macOS, the Bash and Fish `top` functions use `TERM=xterm-256color` for that
command when running in Kitty. Apple's privileged `top` ignores user terminfo
locations, so installing Kitty's definition in `~/.terminfo` does not fix its
interactive mode. Other commands retain `TERM=xterm-kitty`; no system files or
terminal settings need changing.

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

Codex CLI and Claude Code are optional native tools in the `--agents` profile; the CLI core profile does not install them. After
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

Machines running the starting revision (`b4dcc97`) can migrate in place. Close editor sessions first
so an old process does not load a mixture of plugin versions during the update.
Use the actual checkout path if it lives outside `~/.config`:

```sh
cd ~/.config
git status --short
# Resolve tracked/untracked changes before pulling; keep private overrides in dotfiles/local/.
git -c submodule.recurse=false pull --ff-only
```

Before provisioning, select the role. On a server use
`./tools/install-dotfiles --role server --backup`; on a workstation the default
is suitable, or set `--role workstation` explicitly. Then run:

```sh
./tools/update-dotfiles --no-pull --backup --all
```

The first pull bootstraps the updater, which was absent from the starting
revision. `--no-pull` applies that checkout immediately. `--backup` migrates an
old symlinked XDG `git/` directory into a real directory with a linked config;
it also preserves any other conflicting files before replacing them. Review
installer `skip:` messages when omitting `--backup`. Existing host selection
and `dotfiles/local/` files are retained; there is no need to repeat `--host`.

`--tools` updates CLI core and regenerates cached completions. `--editor` updates
Neovim and editor dependencies, restores the exact plugin commits, and compiles
the role's shared parsers. Server roles omit Python and Typst at both stages.
Old parser directories are preserved in state backups.
`--agents` updates the two optional coding CLIs; native login/configuration and
the separately applied agent themes remain as described above. Omit
`--editor`/`--agents` on machines where those features are not wanted. The removed
Vim submodule is no longer used or fetched; leftover submodule directories and
Git metadata can be reviewed and removed separately.

Linux tool ownership rules still apply. An older working Neovim supplied by
the site or installed outside this tool manager is preserved. Full editor
provisioning requires 0.12+; use a supported site module, or explicitly preview
and adopt an eligible user installation:

```sh
./tools/update-tools --check --adopt nvim
./tools/update-tools --adopt nvim
./tools/update-dotfiles --no-pull --editor
```

Site/system binaries are protected even with `--adopt`. Vim and older Neovim
remain usable as the basic fallback. `DOTFILES_NVIM_MODE=basic nvim` also opens
the fallback while repairing an incomplete full-editor update.

For subsequent updates, use an explicit command with the profiles wanted on
that machine:

```sh
~/.config/tools/update-dotfiles --check --all
~/.config/tools/update-dotfiles --all
# Configuration links only:
~/.config/tools/update-dotfiles
```

`--all` selects CLI core, editor, and agents together; `--backup` remains a
separate choice for replacing conflicting configuration entries with backups.
The selected role determines whether Python and Typst belong to those profiles.
The default updates Git and reapplies configuration links. Profiles are explicit
on each invocation; include `--editor` whenever refreshing a provisioned full
Neovim setup. Git uses the current branch's configured upstream and requires a
clean checkout with no local-only commits. Updates fast-forward without merging
or rebasing local work. Submodules are left alone. `--check` fetches refs and
lists incoming commits and planned steps; it leaves HEAD, configuration,
packages, and plugins unchanged. It is a workflow preview; use
`tools/update-tools --check` for individual tool versions.

After a successful pull the updater executes the newly checked-out script.
Failures stop subsequent steps and leave completed steps in place. Fix the
reported issue and rerun with `--no-pull` and the same profile flags. Private
configuration and per-tool backup policies remain in the underlying installers.
The updater runs only when invoked; shell and editor startup stay offline.

Verify changes locally with:

```sh
python3 ~/.config/tests/check_dotfiles.py
```

The tests use disposable home directories and offline fixtures to check
installation/backups, configuration precedence, quiet noninteractive startup,
PATH handling, tool reuse, checksum failure recovery, and editor fallbacks.
They also exercise local Git remotes, self-update previews, migration from the
original installer, profile selection, and refusal to overwrite local work.
Python is needed only for tests, not shell startup or package installation.
After provisioning the full editor, test a Neovim upgrade against its plugins,
installed parser binaries, filetypes, formatting, and file saving with:

```sh
cd ~/.config
nvim --headless -i NONE -c "lua dofile('tests/check_nvim.lua')"
# With editor tools and spelling provisioned:
nvim --headless -i NONE -c "lua dofile('tests/check_languages.lua')"
# Real Typst build/preview; agent launches are mocked:
nvim --headless -i NONE -c "lua dofile('tests/check_workflows.lua')"
# Server role: verify Python/Typst stay inactive even if the tools are installed:
DOTFILES_ROLE=server nvim --headless -i NONE -c "lua dofile('tests/check_server.lua')"
```

The editor check uses and removes its own temporary files.

GitHub Actions runs the offline suite and explicitly provisions the full editor
with parsers and Typst build/preview tools on macOS, Linux x86_64, and Linux aarch64. The Linux jobs download
the manifest's exact Neovim archives and verify their checksums before executing
them. The workflow uses a disposable home and fails if provisioning changes the
plugin lockfile. Its first hosted run occurs after the workflow is pushed.

### Version pins

Pins are snapshots for reproducible setup, not a requirement to downgrade every
machine to the same version. Linux reuses working site/system tools; Homebrew
formulae are unpinned. Keep immutable release URLs and SHA-256 checksums together
so offline archives can be verified without trusting a moving `latest` download.

| Pin | Purpose and update policy |
| --- | --- |
| `tools/linux-releases.txt` | Verified fallback downloads. Update ordinary tools to reviewed stable releases; test the executable and shell/editor integration. |
| Linux x86_64 Neovim 0.12.5 | Compatibility hold: the latest [older-glibc build](https://github.com/neovim/neovim-releases) was tested on marc3a's glibc 2.28. Lift this hold only after testing a replacement on the cluster. |
| `nvim/lazy-lock.json` | Keep exact plugin commits so all machines restore the same setup. Refresh deliberately with `:Lazy update`, then run the editor/language checks before sharing the new lockfile. |
| Tree-sitter `main` commit | Uses the supported Neovim 0.12 API. Update the pinned plugin and parser binaries together through explicit provisioning. |
| Linux Tree-sitter CLI package | Pins a conda-forge build compatible with glibc 2.17+. Pixi resolves its C runtime in a private environment; the upstream Linux binaries currently require glibc 2.39. |
| Vendored `bash-preexec` 0.7.0 | Keeps history hooks offline and supports Bash 3.2 through 5.3. Review the diff against the [exact upstream revision](https://github.com/rcaloras/bash-preexec/blob/d866eeefdb8dfce075cbd4e37dc73c4deb4b0bd2/bash-preexec.sh) when updating. |
| German spelling checksum | Validates the downloaded dictionary. Its upstream URL is mutable, so an upstream change must fail verification until the new contents/checksum are reviewed. |
| JetBrains submodule commit | `lazy-idea` supplies the optional JetBrains mappings. Keep its revision fixed for reproducible setup; initialize or update it only when using that integration. |
| CI action commits | Keep full commit SHAs for the action code executed by CI; the release comments identify which upstream tags to review for updates. |

The plugin lockfile is sufficient to choose versions; there is no additional
global stable-tag filter. This avoids trapping plugins on old release tags when
their maintained code lives on a branch. The supported full configuration uses
Neovim 0.12+; older editor versions use the basic fallback.

The root `.gitignore` is an allowlist because this checkout can also be the live
XDG directory. Unmanaged application data, private overrides, and generated
completions stay out of Git. `nvim/lazy-lock.json` pins the plugin setup.
The `lazy-idea` submodule is optional and is never cloned by the installer.
JetBrains integration requires explicitly initializing it; it is unnecessary
on clusters.
