# Dotfiles

My public dotfiles.

## New Setup

```bash
git clone --bare git@github.com:mvondomaros/dotfiles $HOME/.dotfiles
alias dotfiles="GIT_WORK_TREE=~ GIT_DIR=~/.dotfiles"
dotfiles git checkout -f
```

Reload your shell.

```bash
dotfiles setup
```
