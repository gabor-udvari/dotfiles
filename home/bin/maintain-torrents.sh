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

function get_torrent_ids {
  # get the ids of the torrents
  torrent_ids=$(transmission-remote --auth "$AUTH" -l | grep Done | awk '{print $1}')

  echo "$torrent_ids"
}

function get_torrent_files {
  get_torrent_ids | while read t; do
    # What this sed does:
    # 1. Get both info and files output for each torrent
    # 2. Hold the "Location:" part
    # 3. Print out the "Location:" part before every filename
    # 4. Replace every 2nd newline with "||" so we can later cut it
    transmission-remote --auth "$AUTH" -t "$t" -i -f | sed -n -e '/^ *Location: /h;x;s/^ *Location: //;x' -e '/^.*[0-9]:.*[kMG]B.*$/{x;p;x;s/^.*[kMG]B *\(.*\)$/\1/p}' | sed -e 'N;s/\n/||/g'
  done
}

function get_torrent_directories {
  # The output has || separating location and files inside the torrent
  get_torrent_files | sed -n 's#^\(.*||[^/]*\)/.*$#\1#p' | sort -n | uniq
}

function get_additional_files {
  echo "== Files on the filesystem but not in the torrent list ===="

  # The output has || separating location and files inside the torrent
  torrents="$(get_torrent_directories)"

  torrent_locations="$(echo "$torrents" | sed -n 's/^\(.*\)||.*$/\1/p' | sort -n | uniq)"

  # Make temporary files
  file_torrents="$(mktemp)"
  file_filesystem="$(mktemp)"
  file_diff="$(mktemp)"

  # Loop through every location, and get all the files into a list
  echo "$torrent_locations" | while read l; do
    # Find the directories 1 folder deep
    find "$l" -mindepth 1 -maxdepth 1 -type d | sort -n >>"$file_filesystem"
  done

  sort -n "$file_filesystem" | uniq >"$file_diff"
  mv "$file_diff" "$file_filesystem"

  # Replace || back to /, and squeeze any //
  echo "$torrents" | grep -F "$l" | sed 's/||/\//' | tr -s '/' | sort -n >"$file_torrents"

  diff "$file_torrents" "$file_filesystem" | sed -n 's#^> \(/.*\)$#\1#p'
}

function cleanup {
  rm "$file_torrents" "$file_filesystem"
}

get_args $@
get_additional_files
cleanup
