# Dotfiles

This repository is designed to be checked out directly as `~/.config`. XDG-aware
applications use it in place; `tools/install` creates the few compatibility
links required by applications that still read files from `$HOME`.

## Install

Back up an existing config directory, clone the repository, and run the
installer:

```sh
cd "$HOME"
if [ -e .config ]; then
    mv .config ".config.backup.$(date +%Y%m%d-%H%M%S)"
fi
git clone --recurse-submodules git@github.com:mvondomaros/dotfiles.git .config
~/.config/tools/install
```

The installer is idempotent and never replaces an existing home-directory
file. Review any `skip:` messages and merge or back up those files manually.

The backup can contain useful machine-local application state. Copy back only
what is needed; do not copy credentials into the repository.

## Packages

On macOS, install Homebrew separately and apply the package manifest explicitly:

```sh
brew bundle --file="$HOME/.config/brew/brewfile"
```

On Linux, source the Bash configuration and run `bootstrap_cli_tools` after
installing `curl` and `jq` with the system package manager. Package installation
is deliberately not performed during shell startup.

## Update

Update the checkout and its pinned submodules separately from upgrading machine
packages:

```sh
git -C "$HOME/.config" pull --rebase
git -C "$HOME/.config" submodule update --init --recursive
```

`tools/update` upgrades installed Homebrew and Pixi packages. It can make broad
changes to the machine, so run it intentionally rather than from shell startup.

## Repository policy

Tracked files are portable, declarative configuration. The root ignore file is
an allowlist: newly created application directories are ignored until they are
explicitly selected for management. Generated completions, version markers,
application databases, and credentials inside managed directories are also
ignored. Neovim's `lazy-lock.json` is intentionally tracked when generated so
plugin versions are reproducible across machines.
