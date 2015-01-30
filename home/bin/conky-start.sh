#!/bin/bash

# check for pause parameter
while [[ $# > 1 ]]; do
  key="$1"
  shift

  case $key in
    -p|--pause)
      PAUSE="$1"
      shift
      ;;
  esac
done

if [ -z $PAUSE ]; then
  # default PAUSE value
  PAUSE=60
fi

# set CONKYDIR and export for later usage
CONKYDIR="$HOME/.conky"
export CONKYDIR

# launch all conkyrc# scripts
i=1
for rcfile in $(ls -1 $CONKYDIR/conkyrc*); do
  # conky -c ${rcfile} >>$CONKYDIR/conky-${i}.log 2>&1 &
  conky -p ${PAUSE} -c ${rcfile} &
  # store process number
  PROCESSES[$i]=$( echo $! )
  i=$((i+1))
done

# wait for the processes
wait ${PROCESSES[@]}
