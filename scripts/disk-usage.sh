#!/usr/bin/env bash
# disk-usage.sh — show the 10 largest files under /home
set -euo pipefail

TARGET="${1:-/home}"

if [[ ! -d "$TARGET" ]]; then
	  echo "Directory $TARGET does not exist" >&2
	    exit 1
fi

echo "Top 10 largest files under $TARGET:"
echo

find "$TARGET" -type f -printf '%s\t%p\n' 2>/dev/null \
	  | sort -rn \
	    | head -10 \
	      | awk '{
      size = $1
            $1 = ""
	          sub(/^ /, "")
		        if (size >= 1073741824) printf "%.2f GB  %s\n", size/1073741824, $0
				      else if (size >= 1048576) printf "%.2f MB  %s\n", size/1048576, $0
					            else if (size >= 1024) printf "%.2f KB  %s\n", size/1024, $0
							          else printf "%d B   %s\n", size, $0
									      }'

