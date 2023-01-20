# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# Configure XDG_DATA_HOME if not set
export XDG_DATA_HOME="${XDG_DATA_HOME:="$HOME/.local/share"}"
# Configure the default XDG_DATA_DIRS if not set
export XDG_DATA_DIRS="${XDG_DATA_DIRS:="/usr/local/share:/usr/share"}"
# Add the .local to the XDG_DATA_DIRS
export XDG_DATA_DIRS="$XDG_DATA_DIRS:$HOME/.local/share"

# Set timeformat to ISO 8601
export TIME_STYLE="long-iso"

# Install Ruby Gems to ~/gems
export GEM_HOME="$HOME/gems"

# PATH settings
export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/.composer/vendor/bin:$HOME/gems/bin:$HOME/lutris/bin:${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# EDITOR settings
export EDITOR='vim'

# For packaging
export DEBFULLNAME="Gabor Udvari"
export DEBEMAIL="gabor.udvari@gmail.com"

# if running bash
if [ -n "$BASH_VERSION" ]; then
  # include .bashrc if it exists
  if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
  fi
fi

# GUIX
if [ -e "$HOME/.config/guix/current" ]; then
  export GUIX_PROFILE="$HOME/.config/guix/current"
  export GUIX_LOCPATH="$HOME/.guix-profile/lib/locale"
  . "$GUIX_PROFILE/etc/profile"
fi

# Nix
# If not on NixOS, set the local archive to the native distro
if command -v nix >/dev/null && [ "$(sed -n 's/^NAME=\"\?\([a-zA-Z0-9\/\ ]*\)\"\?$/\1/p' /etc/os-release)" != "NixOS" ]; then
  export LOCALE_ARCHIVE="/usr/lib/locale/locale-archive"
fi
