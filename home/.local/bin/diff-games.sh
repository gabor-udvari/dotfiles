#!/bin/bash

temp="$(mktemp -d)"

print_usage () {
  cat << EOF
Will print out a three columned CSV file. First column
for GOG games, second for Steam, third for both of them.

$0 -s <steam_user>

-s/--steamuser: define steam user
EOF
}

parse_args () {
  POSITIONAL=()
  while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
      -s|--steamuser)
        STEAMUSER="$2"
        shift # past argument
        shift # past value
        ;;
      -h|--help)
        print_usage
        exit
        ;;
      *)    # unknown option
        POSITIONAL+=("$1") # save it in an array for later
        shift # past argument
        ;;
      esac
  done
  set -- "${POSITIONAL[@]}" # restore positional parameters

  if [ -z "$STEAMUSER" ]; then
    echo "ERROR: steam user needs to be defined"
    print_usage
    exit 1
  fi
}

download_gog () {
  output_file="$temp/games-gog.txt"
  if command -v 'lgogdownloader' >/dev/null; then
    lgogdownloader --list-details >"$output_file" 2>/dev/null
    echo "$output_file"
  else
    echo 'ERROR: lgogd_fileownloader is required for downloading GOG game data'
    exit 1
  fi
}

parse_gog () {
  input="$1"
  sed -n 's/^title: \(.*\)$/\1/p' "$input"
}

download_steam () {
  steam_id="$1"
  output_file="$temp/games-steam.html"

  curl -s "https://steamcommunity.com/id/$steam_id/games/?tab=all" >"$output_file" 2>/dev/null
  echo "$output_file"
}

parse_steam () {
  input="$1"

  sed -n 's/"name/\n"name/gp' "$input" | sed -n 's/"name":"\([^"]*\).*$/\1/p'
}

make_diff () {
  c=1
  for i in "$1" "$2"; do
    echo "$i" | \
      sed -e 's/™//g' -e 's/®//g' \
      -e 's/\\u2122//g' -e 's/\\u00fc/u/g' \
      -e 's/n: \(Spear of Destiny\)/n 3D: \1/' \
      -e 's/STAR WARS/Star Wars/g' \
      -e 's/Star Wars[^:]/Star Wars: /' \
      -e 's/Battlefront II/Battlefront 2/' \
      -e 's/ - Jedi/: Jedi/' \
      | sort -n >"$temp/list-$c.txt"
    ((c++))
  done

  comm "$temp/list-1.txt" "$temp/list-2.txt" | tr '\t' ';'
}

cleanup () {
  rm -rf "$temp"
}

parse_args "$@"

games_gog="$(download_gog)"
list_gog="$(parse_gog "$games_gog")"

games_steam="$(download_steam "$STEAMUSER")"
list_steam="$(parse_steam "$games_steam")"

make_diff "$list_gog" "$list_steam"

cleanup
