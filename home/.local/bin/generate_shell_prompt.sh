#!/bin/bash

# Make tempfiles
temp="$(mktemp)"
log="$(mktemp)"

# Check target file, if symlink (eg. homeshick castle), follow it
target="$HOME/.shell_prompt.sh"
if [ -L "$target" ]; then
    target="$(readlink -f "$target")"
fi

# Put the vim commands into the tempfile
cat >"$temp" <<EOF
redir! >$log

" promptline.vim needs to be enabled
if exists(":PromptlineSnapshot")
    let g:promptline_theme = 'airline'

    " Override the built-in powerline symbols (especially truncation)
    " Note: this needs to be done before section, because once
    " promptline#slices#cwd is mentioned, it will not rewritten
    let g:promptline_symbols = {
        \ 'left'       : '',
        \ 'left_alt'   : '',
        \ 'dir_sep'    : '  ',
        \ 'truncation' : '…',
        \ 'vcs_branch' : ' ',
        \ 'space'      : ' '}

    " Sections (a, b, c, x, y, z, warn) are optional
    let g:promptline_preset = {
        \ 'a'    : [ promptline#slices#host({ 'only_if_ssh': 1 }) ],
        \ 'b'    : [ promptline#slices#user() ],
        \ 'c'    : [ promptline#slices#cwd({ 'dir_limit': 2 }) ],
        \ 'y'    : [ promptline#slices#vcs_branch() ],
        \ 'warn' : [ promptline#slices#last_exit_code() ]}

    " Overwrite the file even if it exists
    PromptlineSnapshot! $target
else
    echo "Error: the plugin promptline.vim is not enabled."
endif

redir END
q
EOF

# Call vim in ex mode and memory only with the script
vim -e -n -S "$temp" 2>&1

# Display the output
cat "$log"

# Cleanup
rm "$temp" "$log"
