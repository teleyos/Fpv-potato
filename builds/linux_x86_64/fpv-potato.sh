#!/bin/sh
echo -ne '\033c\033]0;Fpv\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/fpv-potato.x86_64" "$@"
