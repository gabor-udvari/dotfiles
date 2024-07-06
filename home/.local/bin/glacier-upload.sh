#!/usr/bin/env bash

prepare_file() {
  input="$1"

  test -f "$input" || exit 1

  description="$(basename "$input" | sed 's/-\([0-9]\{4\}[^.]*\)\..*$/ \1/')"

  apiresult="$(aws glacier initiate-multipart-upload --account-id - --vault-name gaborudvari --archive-description "$description" --part-size "$partsize")"

  uploadid="$(echo "$apiresult" | sed -n 's/^.*uploadId": "\([^"]*\).*$/\1/p')"

  # Return the uploadid
  echo "$uploadid"
}

force_encryption() {
  input="$1"
  gpg="$2"

  [ -f "$input" ] || exit 1
  [ -z "$gpg" ] && exit 1

  if file "$input" | grep -q 'encrypted'; then
    # File is already encrypted, nothing to do
    echo "$input"
    return 0
  else
    echo "The file $1 is not encrypted, encrypting now." >&2
    # Encrypt the file
    gpg -e -r "$2" "$1"
    # Remove the original
    rm "$1"
    echo "$1.gpg"
    return 0
  fi
}

upload_parts() {
  if [ "$#" -lt 2 ]; then
    echo "ERROR: not enough parameters for upload_parts, file and upload id is required."
    return 1
  fi

  # Get the input file
  input="$1"
  # Get the upload id
  u="$2"

  temp_chunk="$(mktemp -d)"

  # Get the size, and slice up the file
  size="$(du -b "$input" | sed -n 's/^\([0-9]\+\).*$/\1/p')"
  split --bytes "$partsize" --verbose "$input" --suffix-length 4 -d "$temp_chunk/chunk-"

  min_bytes=0
  for f in "$temp_chunk"/chunk-*; do
    max_bytes=$(( min_bytes + partsize - 1))
    if [ "$max_bytes" -ge "$size" ]; then
      max_bytes=$((size - 1));
    fi

    # Issue the upload command
    echo "Uploading $f, range: $min_bytes-$max_bytes"
    aws glacier upload-multipart-part --account-id - --vault-name gaborudvari --upload-id "$u" --range 'bytes '"$min_bytes-$max_bytes"'/*' --body "$f" | sed -n 's/^.*checksum": "\([^"]*\).*$/AWS checksum: \t\t\1/p'

    # Calculate the tree hash
    echo -n -e "Local checksum: \t"
    calculate_tree_hash "$f"

    min_bytes=$(( min_bytes + partsize ))
  done

  # Calculate the hash for the whole file
  file_hash="$(calculate_tree_hash "$temp_chunk"/chunk-*)"

  echo "File hash: $file_hash"

  # Complete the upload job
  aws glacier complete-multipart-upload --account-id - --vault-name gaborudvari --upload-id "$u" --archive-size "$(( max_bytes+1 ))" --checksum "$file_hash"
}

calculate_tree_hash() {
  max_files="$#"

  # Check all files if they exist
  for f in "$@"; do
    test -f "$f" || exit 1
  done

  temp="$(mktemp -d)"

  if [ "$max_files" -eq 1 ] && [ "$(du -b "$1" | sed -n 's/^\([0-9]\+\).*$/\1/p')" -lt 1048576 ]; then
    # If the files is less than 1MB, then there is no reason to split it
    # Just copy it to top-hashes, and use it as it is
    cp "$1" "$temp/top-hashes-0000-0000.bin"
  else
    # Start the checksum calculation for the files
    i_f=0
    for f in "$@"; do
      # Split to 1MB parts
      prefix_parts="$temp/parts-$(printf %04d "$i_f")"
      split "$f" --bytes 1048576 -d "$prefix_parts-" 1>/dev/null

      # Loop through the parts and generate the initial binary hashes
      i_h=0
      prefix_filehashes="$temp/hashes-$(printf %04d "$i_f")"
      for p in "$prefix_parts"-*; do
        openssl dgst -sha256 -binary "$p" >"$prefix_filehashes-0000-$(printf %04d "$i_h").bin"
        (( i_h++ ))
      done

      # We done generating the hashes, build the tree
      # We use process substitution because we need ith to be increased in the loop
      ith=0
       while read -r th; do
        cp "$th" "$temp/top-hashes-$(printf %04d "$i_f")-$(printf %04d "$ith").bin"
        (( ith++ ))
      done <<<"$(process_tree "$prefix_filehashes"-0000-*.bin)"

      if [ "$ith" -eq 0 ]; then
        echo "ERROR: could not build a tree for $prefix_filehashes-0000-*.bin"
        return 1
      fi

      (( i_f++ ))
    done
  fi

  # Get the human readable checksum based on number of input files
  if [ "$max_files" == 1 ]; then
    # Get the human readable sha256sum from the latest level
    cat "$temp/top-hashes"-*.bin | openssl dgst -sha256 | cut -d ' ' -f2
  else
    # We done generating the hashes, build the tree
    ith=0
    while read -r th; do
      cp "$th" "$temp/top-hashes-all-$(printf %04d "$i_f")-$(printf %04d "$ith").bin"
      (( ith++ ))
    done <<<"$(process_tree "$temp/top-hashes"-*.bin)"
    cat "$temp/top-hashes-all"-*.bin | openssl dgst -sha256 | cut -d ' ' -f2
  fi

  # Cleanup
  # echo "$temp"
  # rm -rf "$temp"
}

process_tree() {
  # Process a list of files, make a tree of binary hashes,
  # and return the top 2 files. This function does not distinct
  # between group of files, handles all the input as one tree
  max_files="$#"
  temp="$(mktemp -d)"

  if echo "$1" | grep -qF '*'; then
    return 1
  fi

  # Copy all the input into an ordered set of files
  if=0
  for f in "$@"; do
    cp "$f" "$temp/hashes-0000-$(printf %04d "$if").bin"
    (( if++ ))
  done

  # Emulating a do..while loop
  # As taken from: https://stackoverflow.com/a/16491478
  l=0
  while
    max_hashes="$(find "$temp" -name "hashes-$(printf %04d "$l")-*.bin" -type f | wc -l)"
    prefix_hashes="$temp/hashes-$(printf %04d "$l")"
    h=0
    nh=0
    while [ "$h" -lt "$max_hashes" ] && [ "$max_hashes" -gt 2 ]; do
      lf="$prefix_hashes-$(printf %04d $h).bin"
      lnf="$prefix_hashes-$(printf %04d $(( h+1 ))).bin"
      nlf="$temp/hashes-$(printf %04d $(( l+1 )))-$(printf %04d $nh).bin"
      if [ $h -lt $((max_hashes - 1)) ]; then
        # There are 2 more hashes, calculate a sum
        cat "$lf" "$lnf" | openssl dgst -sha256 -binary >"$nlf"
        (( nh++ ))
      else
        # There is only 1 left, just copy it to the next level
        cp "$lf" "$nlf"
        (( nh++ ))
      fi
      (( h += 2 ))
    done
    (( l++ ))

    # Do the above every level, until only 2 hashes remain
    [ "$max_hashes" -gt 2 ]
  do
    :
  done

  # Return the penultimate level, two files
  ls -1 "$temp/hashes-$(printf %04d $(( l-1)))"-*.bin
}

# Part size must be factor of 2
partsize=67108864

if [ -f "$1" ] && [ -n "$2" ]; then
  input="$(force_encryption "$1" "$2")"
  uploadid="$(prepare_file "$input")"
  upload_parts "$input" "$uploadid"
else
  echo "No such file: $1 or the GPG ID was not set"
  exit 1
fi
