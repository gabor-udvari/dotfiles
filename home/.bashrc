# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Terminal logging for interactive shells
if [[ $- =~ i ]]; then
  # check if not yet under script
  if [ -z "$UNDER_SCRIPT" ]; then
    # set the logdir
    logdir=$HOME/terminal-logs
    if [ ! -d $logdir ]; then
      mkdir $logdir
    fi
    # compress the logs older than 30 days
    find $logdir -type f -name "*.log" -mtime +30 -exec gzip {} \;
    # set the new logfile and start the interactive terminal with scrip
    logfile=$logdir/$(date +%F_%T).$$.log
    export UNDER_SCRIPT=$logfile
    script -f -q $logfile
    # exit the parent shell when script is finished
    exit
  fi
fi

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=20000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

#
# ssh-agent (not on cygwin)
#
if ! uname | grep CYGWIN >/dev/null; then
  SSH_ENV="$HOME/.ssh/environment"

  function start_agent {
       echo "Initialising new SSH agent..."
       /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
       echo succeeded
       chmod 600 "${SSH_ENV}"
       . "${SSH_ENV}" > /dev/null
       /usr/bin/ssh-add;
  }

  # Source SSH settings, if applicable
  if [ -f "${SSH_ENV}" ]; then
       . "${SSH_ENV}" > /dev/null
       # ps ${SSH_AGENT_PID} doesn't work under cywgin
       ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
           start_agent;
       }
  else
       start_agent;
  fi
fi 

# PATH settings
PATH=$PATH:$HOME/bin
export PATH

# EDITOR settings
EDITOR=vim

# source default ubuntu prompt
# source "$HOME/.bashrc.d/default_prompt.bash"
# setup customized prompt command
export PROMPT_COMMAND='PS1X=$(p="${PWD#${HOME}}"; [ "${PWD}" != "${p}" ] && printf "~";IFS=/; for q in ${p:1}; do printf /${q:0:1}; done; printf "${q:1}")'
export PS1='[\u@\[\e[0;34m\]\h\[\e[m\]:$PS1X]\$ '

#
# SOURCING

# source shell prompt generated by vim-airline
source "$HOME/.shell_prompt.sh"

# source homeshick
source "$HOME/.homesick/repos/homeshick/homeshick.sh"

# source all .bash scripts in .bashrc.d folder
if [ -d $HOME/.bashrc.d ]; then
  for f in $HOME/.bashrc.d/*.bash; do source $f; done
fi

# completions
source "$HOME/.homesick/repos/homeshick/completions/homeshick-completion.bash"
source "$HOME/.homesick/repos/dotfiles/todo.txt_cli-2.10/todo_completion"
