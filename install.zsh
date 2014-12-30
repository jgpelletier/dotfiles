#!/usr/bin/env zsh

# Installation of ~bigeasy/dotfiles. At first I thought I'd use a Makefile, but
# I might want to administer a server where build tools are not installed.
#
# Oh, no wait. I can just install make, without other build tools.
#
# My approach is to treat my environment as a combination of my editor and shell
# of choice plus a preferred scripting language. My dotfiles do not attempt to
# make one UNIX like every other.
#
# My preferred scripting language has been bash, because it's everywhere, but
# I'm drifting over to Node.js, so that a Node.js is going to be something I'll
# want to install on every machine I work with.
#
# Looks as though I've decided to make a `curl | bash` installer.

function abend () {
  echo "fatal: $1" 1>&2
  exit 1
}

git_version=$(git --version 2>/dev/null)
if [ $? -ne 0 ]; then
  abend "git is not installed"
fi
git_version="${git_version#git version }"
if ! { [[  "$git_version" == 1.[8-9].* ]] || [[ "$git_version" == 1.7.1[0-9].* ]]; }; then
  abend "git is at version $git_version but must be at least 1.7.10"
fi

DOTFILES="$HOME/.dotfiles"

if [ $(basename $SHELL) != "zsh" ]; then
  abend "change your shell to zsh before running install"
fi

if ! [ -e "$HOME/.oh-my-zsh" ]; then
  curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh
fi

# We set this in our `~/.dotfiles/zprofile.zsh`.
sed -i -e 's/^ZSH_THEME/# ZSH_THEME/' ~/.zshrc
sed -i -e 's/^plugins/# plugins/' ~/.zshrc

# The generated `.zshrc` writes the path that was set at the time of generation.
sed -i -e 's/^PATH/# PATH/' ~/.zshrc

if ! [ -e "$HOME/.dotfiles" ]; then
  git clone git://github.com/jgpelletier/dotfiles.git "$DOTFILES"
fi

rsync -a "$DOTFILES/home/unix/" "$HOME/"

[ -e "$DOTFILES/home/$(uname)" ] && rsync -a "$DOTFILES/home/$(uname)/" "$HOME/"
