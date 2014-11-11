#!/bin/sh

# launch all conkyrc# scripts
for i in $(ls -1 ~/.conky/conkyrc*); do
  echo "conky -p 120 -c ~/.conky/${i}"
done
