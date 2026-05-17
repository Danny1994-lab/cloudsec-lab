#!/usr/bin/env bash
# audit-users.sh — list non-system users with key attributes
set -euo pipefail

printf "%-20s %-10s %-25s %-20s %s\n" "USERNAME" "UID" "HOME" "SHELL" "LAST LOGIN"
printf "%-20s %-10s %-25s %-20s %s\n" "--------" "---" "----" "-----" "----------"

while IFS=: read -r username _ uid _ _ home shell; do
	  if (( uid >= 1000 && uid < 65534 )); then
		      last_login=$(lastlog -u "$username" 2>/dev/null | awk 'NR==2 {if ($2 == "**Never") print "Never"; else print $4, $5, $6, $7}')
		          [[ -z "$last_login" ]] && last_login="Unknown"
			      printf "%-20s %-10s %-25s %-20s %s\n" "$username" "$uid" "$home" "$shell" "$last_login"
			        fi
			done < /etc/passwd

