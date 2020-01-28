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
  history -a ${HISTFILE}.$$
  history -c
  history -r  # load common history file
  # load histories of other sessions
  for f in $(ls ${HISTFILE}.[0-9]* 2>/dev/null | grep -v "${HISTFILE}.$$\$"); do
    history -r $f
  done
  history -r "${HISTFILE}.$$"  # load current session history
}
if [[ "$PROMPT_COMMAND" != *update_history* ]]; then
  export PROMPT_COMMAND="update_history; $PROMPT_COMMAND"
fi

# merge session history into main history file on bash exit
merge_session_history () {
  if [[ -e ${HISTFILE}.$$ ]]; then
    cat ${HISTFILE}.$$ >> $HISTFILE
    rm ${HISTFILE}.$$
  fi
}
trap merge_session_history EXIT


# detect leftover files from crashed sessions and merge them back
merge_orphaned_history() {
  local active_shells=$(pgrep `ps -p $$ -o comm=`)
  local grep_pattern=$(for pid in $active_shells; do echo -n "-e \.${pid}\$ "; done)
  local orphaned_files=$(ls $HISTFILE.[0-9]* 2>/dev/null | grep -v $grep_pattern)

  if [[ -n "$orphaned_files" ]]; then
    echo Merging orphaned history files:
    for f in ${orphaned_files}; do
      echo "  $(basename $f)"
      cat ${f} >> $HISTFILE
      rm ${f}
    done
    echo "done."
  fi
} #merge_orphaned_history
merge_orphaned_history
