#!/bin/bash

ssh_keys="$(sed -n '/IdentityFile/ s/^[[:space:]]*IdentityFile \(.*\)$/\1/p' "$HOME/.ssh/config" | sort -n | uniq)"

# Add SSH key
echo "$ssh_keys" | sed "s#^~#$HOME#" | while read -r k; do echo "Checking key $k"; ssh-add -l | grep -F "$k" || ssh-add "$k"; done

proxies="$(sed -n '/ProxyJump/ s/^[[:space:]]*ProxyJump \(.*\)$/\1/p' "$HOME/.ssh/config" | sort -n | uniq)"

# Launch SSH tunnels
echo "$proxies" | parallel -j 2 'echo "Checking proxy {}"; pgrep -f "^ssh -f -N {}" || ssh -f -N {}'
