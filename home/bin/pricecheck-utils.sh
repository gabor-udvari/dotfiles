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
tmp="$(mktemp)"

# Takes the price from 2 html tags eg.: ">52 900 Ft</"
# shellcheck disable=SC2034
regex_tags='s#^.*>\([0-9]*\).\([0-9]\{3\}\) *F*t*</.*$#\1\2#p'
# Takes the price from a json attribute, eg.: "price": "64900"
# shellcheck disable=SC2034
regex_json='s/^.*"price": *"*\([0-9]*\)"*.*$/\1/p'

# Multidimensional array as seen in https://stackoverflow.com/a/16487733
declare -A checks
checks_len=8
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
checks[4,0]='PCX'
checks[4,1]='https://www.pcx.hu/'
checks[4,2]='itemprop="price"'
checks[4,3]='tags'
# Computer Imperium
checks[5,0]='Computer Imperium'
checks[5,1]='http://computerimperium.hu/'
checks[5,2]='table table tr:nth-child(4) td:nth-child(5) text{}'
checks[5,3]='html'
# AVO Comp
checks[6,0]='AVO Comp'
checks[6,1]='http://www.avocomp.hu/'
checks[6,2]='.product__inside__price text{}'
checks[6,3]='html'
# Sov24
checks[7,0]='Sov24'
checks[7,1]='https://sov24.hu/'
checks[7,2]='.our_price_display span text{}'
checks[7,3]='html'
# Laptop Bázis
checks[8,0]='Laptop Bázis'
checks[8,1]='https://laptopbazis.hu/lenovo-thinkpad-t440p-intel-core-i7-4600m-nvidia-geforce-gt-730m'
checks[8,2]='#price_akcio_brutto_LB170328 text{}'
checks[8,3]='html'
# PC Boss
checks[9,0]='PC Boss'
checks[9,1]='https://pcboss.hu/lenovo-thinkpad-t440p-hasznalt-laptop-892'
checks[9,2]='.middle div:nth-child(2) .price_row .price text{}'
checks[9,3]='html'
# NDR
checks[10,0]='NDR'
checks[10,1]='https://nrd.hu/lenovo_thinkpad_t440p_8gb_128ssd_hdp.php'
checks[10,2]='.tnev span text{}'
checks[10,3]='html'

function get_price_from_url {
  price=0
  url="${checks[$1,1]}"
  if [ -n "$url" ]; then
    wget "$url" -O "$tmp"
    if [ "${checks[$1,3]}" == "html" ]; then
      price="$(pup "${checks[$1,2]}" < "$tmp"| chomp_price)"
    elif [ "${checks[$1,3]}" == "null" ]; then
      price=0
    else
      regex="regex_${checks[$1,3]}"
      price=$(grep -F "${checks[$1,2]}" "$tmp" | sed -n "${!regex}")
    fi
  fi
  echo "$price"
}

function get_all_prices {
  header='Date'
  row="$(date '+%Y-%m-%d %H:%M:%S')"
  for ((i=0; i<checks_len; i++)); do
    header=$(echo -n "$header;${checks[$i,0]}")
    checks[$i,4]="$(get_price_from_url $i)"
    row=$(echo -n "$row;${checks[$i,4]}")
  done

  # echo $header
  echo "$row" >>"$log"
}

# shellcheck disable=SC2120
function chomp_price {
  # Support both parameter and pipe
  if [ "${#}" == 0 ]; then
    input="$(< /dev/stdin)"
  else
    input="$1"
  fi
  echo "$input" | tr -d '[:space:][:alpha:].,' | sed -n 's/^[^0-9]*\([0-9]\+\).*$/\1/p'
}

function cleanup {
  rm "$tmp"
}

function check_if_cheaper {
  reduction='false'
  for ((i=1; i<=checks_len; i++)); do
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
  for ((i=0; i<checks_len; i++)); do
    body=$(echo -ne "$body\n${checks[$i,0]}: ${checks[$i,4]}\n${checks[$i,1]}\n")
  done
  echo -e "$body" | mail -s "Olcsóbb a(z) $1" "$2"
}
