#!/usr/bin/env bash
# listening-ports.sh — show listening TCP ports with owner process
set -euo pipefail

if (( EUID != 0 )); then
	  echo "Note: run as root for full process visibility" >&2
fi

printf "%-8s %-25s %-10s %s\n" "PROTO" "ADDRESS:PORT" "PID" "PROCESS"
printf "%-8s %-25s %-10s %s\n" "-----" "------------" "---" "-------"

ss -tlnp | tail -n +2 | while read -r netid state recvq sendq local peer process; do
  proto="tcp"
    pid=$(echo "$process" | grep -oP 'pid=\K[0-9]+' | head -1)
      proc=$(echo "$process" | grep -oP '"\K[^"]+' | head -1)
        printf "%-8s %-25s %-10s %s\n" "$proto" "$local" "${pid:-?}" "${proc:-?}"
done

