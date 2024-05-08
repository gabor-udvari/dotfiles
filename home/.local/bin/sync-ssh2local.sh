#!/bin/bash

# eg.: user@host:/var/www
INPUT="user@host:/var/www"
# eg.: /var/www
OUTPUT="/var/www/"
# eg.: --rsh "ssh -p 1234 -i /home/user/.ssh/id_rsa"
REMOTE="--rsh \"ssh -p 1234 -i /home/user/.ssh/id_rsa\""

OPTIONS="--archive"
DRY="--verbose --dry-run"

COMMAND="rsync $OPTIONS $DRY $REMOTE \"$INPUT\" \"$OUTPUT\""

echo $COMMAND
eval $COMMAND

ret_code=$?
if [ $ret_code != 0 ]; then
  printf "Error : [%d] when executing command: '$COMMAND' \r" $ret_code
  exit $ret_code
fi

COMMAND="rsync $OPTIONS $REMOTE \"$INPUT\" \"$OUTPUT\""

read -p "Do you want to sync the above? (y/n): "
[ "$REPLY" == "y" ] && eval $COMMAND
