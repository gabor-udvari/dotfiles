#!/bin/bash

ssh_keys="$(sed -n '/IdentityFile/ s/^[[:space:]]*IdentityFile \(.*\)$/\1/p' "$HOME/.ssh/config" | sort -n | uniq)"

# Add SSH key
echo "$ssh_keys" | parallel 'ssh-add -l | grep -F $(basename {}) || ssh-add {}'

proxies="$(sed -n '/ProxyJump/ s/^[[:space:]]*ProxyJump \(.*\)$/\1/p' "$HOME/.ssh/config" | sort -n | uniq)"

# Launch SSH tunnels
echo "$proxies" | parallel -j 2 'echo "Checking proxy {}"; pgrep -f "^ssh -f -N {}" || ssh -f -N {}'
