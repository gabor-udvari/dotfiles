#!/bin/bash

# Check for parallel
if ! command -v parallel >/dev/null; then
  echo 'ERROR: parallel is required for this script'
  exit 1
fi

ssh_keys="$(sed -n '/IdentityFile/ s/^[[:space:]]*IdentityFile \(.*\)$/\1/p' "$HOME/.ssh/config" | sort -n | uniq)"

# Add SSH key
# Use parallel so that tty can be used for ssh-add password input
echo "$ssh_keys" | sed "s#^~#$HOME#" | parallel --tty --env SSH_AUTH_SOCK --env SSH_AGENT_PID --env SSH_ENV 'echo "Checking key {}"; ssh-add -l | grep -F {} || ssh-add {}'

proxies="$(sed -n '/ProxyJump/ s/^[[:space:]]*ProxyJump \(.*\)$/\1/p' "$HOME/.ssh/config" | sort -n | uniq)"

# Launch SSH tunnels
if [ -n "$proxies" ]; then
  echo "$proxies" | parallel -j 2 'echo "Checking proxy {}"; pgrep -f "^ssh -f -N -o .* {}" || ssh -f -N -o ConnectTimeout=10 {}'
fi
