#!/bin/bash

# Description:	start every conkyrc file in the selected conky directory
# Author:	Gabor Udvari (gabor.udvari@gmail.com)
# URL:		https://github.com/gabor-udvari/dotfiles

prtusage () {
  # print out usage of the script
  cat <<EOF
Usage: $(basename $0) [-p SECONDS]
   or: $(basename $0) [--pause SECONDS]

Start every conkyrc file in the selected conky director

    -p, --pause		set the pause in seconds before conky is displayed
			(default is 30 seconds)
    -h, --help		Output this help and exit
EOF
}

getargs () {
  # Get all the arguments of the script
  # check for pause parameter
  while [[ $# > 0 ]]; do
    key="$1"
    shift

    case $key in
      -p|--pause)
        # set pause
        PAUSE="$1"
        shift
        ;;
      -h|--help)
        # print help
        prtusage
        exit
        ;;
      *)
        # unknown option
        echo "Error: unknown argument detected."
        # print help
        prtusage
        exit 1
        ;;
    esac
  done

  if [ -z $PAUSE ]; then
    # default PAUSE value
    PAUSE=30
  fi

  # set CONKYDIR and export for later usage
  CONKYDIR="$HOME/.conky"
  export CONKYDIR
}

function launchconky () {
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
}

getargs $@
launchconky
