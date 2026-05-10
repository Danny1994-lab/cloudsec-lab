**WEEK 2 — LINUX FUNDAMENTALS**
Lecturer's note on Week 2
Almost every cloud workload — every container, every Kubernetes pod, every serverless function, every managed database — runs on Linux underneath. AWS Lambda runs Linux. Azure Functions run Linux (or .NET on Linux). Kubernetes nodes are Linux. Every Docker container is, at its core, an isolated Linux process tree. Even Windows-shop enterprises run their security tooling on Linux because the SIEM, the EDR backends, and the analyst workstations are all Linux-based.
So for the next week, we live in a Linux terminal. Every concept you learn here is one you'll use every working day for the rest of your career.
________________________________________
**Module 2.1 — The Linux Philosophy and Filesystem Layout**
Concept
Linux is built on a philosophy — articulated by Doug McIlroy in the early 1970s — that programs should do one thing well, work together using text streams, and treat the filesystem as a universal interface. This is why a single line like ps aux | grep nginx | awk '{print $2}' | xargs kill works: each tool does one job, and pipes glue them together.
The filesystem is hierarchical and starts at / (the root). Everything — including hardware devices, running processes, kernel parameters, and network interfaces — appears as a file or directory somewhere under /. This is the everything is a file principle, and it's why Linux is such a powerful platform for automation.
The standard directories
Open a terminal and run ls /. You'll see something like:
bin   boot  dev  etc  home  lib  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
You don't need to memorise every directory, but understand the important ones:
PathPurposeWhy it matters
/etc/System configuration filesWhere every service stores its config; first place to look when something breaks
/var/log/Log filesFirst place to look when investigating an incident
/home/User home directoriesPersonal files, SSH keys, shell history
/tmp/Temporary filesWorld-writable; security risk if used for persistent data
/proc/Virtual filesystem of running processes/proc/<PID>/cmdline shows what a process is running
/sys/Virtual filesystem of kernel/devicesUsed to read or change kernel runtime parameters
/usr/bin/Standard user binariesWhere most installed programs live
/usr/local/bin/Locally-installed softwareWhere you put your own scripts and tools
/opt/Third-party softwareWhere vendors install standalone applications
/dev/Device files/dev/null is the void; /dev/random is randomness
Worked example
Let's confirm the philosophy with a quick experiment:
cat /proc/cpuinfo | head -25  - Head -25 provide only the top 25. 
You're literally catting (reading) a file that contains live information about your CPU. There is no special "show me CPU info" command — the kernel exposes the data as a file, and any tool that can read a file can read CPU info.
cat /etc/os-release
Same trick — your operating system identity is stored in a plain text file you can read with the same cat you'd use on a shopping list.
Why this matters in cloud security
When you investigate a compromised container or host, you'll spend most of your time reading from /proc, /var/log, and /etc. An attacker who modified /etc/passwd to add a backdoor account, or who stored a binary in /tmp, leaves traces in these standard locations. Knowing the layout cold lets you move fast under pressure.
________________________________________
Module 2.2 — Navigating the Filesystem
The core commands
These are commands you'll type thousands of times. Build muscle memory.
pwd — print working directory
Tells you where you are. The first thing to check when a script behaves unexpectedly.
pwd
# /home/dinesh
cd — change directory
cd /etc                  # absolute path
cd nginx                 # relative — only works if /etc/nginx exists
cd ..                    # up one level
cd ~                     # back to your home directory
cd -                     # back to the previous directory you were in (handy)
ls — list contents
The most-used command in Linux. Memorise these flags:
ls                       # plain list
ls -l                    # long form: permissions, size, owner, date
ls -la                   # long form, including hidden (.dotfile) files
ls -lh                   # human-readable sizes (KB, MB)
ls -lS                   # sort by size, largest first
ls -lt                   # sort by modification time, newest first
ls -laR /etc             # recursive — careful, can be huge
Worked example:
ls -lh /var/log
Output explained, line by line:
-rw-r----- 1 syslog  adm   1.2M May  9 14:23 syslog
^^^^^^^^^^   ^       ^     ^^^^ ^^^^^^^^^^^^ ^^^^^^
permissions  owner   group size date          filename
The leading character of the permissions tells you the file type:
•- regular file
•d directory
•l symbolic link
•c character device (e.g. /dev/tty)
•b block device (e.g. /dev/sda)
•p named pipe
•s socket
find — search the filesystem
This is where students get scared. Don't be. The pattern is always: find <where> <what>.
find /etc -name "*.conf"                    # all .conf files under /etc
find /home -type f -size +100M              # files larger than 100MB
find /var/log -type f -mtime -1             # modified in the last 1 day
find / -perm -4000 -type f 2>/dev/null      # files with SUID bit (more on this in 2.3)
find /tmp -user root -type f                # files in /tmp owned by root
The 2>/dev/null at the end discards permission-denied errors, which appear constantly when you're searching from / as a non-root user.
tree — directory tree visualisation
Not installed by default. Useful for understanding a project layout.
sudo apt install tree
tree -L 2 /etc          # only 2 levels deep
tree -d /etc            # directories only
du — disk usage
du -sh /var/log         # total size of /var/log, human-readable
du -sh /var/log/*       # size of each file/folder inside /var/log
du -sh /var/log/* | sort -h    # sorted small to large
df — disk free
df -h                   # disk space used per filesystem, human-readable
df -i                   # inode usage (when files won't create even though space exists)
Pitfall — running out of inodes
A filesystem can have free space but be unable to create new files because it has run out of inodes (the metadata records that describe each file). This is rare but devastating. Symptoms: "No space left on device" while df -h shows free space. Diagnose with df -i. Common cause: a runaway log directory with millions of tiny files.
Why this matters in cloud security
You'll routinely SSH into a compromised box and need to find: every file modified in the last 24 hours, every file owned by an unexpected user, every file with SUID set, the largest files (looking for hidden data caches). find is your hunting tool.
________________________________________
Module 2.3 — File Permissions, Ownership, and Special Bits
Concept
Linux permissions are deceptively simple. Every file has an owner (a user) and a group, and three sets of permissions: what the owner can do, what members of the group can do, and what everyone else can do. Each set has three bits: read (r), write (w), and execute (x).
This is the most-tested topic in junior security interviews. Master it.
Reading permissions
ls -l /etc/shadow
# -rw-r----- 1 root shadow 1234 May  9 14:23 /etc/shadow
Decoded:
PositionValueMeaning
1-Regular file
2-4rw-Owner (root) can read and write
5-7r--Group (shadow) can read
8-10---Everyone else: nothing
This is exactly right for /etc/shadow — the file containing password hashes. If you ever see it as -rw-r--r--, you have a critical security problem.
Numeric (octal) notation
Each permission triplet is a binary number:
SymbolicBinaryOctal
---0000
--x0011
-w-0102
-wx0113
r--1004
r-x1015
rw-1106
rwx1117
So chmod 755 file means owner=rwx, group=rx, other=rx. chmod 600 means owner=rw, nobody else can do anything. Memorise the common ones:
•644 — typical regular file (owner can write, others can read)
•755 — typical script or directory (owner can write, others can read and execute)
•600 — sensitive file like an SSH private key
•700 — sensitive directory like ~/.ssh
•777 — danger sign; everyone can do everything
Worked example
touch test.txt
ls -l test.txt
# -rw-r--r-- 1 dinesh dinesh 0 May  9 14:23 test.txt

chmod 600 test.txt
ls -l test.txt
# -rw------- 1 dinesh dinesh 0 May  9 14:23 test.txt
You can also use symbolic mode:
chmod u+x test.txt        # add execute for owner (user)
chmod g-w test.txt        # remove write for group
chmod o=r test.txt        # set other to exactly r
chmod a+r test.txt        # 'a' = all
chown — change ownership
sudo chown dinesh:dinesh test.txt        # change owner and group
sudo chown :wheel test.txt               # change only group
sudo chown -R dinesh:dinesh /home/dinesh # recursive — careful
umask — default permissions for newly created files
When you create a file, it doesn't get 777. The system applies a mask that subtracts permissions. Your shell's default is usually 022, meaning new files are created with 666 - 022 = 644 and new directories with 777 - 022 = 755.
umask                     # show current mask
umask 077                 # set restrictive: new files = 600, directories = 700
For a shared server hosting sensitive material, umask 077 is a good default in /etc/profile.
Special bits — the SUID, SGID, and sticky bit
These are the bits that get attackers excited.
SUID (Set User ID, octal 4000)
When set on an executable, the program runs as the owner of the file rather than the user invoking it. The classic example is /usr/bin/passwd:
ls -l /usr/bin/passwd
# -rwsr-xr-x 1 root root 68208 May  9 14:23 /usr/bin/passwd
Notice the s where the owner's x would be. That's SUID. Any user can run passwd, but the program runs as root so it can write to /etc/shadow.
This is also why SUID files are an attacker's first hunting ground. If you find an SUID-root program with a vulnerability, you have local privilege escalation.
# Find all SUID-root files
find / -perm -4000 -user root -type f 2>/dev/null
SGID (Set Group ID, octal 2000)
Same concept but for group. On a directory, SGID also makes new files inherit the directory's group.
Sticky bit (octal 1000)
On a directory, the sticky bit means only the file's owner can delete files inside, even if the directory itself is world-writable. The classic example is /tmp:
ls -ld /tmp
# drwxrwxrwt 23 root root 4096 May  9 14:23 /tmp
The trailing t is the sticky bit. Without it, any user could delete any other user's files in /tmp.
Setting special bits
chmod u+s myprogram       # add SUID
chmod g+s mydir           # add SGID
chmod +t mydir            # add sticky bit

# Or numerically — special bits are the leading digit
chmod 4755 myprogram      # SUID + 755
chmod 2755 mydir          # SGID + 755
chmod 1755 mydir          # sticky + 755
Pitfall — chmod 777 is almost never the answer
When something doesn't work because of permissions, students reach for chmod -R 777 to "make it work". This:
1.Almost certainly creates a security hole.
2.Doesn't even fix the actual problem most of the time.
3.Is a giant red flag in code review.
Always identify which user and which permission is missing, then make the smallest change. If a web server can't read /var/www/site, the fix is chown -R www-data:www-data /var/www/site, not chmod -R 777.
Why this matters in cloud security
Container security, Kubernetes Pod Security Standards, AWS S3 bucket policies, and Azure RBAC all extend the same model: who is the principal, what is the action, what is the resource, what is the effect. Linux permissions are the simplest expression of this model. If you understand them deeply, the rest is easy.
________________________________________
Module 2.4 — Processes and Process Management
Concept
A process is a running instance of a program. The kernel assigns each one a unique process ID (PID) and tracks its memory, file descriptors, owner, parent process, and more. Linux exposes all of this through /proc/<PID>/. Every interactive command you type spawns a process; every service is a process; every container is a process tree.
Inspecting processes
ps — process snapshot
The two flag combinations you need:
ps aux                    # all processes, BSD style — most common
ps -ef                    # all processes, System V style — also common
ps aux columns: USER, PID, %CPU, %MEM, VSZ (virtual size), RSS (resident size), TTY, STAT, START, TIME, COMMAND.
The STAT column is worth knowing:
•R running
•S sleeping (waiting for something, normal)
•D uninterruptible sleep (usually waiting for I/O — a stuck D is bad)
•Z zombie (dead but not reaped)
•T stopped (e.g. by Ctrl+Z)
Common patterns:
ps aux | grep nginx                 # find nginx processes
ps -ef --forest                     # show parent-child tree
ps -p 1234 -o pid,user,cmd          # specific PID, specific columns
top — live process monitor
top
Inside top, press:
•M to sort by memory
•P to sort by CPU
•1 to show all CPU cores
•k then PID to kill a process
•q to quit
htop — friendlier top
Not installed by default. Worth installing on every machine you touch:
sudo apt install htop
htop
Colour-coded, scrollable, mouse-supportive. Press F5 for tree view.
Sending signals
A signal is a message to a process. The kernel and other programs use signals to ask processes to do things — most commonly, to stop.
kill 1234                 # send SIGTERM (15) — polite "please exit"
kill -9 1234              # send SIGKILL (9) — forced, cannot be caught
kill -HUP 1234            # send SIGHUP (1) — typically reload config
killall nginx             # send SIGTERM to all processes named nginx
pkill -f "python myscript.py"   # match command line, not just name
Pitfall — kill -9 is the nuclear option
SIGKILL cannot be caught by the process, so it cannot clean up — open files may be corrupted, locks may be left held, child processes may be orphaned. Always try SIGTERM first, wait a few seconds, only then escalate to SIGKILL.
Background, foreground, and nohup
long-running-command &           # run in the background; you keep your shell
jobs                             # list backgrounded jobs
fg %1                            # bring job 1 back to foreground
bg %1                            # send job 1 to background

nohup long-running-command &     # immune to your terminal closing
The combination nohup ... & is how you start a long-running script and walk away. Modern alternative: tmux or screen, both of which give you a detachable session.
systemctl — managing services
Modern Linux uses systemd to manage services. Every long-running daemon (sshd, nginx, docker, etc.) is a unit under systemd's control.
sudo systemctl status sshd        # is it running?
sudo systemctl start nginx
sudo systemctl stop nginx
sudo systemctl restart nginx
sudo systemctl reload nginx       # reload config without restarting
sudo systemctl enable nginx       # start at boot
sudo systemctl disable nginx
sudo systemctl list-units --type=service --state=running
Service files live under /etc/systemd/system/ and /lib/systemd/system/.
Why this matters in cloud security
When you respond to an incident on a Linux host, the first three things you do are: run ps auxf and look for unexpected processes, check lsof -i for unexpected network connections, check journalctl -u suspicious.service for the service's logs. Every container compromise investigation starts with these commands.
________________________________________
Module 2.5 — Networking from the Command Line
Concept
A Linux host's network configuration lives in three layers: the interfaces (physical or virtual NICs), the routes (where to send packets for each destination), and the listening sockets (which ports are open). The commands here let you inspect all three.
ip — the modern Swiss army knife
The old ifconfig, route, and arp are deprecated. Use ip instead.
ip a                      # show all interfaces and their IP addresses
ip a show eth0            # show only eth0
ip r                      # show routing table
ip neigh                  # show ARP table (neighbours)
Sample output of ip a:
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 ...
    inet 127.0.0.1/8 scope host lo
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 ...
    link/ether 02:42:ac:11:00:02 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.2/16 brd 172.17.255.255 scope global eth0
Read this as: there are two interfaces, lo (loopback) and eth0. eth0 has IP 172.17.0.2 in subnet /16, MAC address 02:42:ac:11:00:02, and is up.
ss — socket statistics (the modern netstat)
This is the command you'll run a hundred times a week.
ss -tulnp                 # TCP+UDP, listening only, numeric, with process
Letter-by-letter:
•t TCP
•u UDP
•l listening sockets only
•n numeric (don't resolve names — much faster)
•p show the owning process (needs root for other users' processes)
Sample output:
Netid State   Recv-Q Send-Q Local Address:Port  Peer Address:Port  Process
tcp   LISTEN  0      128    0.0.0.0:22          0.0.0.0:*          ("sshd",pid=842,fd=3)
tcp   LISTEN  0      128    127.0.0.1:6379      0.0.0.0:*          ("redis-server",pid=901,fd=6)
Read this as: sshd is listening on port 22 on every interface (0.0.0.0); redis is listening on port 6379 but only on localhost (127.0.0.1) — meaning it cannot be reached from outside the host.
netstat — legacy but still common
sudo netstat -tulnp       # equivalent to ss -tulnp
sudo netstat -plnt        # popular alias
You'll see this in older guides; treat as equivalent.
dig — DNS lookups
dig microsoft.com                 # default A record query
dig microsoft.com MX              # mail server lookup
dig microsoft.com TXT             # text records (SPF, verification, etc.)
dig +trace microsoft.com          # full recursive trace from the root servers
dig +short microsoft.com          # just the answer, no chatter
A +trace walks the entire DNS hierarchy in front of you — root → TLD → authoritative nameservers — and is one of the best ways to actually understand DNS.
nslookup — older DNS tool
nslookup microsoft.com
Use dig in scripts; nslookup is fine for quick interactive checks.
curl and wget — HTTP from the terminal
curl https://example.com                       # GET, print to stdout
curl -I https://example.com                    # HEAD only — just headers
curl -v https://example.com                    # verbose: full request and response
curl -X POST https://api.example.com/data \
  -H "Content-Type: application/json" \
  -d '{"name":"test"}'                         # POST with JSON body
curl -o file.tar.gz https://example.com/file.tar.gz   # save to file

wget https://example.com/file.tar.gz           # save to current directory
wget -r --level=1 https://example.com          # recursive, one level deep
curl -v is your best friend for debugging APIs, TLS issues, and redirects.
Why this matters in cloud security
A misconfigured cloud workload that "doesn't work" usually has a network reason. You'll spend hours of every week running ss -tulnp to check what's listening, dig to verify a CNAME points where you think, and curl -v to confirm a TLS handshake completes. These are the diagnostic muscles of the job.
________________________________________
Module 2.6 — Text Processing and the Power of Pipes
Concept
Pipes (|) connect the output of one command to the input of another. This is the heart of Unix philosophy. With four or five small tools, you can write a one-liner that takes minutes to build but would take an hour in a programming language.
grep — pattern matching
grep "ERROR" /var/log/syslog                    # lines containing ERROR
grep -i "error" /var/log/syslog                 # case-insensitive
grep -v "DEBUG" log.txt                         # invert: lines NOT matching
grep -r "TODO" .                                # recursive in current dir
grep -n "Failed" /var/log/auth.log              # show line numbers
grep -E "error|fail|warn" log.txt               # extended regex with OR
grep -A 3 -B 1 "ERROR" log.txt                  # 3 lines after, 1 before each match
sed — stream editor
sed is for substitutions and filtering. The s/old/new/ pattern is the one you'll use 90% of the time.
sed 's/foo/bar/' file.txt                       # replace first occurrence per line
sed 's/foo/bar/g' file.txt                      # replace all occurrences (g = global)
sed -i 's/foo/bar/g' file.txt                   # edit file in place
sed -n '10,20p' file.txt                        # print only lines 10 to 20
sed '/^#/d' file.txt                            # delete comment lines
⚠️ Pitfall: sed -i on a Mac requires a backup-extension argument (sed -i '' 's/.../.../g' file). On Linux it's just sed -i.
awk — column-aware text processing
awk treats input as records (lines) and fields (columns). The default field separator is whitespace.
awk '{print $1}' file.txt                       # print the first column
awk '{print $1, $3}' file.txt                   # first and third
awk -F: '{print $1}' /etc/passwd                # use ':' as separator (passwd file)
awk '$3 > 1000 {print $1}' /etc/passwd          # users with UID > 1000 (we'll use this in the lab)
awk '/ERROR/ {count++} END {print count}' log.txt   # count ERROR lines
awk is a full programming language. You'll never use most of it, but the patterns above will get you 90% of the value.
cut, sort, uniq, tr
cut -d: -f1 /etc/passwd                         # take first colon-separated field
cut -c1-10 file.txt                             # first 10 characters of each line

sort file.txt                                   # alphabetical
sort -n file.txt                                # numerical
sort -r file.txt                                # reverse
sort -k2 file.txt                               # sort by second column

uniq                                            # collapse adjacent duplicates (data must be sorted)
sort file.txt | uniq -c                         # count occurrences
sort file.txt | uniq -c | sort -rn              # count, sorted by frequency

echo "Hello World" | tr 'a-z' 'A-Z'             # change case
tr -d '\r' < windows.txt > unix.txt             # delete carriage returns
Pipes and redirection
command1 | command2                # pipe stdout of cmd1 to stdin of cmd2
command > file                     # redirect stdout to file (overwrite)
command >> file                    # redirect stdout to file (append)
command 2> error.log               # redirect stderr to file
command > out.log 2>&1             # redirect both stdout and stderr to one file
command &> out.log                 # shorthand for the same (bash)
command < file                     # take stdin from file
Worked example — the kind of one-liner you'll write daily
"Show me the top 10 IPs in my web server access log, by request count":
awk '{print $1}' /var/log/nginx/access.log \
  | sort \
  | uniq -c \
  | sort -rn \
  | head -10
Decoded:
1.awk extracts the first column (the source IP).
2.sort so identical IPs become adjacent.
3.uniq -c collapses duplicates and adds counts.
4.sort -rn sorts by count, descending.
5.head -10 takes the top 10.
That's a brute-force-attack-detection one-liner.
Why this matters in cloud security
Every log analysis you do — Wazuh alerts, Sentinel KQL, EDR exports, audit logs — eventually comes back to this kind of text manipulation. KQL and SQL are nicer interfaces, but the underlying logic is identical: filter, group, count, sort. Master the command-line version and the cloud SIEM versions will feel familiar.
________________________________________
Module 2.7 — Package Management
Concept
Package managers install, update, and remove software, handling dependencies automatically. On Debian/Ubuntu, the high-level tool is apt; the low-level tool is dpkg. On Red Hat / CentOS / Fedora, the high-level is dnf (formerly yum) and low-level is rpm.
We focus on apt here because that's what you'll use on your WSL2 Ubuntu and on most cloud Linux images.
Daily commands
sudo apt update                                # refresh package metadata
sudo apt upgrade                               # install pending updates
sudo apt install nginx                         # install a package
sudo apt remove nginx                          # remove (keep config files)
sudo apt purge nginx                           # remove (delete config files too)
sudo apt autoremove                            # remove orphaned dependencies
sudo apt search nmap                           # search for a package
apt show nginx                                 # detailed package info
dpkg — low-level inspection
dpkg -l                                        # list all installed packages
dpkg -l | grep nginx                           # is nginx installed?
dpkg -L nginx                                  # what files did nginx install?
dpkg -S /usr/sbin/nginx                        # which package owns this file?
sudo dpkg -i package.deb                       # install a local .deb file
Repositories
apt reads from /etc/apt/sources.list and files in /etc/apt/sources.list.d/. To add a new repository (e.g. Docker's), you add a key and a sources entry.
# Example: add the Docker repository
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt update
sudo apt install docker-ce
Pitfall — running random curl | bash
You'll see install instructions like curl https://example.com/install.sh | bash. This downloads and immediately executes a script with your shell's privileges. Always download and read the script first before piping to bash. A malicious or compromised installer can do anything.
# Safer
curl -O https://example.com/install.sh
less install.sh                  # read it
bash install.sh                  # only if you trust it
Why this matters in cloud security
Container image scanning (Trivy, Grype) works by enumerating installed packages and comparing versions against vulnerability databases. The package manager is the data source for that scan. You should be able to look at any container, run dpkg -l (or apk info -v for Alpine), and immediately see what's installed.
________________________________________
Module 2.8 — Users, Groups, and the Identity Files
Concept
A Linux user is identified by a numeric UID, a group by a numeric GID. Names like dinesh are convenience labels mapped to UIDs in /etc/passwd. Passwords (hashes, actually) live in /etc/shadow. Group memberships live in /etc/group.
By convention:
•UID 0 = root (superuser)
•UID 1–999 = system accounts (services like nginx, postgres)
•UID 1000+ = human users
The identity files
/etc/passwd
World-readable. Contains one line per user, colon-separated:
dinesh:x:1000:1000:Dinesh Sharma:/home/dinesh:/bin/bash
Fields: username, password placeholder (x = stored in shadow), UID, GID, GECOS (full name and metadata), home directory, default shell.
/etc/shadow
Root-readable only. Contains password hashes:
dinesh:$y$j9T$abc...$xyz:19752:0:99999:7:::
Fields: username, hash, last password change (days since epoch), min days between changes, max days, warning days, inactive days, expiration date, reserved.
The hash format $y$... indicates yescrypt (modern); $6$... is SHA-512 crypt; $1$... is MD5 (legacy and insecure).
/etc/group
sudo:x:27:dinesh,alice
Fields: group name, password placeholder, GID, comma-separated list of members.
User and group commands
sudo useradd -m -s /bin/bash alice              # create with home directory and bash
sudo passwd alice                                # set password
sudo usermod -aG sudo alice                      # add alice to sudo group (-a = append, -G = group)
sudo userdel -r alice                            # delete alice and her home

sudo groupadd developers
sudo gpasswd -a alice developers                 # add alice to developers group
sudo gpasswd -d alice developers                 # remove alice from developers

id                                              # who am I, what groups
id alice                                        # what groups is alice in
groups                                          # my group memberships
who                                             # who is logged in now
last                                            # login history
Sudo — controlled root access
sudo lets specified users run commands as root (or another user). Configuration lives in /etc/sudoers and /etc/sudoers.d/. Never edit these directly with a text editor — use visudo, which validates syntax before saving:
sudo visudo
A typical sudoers line:
%sudo   ALL=(ALL:ALL) ALL
Read as: members of group sudo (the % prefix), from anywhere, can run any command, as any user, including all groups.
Pitfall — locking yourself out of root
Removing your account from the sudo group while you're logged in is fine, but if you also have no root password set (the default on Ubuntu), you've now locked yourself out of admin functions. Always keep at least one verified path to root.
Why this matters in cloud security
Users, groups, and sudo policies are the on-host equivalent of cloud IAM. The principle of least privilege starts here: every service account should be a non-root user with only the permissions it needs. Container images that run as root are flagged in every security scanner — for good reason.
________________________________________
Module 2.9 — Logs and Log Inspection
Concept
Logs are the record of what happened. In cloud security, logs are evidence. You will spend a lot of your career reading logs.
Modern Linux uses two parallel logging systems:
1.systemd journal — a structured binary database, accessed via journalctl.
2.Plain text logs — files in /var/log/, written by rsyslog or applications.
journalctl — querying the systemd journal
journalctl                              # all logs
journalctl -u sshd                      # only sshd unit
journalctl -u sshd --since "1 hour ago"
journalctl -u sshd --since "2026-05-09 09:00" --until "2026-05-09 12:00"
journalctl -p err                       # priority error and above
journalctl -f                           # follow (live tail)
journalctl -k                           # kernel messages only
journalctl -b                           # since last boot
journalctl --vacuum-time=7d             # delete logs older than 7 days
Priority levels (highest to lowest):
•emerg (0), alert (1), crit (2), err (3), warning (4), notice (5), info (6), debug (7)
/var/log/ — the traditional logs
Every distribution organises this slightly differently. On Ubuntu, key files:
FileContents
/var/log/syslog General system messages
/var/log/auth.log Authentication: SSH, sudo, login
/var/log/kern.log Kernel messages
/var/log/dpkg.log Package install/remove history
/var/log/nginx/access.logWeb server access
/var/log/nginx/error.logWeb server errors
tail -f — follow a log live
tail -f /var/log/auth.log
tail -n 100 /var/log/syslog            # last 100 lines
tail -F /var/log/syslog                # like -f but handles log rotation
Combine with grep to filter:
tail -f /var/log/auth.log | grep --line-buffered "Failed"
The --line-buffered flag prevents grep from waiting until it has a full output buffer — without it, your live tail can hang for minutes between updates.
Worked example — finding SSH brute force attempts
grep "Failed password" /var/log/auth.log \
  | awk '{print $11}' \
  | sort \
  | uniq -c \
  | sort -rn \
  | head -10
This gives you the top 10 source IPs of failed SSH login attempts. If any are external and have hundreds of attempts, you've identified an active brute-force attack.
Why this matters in cloud security
This is the work of a SOC analyst. Cloud SIEMs like Sentinel and Splunk make this prettier and faster, but the queries you write in KQL or SPL are conceptually identical to what you just did with grep, awk, sort, uniq. If you can do it on a host, you can do it in the cloud.
________________________________________
Module 2.10 — Bash Scripting Essentials
Concept
A Bash script is a text file containing commands you'd type interactively, plus control flow (if/then, loops, functions). Every operations engineer eventually writes hundreds of small scripts. The skill is not the syntax — it's writing scripts that fail safely when something unexpected happens.
Anatomy of a good script
#!/usr/bin/env bash
# Description: brief explanation of what this script does
# Usage: ./scriptname.sh [arguments]

set -euo pipefail
IFS=$'\n\t'

# --- functions ---
function log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
}

# --- main ---
log "Starting..."
# your commands here
log "Done."
The header lines matter:
•#!/usr/bin/env bash — the shebang. Tells the OS to run this with bash.
•set -e — exit immediately if any command fails.
•set -u — error on undefined variables (catches typos).
•set -o pipefail — make a pipeline fail if any command in it fails (default is only the last).
•IFS=$'\n\t' — set the internal field separator to newline and tab; protects against filenames with spaces.
These four lines transform Bash from "fragile by default" to "fails loudly when something goes wrong", which is exactly what you want in operations.
Variables
name="Alice"                  # no spaces around =
echo "Hello $name"
echo "Hello ${name}"          # braces are clearer when adjacent to text
echo "Hello ${name}_admin"    # required here

today=$(date +%Y-%m-%d)       # capture command output into a variable
files=$(ls *.txt | wc -l)
Conditionals
if [[ -f /etc/passwd ]]; then
  echo "passwd file exists"
elif [[ -d /etc ]]; then
  echo "/etc is a directory"
else
  echo "neither"
fi

# String comparison
if [[ "$name" == "Alice" ]]; then
  echo "Hello Alice"
fi

# Numeric comparison
count=5
if (( count > 3 )); then
  echo "more than 3"
fi
Common test operators:
TestMeaning
-f pathregular file exists
-d pathdirectory exists
-e pathpath exists (any type)
-r pathpath is readable
-w pathpath is writable
-x pathpath is executable
-z strstring is empty
-n strstring is non-empty
str1 == str2strings equal
str1 != str2strings differ
Loops
# for over a list
for fruit in apple banana cherry; do
  echo "Fruit: $fruit"
done

# for over file glob
for file in /var/log/*.log; do
  echo "Log: $file"
done

# for over command output
for user in $(awk -F: '$3 >= 1000 {print $1}' /etc/passwd); do
  echo "User: $user"
done

# while
count=0
while (( count < 5 )); do
  echo "Count: $count"
  ((count++))
done

# until
until ping -c 1 -W 1 8.8.8.8 &>/dev/null; do
  echo "Waiting for network..."
  sleep 2
done
Functions
function greet() {
  local name="$1"           # 'local' scopes the variable to the function
  echo "Hello, $name"
  return 0                  # exit code; 0 = success
}

greet "Alice"
greet "Bob"
Arguments and exit codes
# Inside a script:
echo "Script name: $0"
echo "First arg: $1"
echo "All args: $@"
echo "Number of args: $#"
echo "Last command's exit: $?"

# Validate args
if (( $# < 1 )); then
  echo "Usage: $0 <username>" >&2
  exit 1                                  # non-zero = failure
fi

username="$1"
The convention is: exit code 0 = success, anything else = failure. Specific codes can mean specific things in your script.
Worked example — a small but real script
#!/usr/bin/env bash
# backup-home.sh — back up a user's home directory
set -euo pipefail
IFS=$'\n\t'

if (( $# != 1 )); then
  echo "Usage: $0 <username>" >&2
  exit 1
fi

USERNAME="$1"
HOME_DIR="/home/$USERNAME"
BACKUP_DIR="/var/backups"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_FILE="$BACKUP_DIR/${USERNAME}-${TIMESTAMP}.tar.gz"

if [[ ! -d "$HOME_DIR" ]]; then
  echo "Home directory $HOME_DIR does not exist" >&2
  exit 2
fi

mkdir -p "$BACKUP_DIR"
tar -czf "$BACKUP_FILE" -C /home "$USERNAME"

echo "Backed up $HOME_DIR → $BACKUP_FILE"
echo "Size: $(du -sh "$BACKUP_FILE" | cut -f1)"
This script demonstrates: argument validation, error handling, timestamped output, and clear exit codes.
Why this matters in cloud security
Half the security tooling in the world is Bash glue. Detection rules, response playbooks, IaC pipelines, audit scripts — Bash everywhere. You won't write giant systems in it, but you'll write many short, reliable scripts. Make them safe by default.
________________________________________
Week 2 Lab Exercises
The three exercises required by your study plan, with full solutions and explanation. Type these out yourself first before reading my solutions.
Lab 2.1 — scripts/audit-users.sh
Requirement: lists all users with UID >= 1000, plus their home directory, shell, and last login.
Solution:
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
Test:
chmod +x scripts/audit-users.sh
./scripts/audit-users.sh
What's happening:
1.IFS=: tells read to split on colons (the passwd file format).
2.We skip UID 65534 because that's nobody — a system placeholder, not a real user.
3.lastlog shows the last login for each user.
Lab 2.2 — scripts/listening-ports.sh
Requirement: lists all listening TCP ports with the process name and PID.
Solution:
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
Test:
sudo ./scripts/listening-ports.sh
Lab 2.3 — scripts/disk-usage.sh
Requirement: finds the 10 largest files in /home.
Solution:
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
Test:
chmod +x scripts/disk-usage.sh
./scripts/disk-usage.sh
./scripts/disk-usage.sh /var          # works on any directory
Week 2 Verification
Tick all of these:
•[ ] scripts/audit-users.sh runs cleanly, returns at least your own user.
•[ ] scripts/listening-ports.sh runs (with sudo) and shows at least sshd or systemd-resolved.
•[ ] scripts/disk-usage.sh runs and returns 10 paths.
•[ ] All three scripts have chmod +x set.
•[ ] All three scripts are pushed to your cloudsec-lab GitHub repo.
•[ ] You can explain to someone else what each set -euo pipefail flag does.
•[ ] You can decode -rwxr-xr-x permissions in your head without looking it up.
If you cannot tick all seven, repeat the relevant module before moving to Week 3.
