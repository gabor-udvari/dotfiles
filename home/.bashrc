# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
echo $- | grep -F i >/dev/null || return

# Terminal logging for interactive shells
#
# Check if not yet under script
if [ -z "$UNDER_SCRIPT" ]; then
  # set the logdir
  logdir="$XDG_DATA_HOME/terminal-logs"
  if [ ! -d "$logdir" ]; then
    mkdir "$logdir"
  fi
  # find the logs older than 30 days
  old_logs=($(find "$logdir" -type f -name "*.log" -mtime +30))
  if [ ${#old_logs[@]} -gt 0 ]; then
    echo -n "Compressing old logs..."
    for i in "${old_logs[@]}"; do
      # compress the logs older than 30 days
      gzip "$i"
    done
    echo " Done"
  fi
  # set the new logfile and start the interactive terminal with script
  logfile="$logdir/$(date +%F_%T).$$.log"
  export UNDER_SCRIPT="$logfile"
  if which script >/dev/null; then
    if script -f -q "$logfile"; then
      # exit the parent shell when script is finished
      exit
    else
      # there was a problem running script, reset the terminal
      reset
    fi
  fi
fi

#
# Start ssh-agent (if exists)
#
if [ -x /usr/bin/ssh-agent ]; then
  # Create .ssh if not exists
  if [ ! -d "$HOME/.ssh" ]; then
    mkdir "$HOME/.ssh"
  fi

  export SSH_ENV="$HOME/.ssh/environment"

  # Check if ssh-agent is already running
  # Taken from: https://stackoverflow.com/a/48509425
  /usr/bin/ssh-add -l &>/dev/null
  add_retval="$?"
  if [ ! -f "$SSH_ENV" ] || ! ps -p "$(sed -n 's/^SSH_AGENT_PID=\([0-9]\+\).*$/\1/p' "$SSH_ENV")" &>/dev/null || [ "$add_retval" -eq 2 ]; then
    echo -n "Initialising new SSH agent..."
    /usr/bin/ssh-agent > "$SSH_ENV"
    echo " Done"
    chmod 600 "$SSH_ENV"
  fi

  if [ -z "$SSH_AGENT_PID" ] || ! ps -p "$SSH_AGENT_PID" &>/dev/null; then
    source "$SSH_ENV" >/dev/null
  fi
fi

#
# Concat SSH config scripts if any
#
if [ -d "$HOME/.ssh/config.d" ] && [ "$(ls -A "$HOME/.ssh/config.d")" ]; then
  # concat .conf and .config files as well
  echo -e "# Do not edit this file manually!\n# It is automatically generated from the .ssh/config.d folder.\n" >"$HOME/.ssh/config"
  cat "$HOME/.ssh/config.d"/{*.conf,*.config} >>"$HOME/.ssh/config" 2>/dev/null
  chmod 600 "$HOME/.ssh/config"
fi

#
# Create screen directory, and configure environment variable
#
if [ ! -d "$HOME/.screen" ]; then
  mkdir "$HOME/.screen" && chmod 700 "$HOME/.screen"
fi
export SCREENDIR=$HOME/.screen

#
# EXPORTS

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
export HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
export HISTSIZE=10000
export HISTFILESIZE=20000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# source default ubuntu prompt
# source "$HOME/.bashrc.d/default_prompt.bash"
# setup customized prompt command
export PROMPT_COMMAND='PS1X=$(p="${PWD#${HOME}}"; [ "${PWD}" != "${p}" ] && printf "~";IFS=/; for q in ${p:1}; do printf "%s" "/${q:0:1}"; done; printf "%s" "${q:1}")'
export PS1='[\u@\[\e[0;34m\]\h\[\e[m\]:$PS1X]\$ '

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

#
# SOURCING

# source shell prompt generated by vim-airline
source "$HOME/.shell_prompt.sh"

# source homeshick
source "$HOME/.homesick/repos/homeshick/homeshick.sh"

# source all .bash scripts in .bashrc.d folder
if [ -d "$HOME/.bashrc.d" ]; then
  for f in "$HOME/.bashrc.d/"*.bash; do source "$f"; done
fi

# source sync-history
source "$HOME/.sync-history.sh"

# source Abevjava profile
[ -f "$HOME/.profabevjava" ] && source "$HOME/.profabevjava"

#
# COMPLETIONS

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  # Only source completions when POSIX compatibility is not set
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi

  source "$HOME/.homesick/repos/homeshick/completions/homeshick-completion.bash"
  source "$HOME/.homesick/repos/dotfiles/todo.txt_cli-2.10/todo_completion"
fi
