#!/bin/bash

function prt_usage {
  # print usage information
  cat <<EOF
Usage: $(basename $0) --auth USER:PASSWORD

Help maintaing torrent files with transmission-remote.

-n, --auth    Set the authorization string which will be passed to transmission-remote
-h, --help    Output this help and exit

EOF
}

function get_args {
  # Get all the arguments of the script
  while [[ $# > 0 ]]; do
    key="$1"
    shift

    case $key in
      -n|--auth)
        AUTH="$1"
        shift
        ;;
      -h|--help)
      prt_usage
      exit
        ;;
      *)
        # unknown option
        ;;
    esac
  done

  if [ -z $AUTH ]; then
    echo -e "ERROR: auth not set\n";
    prt_usage
    exit 1;
  fi
}

function get_torrent_names {
  # get list of torrents
  torrents=$(transmission-remote --auth=$AUTH -l)

  if [ "$?" -ne "0" ]; then
    echo "ERROR: cannot get list of torrents"
    exit 1
  fi

  # check which field contains Name
  field_id=$(echo "$torrents" | sed -n '1s/ \([A-Z]\)/\n\1/gp' | sed -n '/Name/=')

  # convert the transmission list output to CSV and cut the name field
  echo "$torrents" | sed -e 's/[ ]\{2,11\}/;/g' -e 's/^;//' | cut -d ';' -f "$field_id"
}

function get_additional_files {
  echo "== Files in public folder but not in torrent list ===="

  # get list of torrents
  list_torrents=$(get_torrent_names)
  if [ "$?" -ne "0" ]; then
    echo "$list_torrents"
    exit 1
  fi

  files_public=$(ls -1 /var/downloads/public)

  while read torrent; do
    list_temp=$(echo "$files_public" | grep -v -F "$torrent")
    files_public=$list_temp
  done <<<"$list_torrents"

  echo "$files_public"
}

get_args $@
get_additional_files
