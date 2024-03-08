#!/bin/bash -

Usage() { echo "$0 [-w width] FontFile"; exit 1; }
SayError() { local error=$1; shift; echo "$0: $@"; exit "$error"; }

# Parse arguments
while getopts ":w:" opt; do
  case ${opt} in
    w )
      width=$OPTARG
      ;;
    \? )
      Usage
      ;;
  esac
done
shift $((OPTIND -1))

# Set width (default = 77)
width=${width:-77}

# Check if there is a file
[ "$#" -eq 2 ] && Usage
fontfile="$1"

[ -f "$fontfile" ] || SayError 4 'File not found'

list=$(fc-query --format='%{charset}\n' "$fontfile")

for range in $list
do IFS=- read start end <<<"$range"
  if    [ "$end" ]
  then
      start=$((16#$start))
      end=$((16#$end))
      for((i=start;i<=end;i++)); do
          printf -v char '\\U%x' "$i"
          printf ' %s:%b ' "$char" "$char" 
      done
  else
      printf '%b ' "\\U$start"
  fi
done | grep -oP '.{'"$width"'}'
