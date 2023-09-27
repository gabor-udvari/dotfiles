#!/bin/bash

# As taken from:
# https://gist.github.com/gyakovlev/0e4141d4f310dc1788f9eeacfd14d4e6

# Synchronize history between bash sessions
#
# Make history from other terminals available to the current one. However,
# don't mix all histories together - make sure that *all* commands from the
# current session are on top of its history, so that pressing up arrow will
# give you most recent command from this session, not from any session.
#
# Since history is saved on each prompt, this additionally protects it from
# terminal crashes.

# keep unlimited shell history because it's very useful
export HISTFILESIZE=-1
export HISTSIZE=-1
shopt -s histappend   # don't overwrite history file after each session

# on every prompt, save new history to dedicated file and recreate full history
# by reading all files, always keeping history from current session on top.
update_history () {
  history -a "${HISTFILE}.$$"
  history -c
  history -r  # load common history file
  # load histories of other sessions
  for f in "$HISTFILE".[0-9]*; do
    case $f in
      *.$$) true;;
      *) history -r "$f";;
    esac
  done
  if [[ -f "${HISTFILE}.$$" ]]; then
    history -r "${HISTFILE}.$$" # load current session history
  fi
}
if [[ "$PROMPT_COMMAND" != *update_history* ]]; then
  export PROMPT_COMMAND="update_history; $PROMPT_COMMAND"
fi

# merge session history into main history file on bash exit
merge_session_history () {
  if [[ -e "${HISTFILE}.$$" ]]; then
    cat "${HISTFILE}.$$" >> "$HISTFILE"
    rm "${HISTFILE}.$$"
  fi
}
trap merge_session_history EXIT

# detect leftover files from crashed sessions and merge them back
merge_orphaned_history() {
  for f in "$HISTFILE".[0-9]*; do
    case $f in
      *.'[0-9]*') true;;
      *.$$) true;;
      *)
        local fpid
        fpid=$(echo "$f" | grep -o '[0-9]*$')
        if ! ps -p "$fpid" -o pid= >/dev/null && [ -f "$f" ]; then
          echo -n "Merging orphaned history file:"
          echo -n " $(basename "$f")"
          cat "$f" >> "$HISTFILE"
          rm "$f"
          echo " done."
        fi
        ;;
    esac
  done
}
merge_orphaned_history
