#!/bin/sh

WAIT=120
# WAIT=0

# launch all conkyrc# scripts
i=0
for rcfile in $(ls -1 ~/.conky/conkyrc*); do
  conky -p $WAIT -c ${rcfile} &
  # store process number
  PROCESSES[$i]=$( echo $! )
  i=$((i+1))
done

# wait for the processes
wait ${PROCESSES[@]}
