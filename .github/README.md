# Dotfiles

My public dotfiles.

## New Setup

```bash
git clone --bare git@github.com:mvondomaros/dotfiles $HOME/.dotfiles
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
dotfiles checkout
if [[ $? == 0 ]]; then
  echo "Checked out dotfiles.";
else
  echo "Backing up pre-existing dot files.";
  dotfiles checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .dotfiles.bak/{}
fi
```
