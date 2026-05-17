# =============================================================================
# crontab — disk-usage scheduled job
# =============================================================================
# This file defines the cron schedule for disk-usage.sh
#
# HOW TO INSTALL on your Linux machine:
#   crontab crontab.txt          ← replaces your entire crontab
#   OR
#   crontab -e                   ← paste the lines manually (safer)
#
# HOW TO VERIFY after installing:
#   crontab -l                   ← list active cron jobs
#   tail -f /var/log/disk-usage-cron.log   ← watch live output
# =============================================================================

# Send all cron output to this email address (change to your address)
MAILTO="dinesharma1994@gmail.com"

# PATH — ensure cron can find system binaries
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# =============================================================================
# SCHEDULE SYNTAX:
#
#  ┌────────── minute       (0-59)
#  │  ┌─────── hour         (0-23)
#  │  │  ┌──── day of month (1-31)
#  │  │  │  ┌─ month        (1-12)
#  │  │  │  │  ┌ day of week (0-7, 0 and 7 = Sunday)
#  │  │  │  │  │
#  *  *  *  *  *   command
# =============================================================================

# Run disk-usage.sh every 10 minutes, scan /home, log to /var/log
*/10 * * * * /usr/bin/disk-usage-cron.sh >> /var/log/disk-usage-cron.log 2>&1

