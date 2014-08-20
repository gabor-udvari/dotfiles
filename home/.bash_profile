# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

shopt -s checkwinsize

# User specific environment and startup programs

PATH=$PATH:$HOME/bin:/opt/ibm/db2/V9.7/bin/
export PATH

export PROMPT_COMMAND='PS1X=$(p="${PWD#${HOME}}"; [ "${PWD}" != "${p}" ] && printf "~";IFS=/; for q in ${p:1}; do printf /${q:0:1}; done; printf "${q:1}")'

# export PROMPT_COMMAND='PS1X=$(perl -pl0 -e "s|^${HOME}|~|;s|([^/])[^/]*/|$""1/|g" <<<${PWD})'

# export PS1="[\u@\h:$PS1X]\$ "

export PS1='[\u@\[\e[0;34m\]\h\[\e[m\]:$PS1X]\$ '

