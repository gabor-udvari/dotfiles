#!/bin/sh

#WAIT=120
WAIT=0

# launch all conkyrc# scripts
for i in $(ls -1 ~/.conky/conkyrc*); do
  conky -p $WAIT -c ${i}
done
