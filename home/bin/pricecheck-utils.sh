#!/bin/bash

# Description: some functions to check prices from different Hungarian
#       IT webshops
# Usage: define an actual checks array as the given example and then
#       call the functions like this:
#
#       get_all_prices
#       if [ "$(check_if_cheaper)" == "true" ]; then
#         send_email 'Product name' 'me@example.com'
#       fi
#       cleanup
#
# Author: gabor.udvari@gmail.com

log="$HOME/example-log.txt"
tmp=$(mktemp)

# Takes the price from 2 html tags eg.: ">52 900 Ft</"
regex_tags='s#^.*>\([0-9]*\).\([0-9]\{3\}\) *F*t*</.*$#\1\2#p'
# Takes the price from a json attribute, eg.: "price": "64900"
regex_json='s/^.*"price": *"*\([0-9]*\)"*.*$/\1/p'

# Multidimensional array as seen in https://stackoverflow.com/a/16487733
declare -A checks
checks_len=3
# Array structure: 0=portal name, 1=URL to check, 2=filter, 3=regex type, 4=price
# Aqua
checks[0,0]='Aqua'
checks[0,1]='https://www.aqua.hu/'
checks[0,2]='Kedvezményes ár (bruttó)'
checks[0,3]='tags'
# MySoft
checks[1,0]='MySoft'
checks[1,1]='http://www.mysoft.hu/'
checks[1,2]='MainContent_LabelNagyBrutto'
checks[1,3]='tags'
# Emag
checks[2,0]='Emag'
checks[2,1]='https://www.emag.hu/'
checks[2,2]='"price": "'
checks[2,3]='json'
# Ipon
checks[3,0]='Ipon'
checks[3,1]='https://ipon.hu/'
checks[3,2]="'"'products'"'"':'
checks[3,3]='json'
# PCX
checks[2,0]='PCX'
checks[2,1]='https://www.pcx.hu/'
checks[2,2]='itemprop="price"'
checks[2,3]='tags'

function get_price_from_url {
  price=0
  url="${checks[$1,1]}"
  if [ ! -z "$url" ]; then
    wget "$url" -O "$tmp"
    regex="regex_${checks[$1,3]}"
    price=$(grep -F "${checks[$1,2]}" "$tmp" | sed -n "${!regex}")
  fi
  echo "$price"
}

function get_all_prices {
  header='Date'
  row="$(date '+%Y-%m-%d %H:%M:%S')"
  for ((i=0; i<$checks_len; i++)); do
    header=$(echo -n "$header;${checks[$i,0]}")
    checks[$i,4]="$(get_price_from_url $i)"
    row=$(echo -n "$row;${checks[$i,4]}")
  done

  # echo $header
  echo "$row" >>"$log"
}

function cleanup {
  rm "$tmp"
}

function check_if_cheaper {
  reduction='false'
  for ((i=1; i<=$checks_len; i++)); do
    old_price=$(tail -2 "$log" | head -1 | cut -d';' -f$((i+1)) )
    new_price=$(tail -1 "$log" | head -1 | cut -d';' -f$((i+1)) )
    if [ "$new_price" -lt "$old_price" ]; then
      reduction='true'
    fi
  done
  echo "$reduction"
}

# Arguments: 1=Product name, 2=recipient
function send_email {
  body='Olcsóbb lett a(z) '"$1"'!\n\n'
  for ((i=0; i<$checks_len; i++)); do
    body=$(echo -ne "$body\n${checks[$i,0]}: ${checks[$i,4]}\n${checks[$i,1]}\n")
  done
  echo -e "$body" | mail -s "Olcsóbb a(z) $1" $2
}
