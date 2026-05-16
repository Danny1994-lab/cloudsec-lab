Cloud Security Foundations
A Three-Week Course Book — Linux, Networking, and Security Fundamentals
Course code: CSEC-FND-101 Duration: 3 weeks (recommended 30 hours total study) Prerequisites: General IT comfort, ability to install software Lecturer: Your textbook companion for self-study
________________________________________
Foreword from the Lecturer
Welcome. This course book accompanies the first foundation phase of your journey into cloud security engineering. Many of you are coming from a developer background, a sysadmin role, or a help-desk position, hoping to break into a more technical security career. A few of you have no IT background at all — you'll find this book demanding but achievable if you do the practicals.
Read this carefully: cloud security is not a subject you can learn by watching videos. The reason is that almost everything that goes wrong in cloud security comes down to misunderstanding one of the foundations — Linux permissions, TCP behaviour, or the difference between authentication and authorisation. If you don't internalise these properly now, you will spend the rest of your career mis-diagnosing problems and mis-designing systems.
So my expectation across these three weeks is simple: you will run every command in a real terminal, write every script, and build every diagram. The exercises are not optional. The verification checklist at the end of each week is not optional. If you cannot tick the verification boxes, you have not finished the week — repeat the exercises until you can.
I will use a few conventions throughout:
•	Concept boxes introduce a new idea in two or three sentences before we examine it in detail.
•	Worked examples show you exactly what I would type and what you would expect to see.
•	Pitfalls flag the specific places students get caught out year after year.
•	Why this matters in cloud security sections connect each concept to the real cloud engineering job.
Let's begin.
________________________________________
Table of Contents
Week 2 — Linux Fundamentals
•	Module 2.1: The Linux Philosophy and Filesystem Layout
•	Module 2.2: Navigating the Filesystem
•	Module 2.3: File Permissions, Ownership, and Special Bits
•	Module 2.4: Processes and Process Management
•	Module 2.5: Networking from the Command Line
•	Module 2.6: Text Processing and the Power of Pipes
•	Module 2.7: Package Management
•	Module 2.8: Users, Groups, and the Identity Files
•	Module 2.9: Logs and Log Inspection
•	Module 2.10: Bash Scripting Essentials
•	Week 2 Lab Exercises (with full solutions)
Week 3 — Networking Refresher
•	Module 3.1: A Mental Model of How Packets Move
•	Module 3.2: The OSI and TCP/IP Models
•	Module 3.3: IPv4 Addressing, Subnetting, and CIDR
•	Module 3.4: TCP, UDP, and the Three-Way Handshake
•	Module 3.5: The DNS Resolution Flow
•	Module 3.6: HTTPS, TLS, Certificates, and Mutual TLS
•	Module 3.7: NAT, Port Forwarding, and Reverse Proxies
•	Module 3.8: Firewalls and Access Control Lists
•	Module 3.9: VPNs and the Zero-Trust Model
•	Week 3 Lab Exercises (with full solutions)
Week 4 — Identity, Cryptography, and Threat Fundamentals
•	Module 4.1: Authentication versus Authorisation
•	Module 4.2: Multi-Factor Authentication
•	Module 4.3: Public-Key Cryptography
•	Module 4.4: Symmetric Cryptography
•	Module 4.5: Hashing and Password Storage
•	Module 4.6: Certificates, Certificate Authorities, and mTLS
•	Module 4.7: OAuth 2.0 — The Three Flows You Must Know
•	Module 4.8: OIDC versus SAML
•	Module 4.9: Threat Modelling with STRIDE
•	Module 4.10: The MITRE ATT&CK Framework
•	Week 4 Lab Exercises (with full solutions)
Capstone
•	Final integration exercise
•	Self-assessment quiz
•	Where to go next
________________________________________
WEEK 2 — LINUX FUNDAMENTALS
Lecturer's note on Week 2
Almost every cloud workload — every container, every Kubernetes pod, every serverless function, every managed database — runs on Linux underneath. AWS Lambda runs Linux. Azure Functions run Linux (or .NET on Linux). Kubernetes nodes are Linux. Every Docker container is, at its core, an isolated Linux process tree. Even Windows-shop enterprises run their security tooling on Linux because the SIEM, the EDR backends, and the analyst workstations are all Linux-based.
So for the next week, we live in a Linux terminal. Every concept you learn here is one you'll use every working day for the rest of your career.
________________________________________
Module 2.1 — The Linux Philosophy and Filesystem Layout
Concept
Linux is built on a philosophy — articulated by Doug McIlroy in the early 1970s — that programs should do one thing well, work together using text streams, and treat the filesystem as a universal interface. This is why a single line like ps aux | grep nginx | awk '{print $2}' | xargs kill works: each tool does one job, and pipes glue them together.
The filesystem is hierarchical and starts at / (the root). Everything — including hardware devices, running processes, kernel parameters, and network interfaces — appears as a file or directory somewhere under /. This is the everything is a file principle, and it's why Linux is such a powerful platform for automation.
The standard directories
Open a terminal and run ls /. You'll see something like:
bin   boot  dev  etc  home  lib  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
You don't need to memorise every directory, but understand the important ones:
Path	Purpose	Why it matters
/etc	System configuration files	Where every service stores its config; first place to look when something breaks
/var/log	Log files	First place to look when investigating an incident
/home	User home directories	Personal files, SSH keys, shell history
/tmp	Temporary files	World-writable; security risk if used for persistent data
/proc	Virtual filesystem of running processes	/proc/<PID>/cmdline shows what a process is running
/sys	Virtual filesystem of kernel/devices	Used to read or change kernel runtime parameters
/usr/bin	Standard user binaries	Where most installed programs live
/usr/local/bin	Locally-installed software	Where you put your own scripts and tools
/opt	Third-party software	Where vendors install standalone applications
/dev	Device files	/dev/null is the void; /dev/random is randomness
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
•	- regular file
•	d directory
•	l symbolic link
•	c character device (e.g. /dev/tty)
•	b block device (e.g. /dev/sda)
•	p named pipe
•	s socket
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
Position	Value	Meaning
1	-	Regular file
2-4	rw-	Owner (root) can read and write
5-7	r--	Group (shadow) can read
8-10	---	Everyone else: nothing
This is exactly right for /etc/shadow — the file containing password hashes. If you ever see it as -rw-r--r--, you have a critical security problem.
Numeric (octal) notation
Each permission triplet is a binary number:
Symbolic	Binary	Octal
---	000	0
--x	001	1
-w-	010	2
-wx	011	3
r--	100	4
r-x	101	5
rw-	110	6
rwx	111	7
So chmod 755 file means owner=rwx, group=rx, other=rx. chmod 600 means owner=rw, nobody else can do anything. Memorise the common ones:
•	644 — typical regular file (owner can write, others can read)
•	755 — typical script or directory (owner can write, others can read and execute)
•	600 — sensitive file like an SSH private key
•	700 — sensitive directory like ~/.ssh
•	777 — danger sign; everyone can do everything
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
1.	Almost certainly creates a security hole.
2.	Doesn't even fix the actual problem most of the time.
3.	Is a giant red flag in code review.
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
ps aux columns: USER, PID, %CPU, %MEM, VSZ (v irtual size), RSS (resident size), TTY, STAT, START, TIME, COMMAND.
The STAT column is worth knowing:
•	R running
•	S sleeping (waiting for something, normal)
•	D uninterruptible sleep (usually waiting for I/O — a stuck D is bad)
•	Z zombie (dead but not reaped)
•	T stopped (e.g. by Ctrl+Z)
Common patterns:
ps aux | grep nginx                 # find nginx processes
ps -ef --forest                     # show parent-child tree
ps -p 1234 -o pid,user,cmd          # specific PID, specific columns
top — live process monitor
top
Inside top, press:
•	M to sort by memory
•	P to sort by CPU
•	1 to show all CPU cores
•	k then PID to kill a process
•	q to quit
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
•	t TCP
•	u UDP
•	l listening sockets only
•	n numeric (don't resolve names — much faster)
•	p show the owning process (needs root for other users' processes)
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
1.	awk extracts the first column (the source IP).
2.	sort so identical IPs become adjacent.
3.	uniq -c collapses duplicates and adds counts.
4.	sort -rn sorts by count, descending.
5.	head -10 takes the top 10.
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
•	UID 0 = root (superuser)
•	UID 1–999 = system accounts (services like nginx, postgres)
•	UID 1000+ = human users
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
1.	systemd journal — a structured binary database, accessed via journalctl.
2.	Plain text logs — files in /var/log/, written by rsyslog or applications.
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
•	emerg (0), alert (1), crit (2), err (3), warning (4), notice (5), info (6), debug (7)
/var/log/ — the traditional logs
Every distribution organises this slightly differently. On Ubuntu, key files:
File	Contents
/var/log/syslog	General system messages
/var/log/auth.log	Authentication: SSH, sudo, login
/var/log/kern.log	Kernel messages
/var/log/dpkg.log	Package install/remove history
/var/log/nginx/access.log	Web server access
/var/log/nginx/error.log	Web server errors
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
•	#!/usr/bin/env bash — the shebang. Tells the OS to run this with bash.
•	set -e — exit immediately if any command fails.
•	set -u — error on undefined variables (catches typos).
•	set -o pipefail — make a pipeline fail if any command in it fails (default is only the last).
•	IFS=$'\n\t' — set the internal field separator to newline and tab; protects against filenames with spaces.
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
Test	Meaning
-f path	regular file exists
-d path	directory exists
-e path	path exists (any type)
-r path	path is readable
-w path	path is writable
-x path	path is executable
-z str	string is empty
-n str	string is non-empty
str1 == str2	strings equal
str1 != str2	strings differ
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
1.	IFS=: tells read to split on colons (the passwd file format).
2.	We skip UID 65534 because that's nobody — a system placeholder, not a real user.
3.	lastlog shows the last login for each user.
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
•	[ ] scripts/audit-users.sh runs cleanly, returns at least your own user.
•	[ ] scripts/listening-ports.sh runs (with sudo) and shows at least sshd or systemd-resolved.
•	[ ] scripts/disk-usage.sh runs and returns 10 paths.
•	[ ] All three scripts have chmod +x set.
•	[ ] All three scripts are pushed to your cloudsec-lab GitHub repo.
•	[ ] You can explain to someone else what each set -euo pipefail flag does.
•	[ ] You can decode -rwxr-xr-x permissions in your head without looking it up.
If you cannot tick all seven, repeat the relevant module before moving to Week 3.
________________________________________
WEEK 3 — NETWORKING REFRESHER
Lecturer's note on Week 3
Cloud security is networking security. Every cloud control — security groups, network policies, WAF rules, private endpoints, service meshes — is a way of controlling where packets are allowed to go. Engineers who understand networking become senior cloud security engineers; engineers who don't stay junior forever, no matter how many certifications they collect.
This week we revisit (or learn for the first time) the underlying mental model. We will not get bogged down in protocol minutiae. We will learn just enough to be dangerous: how packets actually move, why TLS is what it is, how DNS really resolves, and the difference between a stateful and stateless firewall.
________________________________________
Module 3.1 — A Mental Model of How Packets Move
Concept
When you type https://example.com and press Enter, the following happens, in order:
1.	Your browser asks the OS to resolve example.com to an IP. The OS asks DNS.
2.	DNS returns an IP, say 93.184.216.34.
3.	Your browser opens a TCP connection to that IP on port 443.
4.	The TCP three-way handshake completes.
5.	A TLS handshake negotiates encryption.
6.	Inside the encrypted tunnel, the browser sends an HTTP GET / request.
7.	The server returns HTML.
8.	The browser parses the HTML and repeats steps 1–7 for every image, script, and stylesheet referenced.
If you can describe this flow without notes, you have a working mental model. Everything else this week sharpens specific parts of it.
________________________________________
Module 3.2 — The OSI and TCP/IP Models
The OSI model — seven layers
Layer	Name	Examples
7	Application	HTTP, DNS, SSH
6	Presentation	TLS encryption, JPEG encoding
5	Session	RPC session management
4	Transport	TCP, UDP
3	Network	IP, ICMP, routing
2	Data Link	Ethernet, Wi-Fi MAC frames
1	Physical	Copper, fibre, radio
In practice, security engineers focus on layers 3 (IP), 4 (TCP/UDP), and 7 (application). Layers 1 and 2 matter for on-prem networking but are abstracted away in cloud.
The TCP/IP model collapses these into four practical layers — Link, Internet, Transport, Application — but the OSI numbering is what people use in conversation. When someone says "layer 7 firewall", they mean it inspects HTTP requests, not just IP addresses.
Pitfall — the OSI model is not literally how networks work
The OSI model is an abstraction invented after most actual protocols already existed. Real protocols don't always fit cleanly into one layer (TLS spans 5–6, QUIC spans 4–6, etc.). Use OSI to communicate with other engineers, not as a literal description of any specific protocol.
________________________________________
Module 3.3 — IPv4 Addressing, Subnetting, and CIDR
Concept
An IPv4 address is 32 bits, conventionally written as four decimal numbers (each 0–255) separated by dots: 10.20.30.40. A subnet is a contiguous range of addresses defined by a mask — a number indicating how many leading bits are fixed.
CIDR (Classless Inter-Domain Routing) notation writes this as address/prefix-length. So 10.20.30.0/24 means: the first 24 bits are the network identifier, the last 8 bits identify hosts within it. That's 256 addresses total, of which 254 are usable (one is the network address, one is the broadcast).
The CIDR table you must memorise
CIDR	Mask	# Addresses	Usable	Common use
/32	255.255.255.255	1	1	Single host
/31	255.255.255.254	2	2	Point-to-point links
/30	255.255.255.252	4	2	Tiny links
/29	255.255.255.248	8	6	Small subnets
/28	255.255.255.240	16	14	
/27	255.255.255.224	32	30	
/26	255.255.255.192	64	62	
/25	255.255.255.128	128	126	
/24	255.255.255.0	256	254	Typical small subnet
/23	255.255.254.0	512	510	
/22	255.255.252.0	1,024	1,022	
/21	255.255.248.0	2,048	2,046	
/20	255.255.240.0	4,096	4,094	Medium subnets
/19	255.255.224.0	8,192	8,190	
/18	255.255.192.0	16,384	16,382	
/17	255.255.128.0	32,768	32,766	
/16	255.255.0.0	65,536	65,534	Large VPC
/8	255.0.0.0	16,777,216	—	Whole RFC1918 block
The pattern: every step down doubles the size. /24 is 256, /23 is 512, /22 is 1024, etc. Memorise the powers of two and you can derive any of these in your head.
Subnetting practice — example
Take 10.0.0.0/22. That's 2^(32-22) = 2^10 = 1024 addresses, range 10.0.0.0 to 10.0.3.255.
To split it into four /24 subnets:
Subnet	Range
10.0.0.0/24	10.0.0.0 – 10.0.0.255
10.0.1.0/24	10.0.1.0 – 10.0.1.255
10.0.2.0/24	10.0.2.0 – 10.0.2.255
10.0.3.0/24	10.0.3.0 – 10.0.3.255
Private (RFC 1918) address ranges
These three ranges are reserved for private networks; they never appear on the public internet:
•	10.0.0.0/8 (10.0.0.0 – 10.255.255.255)
•	172.16.0.0/12 (172.16.0.0 – 172.31.255.255)
•	192.168.0.0/16 (192.168.0.0 – 192.168.255.255)
Every cloud VPC/VNet uses these ranges. AWS default VPC: 172.31.0.0/16. Azure typical: 10.0.0.0/16.
Why this matters in cloud security
Misunderstood CIDR ranges are a top cause of cloud network-rule bugs. A security group that allows 10.0.0.0/16 instead of 10.0.0.0/24 is opening 256× more addresses than intended. A peering between two VNets that overlap on 10.0.0.0/24 will not work at all. Mental fluency in CIDR makes you faster and safer.
________________________________________
Module 3.4 — TCP, UDP, and the Three-Way Handshake
TCP versus UDP
Feature	TCP	UDP
Connection-oriented	Yes	No
Reliable delivery	Yes (retransmits)	No
Ordering	Yes	No
Header size	20+ bytes	8 bytes
Use cases	HTTP, SSH, databases	DNS, video streaming, VoIP, gaming
TCP is the careful, polite protocol. UDP is the fast, lossy protocol. HTTP/3 (the latest version of HTTP) is built on UDP for speed but rebuilds reliability on top — that's QUIC.
The TCP three-way handshake
When you open a TCP connection:
Client                                    Server
   |  ----- SYN, seq=x ----->             |
   |  <--- SYN-ACK, seq=y, ack=x+1 ---    |
   |  ----- ACK, ack=y+1 ----->           |
   |                                      |
   |   <===== connection open ======>     |
1.	SYN (synchronise) — client says "I want to talk; here's my starting sequence number."
2.	SYN-ACK — server says "OK; here's my starting sequence number, and I acknowledge yours."
3.	ACK — client says "I acknowledge yours."
After this, both sides have agreed on sequence numbers and can send data reliably. Three packets, six in total to establish and tear down a connection. This is why high-throughput services often pool connections rather than open new ones.
Common ports
Memorise these — they appear in every interview and every firewall rule.
Port	Protocol	Service
22	TCP	SSH
25	TCP	SMTP
53	TCP/UDP	DNS
80	TCP	HTTP
443	TCP	HTTPS
110	TCP	POP3
143	TCP	IMAP
3306	TCP	MySQL
5432	TCP	PostgreSQL
6379	TCP	Redis
27017	TCP	MongoDB
1433	TCP	MSSQL
3389	TCP	RDP
9200	TCP	Elasticsearch
8080	TCP	HTTP alternate (often dev)
Why this matters in cloud security
Cloud security groups and NSGs are written in terms of protocols and ports. A rule that allows TCP/22 from 0.0.0.0/0 is SSH open to the entire internet — a very common audit finding. A rule that allows UDP/53 to a managed DNS endpoint is fine. Knowing the protocol-port pairs for common services lets you read a rule and immediately know if it's safe.
________________________________________
Module 3.5 — The DNS Resolution Flow
Concept
DNS turns names into addresses. It does this through a hierarchical, distributed database. The resolution of www.example.com works like this:
1.	Your computer asks its resolver (often the ISP's, or 8.8.8.8 / 1.1.1.1) for the IP of www.example.com.
2.	The resolver checks its cache. If found, return it. If not:
3.	The resolver asks a root server (one of 13): "where do I find .com?"
4.	The root server responds with the IPs of the .com TLD servers.
5.	The resolver asks a .com server: "where do I find example.com?"
6.	The TLD server responds with the IPs of example.com's authoritative nameservers.
7.	The resolver asks an authoritative server: "what is the IP of www.example.com?"
8.	The authoritative server returns the answer.
9.	The resolver caches the answer (for the duration of its TTL) and returns it to your computer.
That entire flow happens in tens to hundreds of milliseconds.
Common record types
Type	Purpose	Example
A	IPv4 address	93.184.216.34
AAAA	IPv6 address	2606:2800:220:1:248:1893:25c8:1946
CNAME	Alias to another name	www → example.com
MX	Mail server for the domain	mail.example.com
TXT	Free-text record	SPF, DKIM, domain verification
NS	Authoritative nameserver	ns1.example.com
SOA	Start of authority (zone metadata)	
SRV	Service location (port + host)	_sip._tcp.example.com
Worked example — tracing a DNS lookup
dig +trace microsoft.com
Read the output top to bottom: it walks from the root, down to .com, down to Microsoft's nameservers, and finally returns A records. This single command teaches DNS better than any video.
Why this matters in cloud security
DNS is an attack vector and a defensive control:
•	DNS hijacking — attackers compromise registrar accounts to point your domain elsewhere. Defended by registrar lock and DNSSEC.
•	DNS exfiltration — malware encodes stolen data into DNS queries to bypass firewalls.
•	DNS sinkholing — defenders point malicious domains to a controlled IP, stopping malware callbacks.
•	DNS over HTTPS (DoH) — encrypts queries; helps users but blinds defenders.
________________________________________
Module 3.6 — HTTPS, TLS, Certificates, and Mutual TLS
Concept
HTTPS is HTTP over TLS. TLS provides three guarantees:
1.	Confidentiality — nobody can read the traffic.
2.	Integrity — nobody can change the traffic without detection.
3.	Authentication — you're talking to the real server (and optionally, the server knows it's talking to the real you).
The TLS 1.3 handshake (simplified)
Client                                   Server
   |  ----- ClientHello ------->          |
   |    (supported ciphers, key share)    |
   |                                      |
   |  <---- ServerHello ------------      |
   |    (chosen cipher, key share,        |
   |     server certificate, signature)   |
   |                                      |
   |  ----- Finished -------->            |
   |  <---- Finished --------              |
   |                                      |
   |  <==== encrypted application ====>   |
In TLS 1.3 (the current standard), the handshake completes in a single round trip. The client and server each contribute to a shared secret using Diffie-Hellman key exchange; the server proves its identity by signing the handshake with the private key corresponding to its certificate.
Certificates in 30 seconds
A certificate is a public key plus metadata, signed by a Certificate Authority (CA). Your browser trusts a list of root CAs (Microsoft, Let's Encrypt, DigiCert, etc.) shipped with the OS. When a server presents a certificate, your browser checks:
1.	Is it signed by a trusted CA (or by an intermediate signed by one)?
2.	Is the name in the certificate (CN or SAN) the same as the hostname you typed?
3.	Is the certificate within its validity period?
4.	Has it been revoked (CRL/OCSP)?
If all four pass, the connection is trusted.
Mutual TLS (mTLS)
Normal TLS authenticates only the server. Mutual TLS authenticates both sides — the client also presents a certificate. This is the foundation of zero-trust service-to-service communication and is built into service meshes like Istio and Linkerd.
Worked example — inspect a real TLS handshake
curl -v https://github.com 2>&1 | grep -E "^\*"
You'll see lines like:
*  SSL connection using TLSv1.3 / TLS_AES_256_GCM_SHA384
*  Server certificate:
*   subject: CN=github.com
*   issuer: CN=Sectigo ECC Domain Validation Secure Server CA
*   start date: ...
*   expire date: ...
*   SSL certificate verify ok.
That's TLS 1.3, AES-256 GCM cipher, signed by Sectigo, valid.
Why this matters in cloud security
Almost every breach response and architecture review involves a TLS question. "Why isn't my private endpoint working?" → certificate issue. "Why does my browser say insecure?" → name mismatch or expired cert. "How do we secure service-to-service traffic in our cluster?" → mTLS via service mesh. Fluency here is non-optional.
________________________________________
Module 3.7 — NAT, Port Forwarding, and Reverse Proxies
NAT — Network Address Translation
NAT lets many private addresses share a single public address. Every home router does this; every cloud NAT Gateway does this for outbound traffic from private subnets.
When your laptop at 192.168.1.42 requests example.com:
1.	The router rewrites the source from 192.168.1.42:54321 to 1.2.3.4:54321.
2.	Stores a mapping: 1.2.3.4:54321 → 192.168.1.42:54321.
3.	When the response comes back to 1.2.3.4:54321, the router looks up the mapping and forwards to 192.168.1.42:54321.
Port forwarding
The inverse of NAT: a public-facing port on the router maps to a specific internal host. Used to expose internal services. Common in home labs ("forward port 22222 to my Raspberry Pi"). Less common in cloud — replaced by load balancers and reverse proxies.
Reverse proxies
A reverse proxy sits in front of one or more application servers, accepting requests on their behalf and forwarding them. Examples: nginx, Apache, HAProxy, Traefik, AWS ALB, Azure Application Gateway, Cloudflare.
Reverse proxies do many jobs:
•	TLS termination (decrypt incoming HTTPS, forward plain HTTP internally)
•	Load balancing across backend instances
•	Caching
•	Rate limiting
•	Web Application Firewall (WAF) rules
•	Routing (different paths to different backends)
•	Authentication (e.g. enforce OIDC at the proxy)
Why this matters in cloud security
You'll spend half your career configuring reverse proxies and the WAF rules in front of them. Understanding what a reverse proxy is — that the client never talks directly to the application — explains why security controls live there: it's the chokepoint where you can see and control all traffic.
________________________________________
Module 3.8 — Firewalls and Access Control Lists
Stateful versus stateless
Stateful	Stateless
Tracks connection state	Treats each packet in isolation
Allows return traffic for established connections automatically	Requires explicit rules for both directions
More memory, more CPU	Faster, cheaper
Examples: iptables (default), AWS Security Groups, Azure NSGs (mostly)	AWS Network ACLs, classic ACLs
In practice, stateful firewalls are easier to configure and the standard for hosts and most cloud security groups. Stateless ACLs are used at network boundaries for a defence-in-depth layer.
Rule evaluation
Cloud firewall rules typically evaluate in priority order, with explicit allows or denies. Most cloud security groups are default-deny — if no rule allows the traffic, it's blocked.
A typical rule has:
•	Direction (inbound, outbound)
•	Protocol (TCP, UDP, ICMP, any)
•	Source (IP, CIDR, security group, tag)
•	Destination port
•	Action (allow, deny)
Worked example — typical web server inbound rules
Priority	Direction	Protocol	Source	Port	Action
100	In	TCP	0.0.0.0/0	443	Allow
110	In	TCP	0.0.0.0/0	80	Allow (for redirect to 443)
120	In	TCP	10.0.0.0/16	22	Allow (SSH from internal only)
65000	In	Any	Any	Any	Deny (default)
Pitfall — overlapping or contradictory rules
When rules overlap, evaluation order matters. A deny at priority 100 will block traffic that a later allow at priority 200 would otherwise permit. Always test rules with a tool like nmap from outside, or nc -vz host port from a designated source.
________________________________________
Module 3.9 — VPNs and the Zero-Trust Model
VPN concepts
A VPN (Virtual Private Network) creates an encrypted tunnel between two endpoints, making them appear to be on the same private network.
•	Site-to-site — two networks (e.g. your office and your AWS VPC) joined by a permanent tunnel. Usually IPsec.
•	Client-to-site (remote access) — a single user's laptop joining a network. IPsec, OpenVPN, WireGuard.
•	WireGuard — modern, fast, simple-to-configure VPN. Increasingly the default for new deployments.
•	IPsec — older, more complex, but ubiquitous in enterprise.
Zero-trust networking
The zero-trust model says: never trust, always verify. The network perimeter is no longer the security boundary; identity is. Every request to every service is authenticated and authorised on its own merits, regardless of source network.
Key principles:
1.	Authenticate every connection (mTLS, OAuth tokens).
2.	Authorise based on identity and context (user, device, location, time).
3.	Assume breach — design as if the network is already compromised.
4.	Continuously verify — sessions can be revoked at any time.
Practical implementations: Google BeyondCorp, Cloudflare Access, Tailscale, AWS Verified Access.
Why this matters in cloud security
The shift from "perimeter firewalls" to "zero trust" is the biggest architectural change in enterprise security in 20 years. Every role you'll interview for in 2026 expects you to talk fluently about this transition.
________________________________________
Week 3 Lab Exercises
Lab 3.1 — Subnet 10.20.0.0/16
Requirement: subnet 10.20.0.0/16 into a /20 for prod, /20 for dev, and four /24s for management.
Solution (commit to notes/subnetting.md):
# Subnetting plan: 10.20.0.0/16

The /16 gives us 65,536 addresses (10.20.0.0 – 10.20.255.255).

| Purpose | CIDR | Range | # Addresses |
|---|---|---|---|
| Prod  | 10.20.0.0/20  | 10.20.0.0 – 10.20.15.255  | 4,096 |
| Dev   | 10.20.16.0/20 | 10.20.16.0 – 10.20.31.255 | 4,096 |
| Mgmt-1 | 10.20.32.0/24 | 10.20.32.0 – 10.20.32.255 | 256 |
| Mgmt-2 | 10.20.33.0/24 | 10.20.33.0 – 10.20.33.255 | 256 |
| Mgmt-3 | 10.20.34.0/24 | 10.20.34.0 – 10.20.34.255 | 256 |
| Mgmt-4 | 10.20.35.0/24 | 10.20.35.0 – 10.20.35.255 | 256 |

Total used: 9,216 of 65,536. Remaining 10.20.36.0 – 10.20.255.255 reserved for growth.
The maths: a /20 is 4,096 addresses, so the second /20 starts 4,096 addresses after the first — at 10.20.16.0 (because 16 × 256 = 4,096).
Lab 3.2 — Trace microsoft.com resolution
Solution:
dig +trace microsoft.com > notes/dig-trace-microsoft.txt
In notes/dns-trace.md, document the chain:
# DNS resolution chain for microsoft.com

1. Root servers (a.root-servers.net to m.root-servers.net) returned NS records for `.com`
2. `.com` TLD servers (a.gtld-servers.net etc.) returned NS records for microsoft.com:
   - ns1-39.azure-dns.com
   - ns2-39.azure-dns.net
   - ns3-39.azure-dns.org
   - ns4-39.azure-dns.info
3. The Azure DNS authoritative servers returned A records:
   - 20.70.246.20
   - (and others — see the trace output)

TXT records (SPF and verification) retrieved with:
   dig microsoft.com TXT +short
Lab 3.3 — Annotate a TLS handshake
Solution:
curl -v https://github.com 2>&1 | tee notes/curl-github-raw.txt
In notes/tls-handshake.md, annotate each meaningful line:
# Annotated TLS handshake to github.com

* Connected to github.com (140.82.112.3) port 443
  → TCP three-way handshake completed; we have a transport connection.

* ALPN, offering h2
  → "Application-Layer Protocol Negotiation" — we want HTTP/2 if the server supports it.

* SSL connection using TLSv1.3 / TLS_AES_256_GCM_SHA384
  → Negotiated TLS 1.3 with AES-256-GCM cipher and SHA-384 hash. Strong.

* Server certificate:
*   subject: CN=github.com
  → The cert claims to belong to github.com (matches what we asked for).
*   issuer: C=GB; O=Sectigo Limited; CN=Sectigo ECC Domain Validation Secure Server CA
  → Signed by a Sectigo intermediate CA, which is in our root store.
*   start date: ...
*   expire date: ...
  → Certificate is currently valid.
*   SSL certificate verify ok.
  → Full chain verified successfully.

* Using HTTP2, server supports multiplexing
  → After the TLS handshake, we upgraded to HTTP/2.

> GET / HTTP/2
  → First HTTP/2 request inside the encrypted tunnel.

< HTTP/2 200
  → Server responded 200 OK.
Week 3 Verification
•	[ ] notes/subnetting.md contains the table above.
•	[ ] notes/dns-trace.md documents the resolution chain.
•	[ ] notes/tls-handshake.md annotates each meaningful line.
•	[ ] You can subnet 10.0.0.0/16 into 8 equal subnets in your head (each /19).
•	[ ] You can describe the difference between TCP and UDP in 30 seconds.
•	[ ] You can explain DNS resolution from root server to A record without notes.
________________________________________
WEEK 4 — IDENTITY, CRYPTOGRAPHY, AND THREAT FUNDAMENTALS
Lecturer's note on Week 4
This week is the most conceptually dense of the three. We move from concrete commands and tools to abstract building blocks — the maths and protocols that make the whole edifice of security stand up.
Don't memorise. Understand. The specific commands change every five years; the underlying ideas (authentication, cryptography, threat modelling) have been stable for decades and will outlast every product currently on the market.
________________________________________
Module 4.1 — Authentication versus Authorisation
Concept
These two are constantly confused.
•	Authentication (AuthN) answers: who are you? It establishes identity.
•	Authorisation (AuthZ) answers: what are you allowed to do? It applies policy to identity.
You log into Azure → that's authentication. Azure then checks whether your role allows you to delete a Storage Account → that's authorisation.
The classic mnemonic: AuthN before AuthZ. You can't decide what someone can do until you know who they are.
Why this matters
Many famous breaches came down to authorisation bugs after correct authentication: Capital One (2019, SSRF leading to over-permissive IAM role); Snowflake customer breaches (2024, MFA missing on legitimate accounts); the long history of "horizontal privilege escalation" in web apps (a logged-in user accessing another user's data because the app didn't check authorisation per-resource).
When you review a system, ask both questions separately:
1.	How is identity established?
2.	How is policy applied to that identity, on every action?
________________________________________
Module 4.2 — Multi-Factor Authentication
Concept
Authentication factors fall into three categories:
•	Something you know — password, PIN
•	Something you have — phone, hardware token, security key
•	Something you are — fingerprint, face
True multi-factor authentication uses two from different categories. Two passwords is not MFA. A password plus a code from your phone (something you know + something you have) is.
MFA methods, ranked by strength
Method	Strength	Notes
FIDO2 / WebAuthn (security keys)	Strongest	Phishing-resistant; cryptographically tied to the domain
Push notification with number matching	Strong	Resists basic MFA fatigue attacks
TOTP (Google Authenticator, Authy)	Strong	Vulnerable to real-time phishing
Push notification (no number matching)	Medium	Vulnerable to MFA fatigue ("press accept until they cave")
SMS	Weak	Vulnerable to SIM swap; in-transit readable
Email	Very weak	Inbox compromise = MFA bypass
Why SMS is weakest
SIM swap attacks: an attacker convinces your mobile carrier to port your number to their SIM, then receives all your codes. This has been used in dozens of high-profile crypto thefts. Most large enterprises have moved off SMS for any privileged account.
TOTP — how it works
TOTP (Time-based One-Time Password) generates a 6-digit code that changes every 30 seconds. The shared secret is established once during setup (the QR code you scan). The code is HMAC-SHA1(secret, current_30s_window) truncated to 6 digits. No network call needed once set up — purely a local calculation.
FIDO2 — why it's special
FIDO2 keys (YubiKey, Titan, Apple Touch ID, Windows Hello) sign a challenge from the server with a private key that never leaves the device. The signature is bound to the domain of the requesting site. This makes FIDO2 phishing-resistant — even if you click a phishing link, the key won't sign because the domain is wrong.
Why this matters in cloud security
Conditional Access policies in Azure and equivalents in AWS / Okta let you require specific MFA methods for specific actions. A typical mature posture: SMS only for low-risk accounts (none in practice), TOTP for normal users, FIDO2 mandatory for any privileged role.
________________________________________
Module 4.3 — Public-Key Cryptography
Concept
Public-key cryptography uses two mathematically related keys: a public key that you share, and a private key that you keep secret. Anything encrypted with one can only be decrypted with the other. This solves a problem that symmetric crypto can't: secure communication between parties who have never met.
The algorithms
Algorithm	Type	Notes
RSA	Encryption + signing	Old workhorse; secure with 2048+ bit keys
ECDSA	Signing	Faster, smaller keys than RSA
Ed25519	Signing	Modern preferred for SSH and signing
ECDH	Key exchange	The "Diffie-Hellman" part of TLS
How it's actually used
Pure asymmetric encryption is too slow for bulk data. Real systems use hybrid encryption:
1.	Generate a fresh random symmetric key (AES, say).
2.	Encrypt the data with that symmetric key (fast).
3.	Encrypt the symmetric key with the recipient's public key (slow but only on small data).
4.	Send both.
The recipient decrypts the symmetric key with their private key, then decrypts the data. This is what TLS does, what GPG does, what every modern encrypted message protocol does.
Worked example — generate keys and verify a signature
# Generate an RSA key pair
openssl genrsa -out private.pem 2048
openssl rsa -in private.pem -pubout -out public.pem

# Sign a message
echo "Hello, world" > message.txt
openssl dgst -sha256 -sign private.pem -out signature.bin message.txt

# Verify
openssl dgst -sha256 -verify public.pem -signature signature.bin message.txt
# Output: Verified OK
If you change one byte of message.txt, the verification fails. This is the integrity guarantee.
Why this matters in cloud security
Every TLS connection, every SSH login, every JWT, every cloud API request signed by an SDK uses public-key crypto under the hood. KMS, Key Vault, and HSMs are managed services for the private keys. You don't need to implement the maths, but you must understand the model.
________________________________________
Module 4.4 — Symmetric Cryptography
Concept
Symmetric crypto uses a single shared key for encryption and decryption. It's much faster than asymmetric but has the key distribution problem: how do both parties get the key without an attacker intercepting it? (Answer: use asymmetric crypto to exchange the symmetric key — see Module 4.3.)
The algorithms
•	AES (Advanced Encryption Standard) — the modern standard. Three key sizes: 128, 192, 256 bits.
•	ChaCha20 — modern alternative, faster on hardware without AES instructions (e.g. mobile).
•	DES, 3DES, RC4 — legacy. Do not use.
Modes of operation
A block cipher like AES encrypts fixed-size blocks. The "mode of operation" defines how blocks chain together. The mode matters more than the algorithm choice.
Mode	Notes
AES-GCM	Modern preferred. Provides confidentiality AND authentication (AEAD).
AES-CBC	Older. Confidentiality only. Vulnerable to padding oracle attacks if used naively.
AES-ECB	Never use. Identical plaintext blocks produce identical ciphertext. The famous "ECB penguin" demonstrates this.
AES-CTR	Used for streaming. Often combined with HMAC for authentication.
AEAD — authenticated encryption
GCM and other AEAD modes (Authenticated Encryption with Associated Data) give you two guarantees in one operation:
1.	The ciphertext can't be decrypted without the key (confidentiality).
2.	The ciphertext can't be modified without detection (authentication / integrity).
Without AEAD, you have to run the cipher and a separate MAC (HMAC) and remember to validate both correctly. Engineers get this wrong constantly. AEAD makes the right behaviour the default.
Why this matters in cloud security
When you choose a KMS key, configure a customer-managed key in Azure Storage, or set TLS cipher suites, you're picking symmetric algorithms and modes. Knowing GCM > CBC > ECB lets you spot insecure configurations in seconds.
________________________________________
Module 4.5 — Hashing and Password Storage
Concept
A hash function takes input of any length and produces a fixed-size output. Cryptographic hashes are:
•	Deterministic — same input always produces same output.
•	Fast to compute (most algorithms).
•	Irreversible — given the output, you cannot derive the input.
•	Collision-resistant — finding two inputs with the same output is computationally infeasible.
Common hash functions
•	SHA-256, SHA-512 — current general-purpose standards.
•	SHA-3 — newer, designed differently to SHA-2; fine to use, less common.
•	MD5, SHA-1 — broken. Do not use for security. Still acceptable for non-security checksums.
Password hashing is different
For passwords specifically, you do not use SHA-256. You use a password hashing function designed to be slow and memory-hard, so brute-forcing is expensive even with GPUs.
Function	Notes
Argon2	Current best practice. Argon2id variant.
bcrypt	Old but solid. Still acceptable.
scrypt	Memory-hard alternative.
PBKDF2	Acceptable; less resistant to GPU attacks than the above.
Always salt passwords — add random per-user data before hashing, so two users with the same password get different hashes. Modern functions handle salting automatically.
Worked example
# SHA-256 of a string
echo -n "hello" | sha256sum
# 2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824 -

# Modern password hash with Argon2 (install argon2 first: sudo apt install argon2)
echo -n "mypassword" | argon2 saltsaltsalt -id -t 3 -m 12 -p 1
# Output: $argon2id$v=19$m=4096,t=3,p=1$c2FsdHNhbHRzYWx0$...
Why this matters in cloud security
When you review a custom application's authentication, the first question is: how are passwords hashed? If the answer is "we MD5 them" or "we SHA-256 them with no salt", you have a critical finding. Cloud-native auth (Entra ID, Cognito, Auth0) handles this for you, which is one reason to prefer it over rolling your own.
________________________________________
Module 4.6 — Certificates, Certificate Authorities, and mTLS
Concept
A certificate is a public key plus identity metadata (CN, SANs, validity dates, issuer), signed by a CA's private key. The CA's certificate, in turn, is either signed by another CA (an intermediate) or is a self-signed root.
The chain of trust
Root CA (self-signed, in your OS trust store)
   └── Intermediate CA (signed by root)
         └── Server certificate (signed by intermediate)
When a server sends its certificate, it usually sends the intermediates too. Your client validates the chain back to a trusted root. If any link is missing or untrusted, validation fails.
Common ways certificates fail
•	Expired — past the notAfter date.
•	Hostname mismatch — the cert is for example.com but you connected to www.example.com (and there's no SAN).
•	Untrusted issuer — self-signed cert presented to a strict client.
•	Revoked — the CA has marked the cert as no longer valid via CRL or OCSP.
•	Weak signature — SHA-1 signed certs are no longer trusted by modern browsers.
Mutual TLS (mTLS) — both sides authenticate
In mTLS, the client also presents a certificate. The server validates it against its own trust store. This is how:
•	Service meshes secure pod-to-pod traffic (Istio, Linkerd).
•	Banking APIs authenticate corporate clients.
•	Zero-trust network access works at scale.
Worked example — see a server's certificate
echo | openssl s_client -connect github.com:443 -servername github.com 2>/dev/null \
  | openssl x509 -noout -subject -issuer -dates
Output:
subject= CN=github.com
issuer= C=GB, O=Sectigo Limited, CN=Sectigo ECC Domain Validation Secure Server CA
notBefore=Mar  7 00:00:00 2025 GMT
notAfter=Mar  6 23:59:59 2026 GMT
Why this matters in cloud security
Certificate management is a job category in itself. Certificate expiry is the #1 cause of "the website went down" incidents — Microsoft, AWS, Spotify, and every major site has had public outages because someone forgot to renew. Cloud platforms like Let's Encrypt and ACM solve this with automation. Use them.
________________________________________
Module 4.7 — OAuth 2.0 — The Three Flows You Must Know
Concept
OAuth 2.0 is an authorisation framework. It lets a user grant a third-party application limited access to their resources without sharing their password. "Sign in with Google" uses OAuth.
Three flows you must know cold:
1. Authorisation Code Flow (with PKCE)
The standard flow for web and mobile apps.
1. App redirects user to Auth Server with: client_id, redirect_uri, scope, code_challenge
2. User authenticates and consents
3. Auth Server redirects back to App with: authorization_code
4. App exchanges code for: access_token + refresh_token (using code_verifier)
5. App uses access_token to call APIs
PKCE (Proof Key for Code Exchange, pronounced "pixie") protects against the authorisation code being stolen mid-flow. Always use it.
2. Client Credentials Flow
For machine-to-machine — no user involved.
1. App authenticates to Auth Server with: client_id + client_secret
2. Auth Server returns: access_token
3. App uses access_token to call APIs
This is what your CI/CD pipeline uses to deploy to Azure. It's what one microservice uses to talk to another.
3. Device Code Flow
For devices without browsers — TVs, CLI tools logging in.
1. Device asks Auth Server for: device_code, user_code, verification_uri
2. Device shows user: "Go to https://example.com/device and enter code XYZ-123"
3. Device polls Auth Server until user completes the browser flow
4. Auth Server returns: access_token
This is what az login does the first time on a new machine.
Tokens
•	Access token — short-lived (often 1 hour). Used for API calls.
•	Refresh token — long-lived (days to weeks). Used to get a new access token without bothering the user.
•	ID token (OIDC only — see next module) — contains user identity claims.
Why this matters in cloud security
Every modern cloud authentication uses OAuth 2.0 underneath. Every "Sign in with X" button. Every API token your CI/CD pipeline uses. Every breach involving an "OAuth phishing" attack (where an attacker registers a malicious app and tricks users into granting it access) is an OAuth 2.0 story. Knowing the flows lets you spot misconfigurations and risky consent patterns immediately.
________________________________________
Module 4.8 — OIDC versus SAML
OIDC — OpenID Connect
OIDC is an identity layer on top of OAuth 2.0. OAuth gives you authorisation; OIDC adds authentication — a way to learn who the user is, not just what they can do.
The key addition: an ID token, which is a signed JWT (JSON Web Token) containing claims about the user (sub, email, name, etc.). The relying party verifies the JWT signature against the auth server's public key.
OIDC is the modern default for new applications.
SAML — Security Assertion Markup Language
SAML is the older enterprise standard, predating OAuth. It uses XML rather than JSON, asserts identity via signed XML documents (SAML assertions), and is most common in:
•	Enterprise SSO with corporate IdPs (Active Directory Federation Services, Okta, Ping)
•	B2B integrations between large companies
•	Legacy on-prem applications
When to use which
Scenario	Choice
New web/mobile app	OIDC
Modern API authentication	OIDC + OAuth
Enterprise SSO with on-prem AD	SAML or OIDC, depending on tooling
Legacy enterprise SaaS	SAML (often the only option)
Mobile app	OIDC
Why this matters in cloud security
Every Identity Provider (Azure AD/Entra, Okta, Ping, Auth0, Cognito) supports both. Configuration mistakes in either are a classic finding: badly validated SAML assertions, OIDC configurations missing audience checks, JWTs accepted with none algorithm. You'll see these in real penetration tests every month.
________________________________________
Module 4.9 — Threat Modelling with STRIDE
Concept
Threat modelling is the structured exercise of asking "how could this go wrong?" before it does. STRIDE is a mnemonic from Microsoft that covers the six main threat categories.
The STRIDE categories
Letter	Threat	Property compromised
S	Spoofing	Authentication
T	Tampering	Integrity
R	Repudiation	Non-repudiation
I	Information disclosure	Confidentiality
D	Denial of service	Availability
E	Elevation of privilege	Authorisation
How to threat model
1.	Draw the system as a data flow diagram (boxes for components, arrows for data, dashed lines for trust boundaries).
2.	For each component and data flow, ask: which STRIDE threats apply?
3.	For each identified threat, decide: mitigate, accept, transfer, or avoid.
4.	Document.
Worked example — three-tier web app
Trust boundary 1: Internet → Frontend Trust boundary 2: Frontend → API Trust boundary 3: API → Database
Component	Threat	Mitigation
Frontend (browser)	S: stolen session cookie	HttpOnly, Secure, SameSite cookies; short session TTL
Frontend → API	T: parameter tampering	Server-side validation; signed tokens
API	I: SQL injection leaks data	Parameterised queries; least-privilege DB user
API → Database	D: large query DoS	Query timeouts; rate limiting
API auth	E: missing auth check on resource	Per-resource authorisation in every endpoint
Database	R: admin actions can be denied	Audit log, append-only, separate admin credentials
Why this matters in cloud security
In any senior security interview, you will be asked to walk through threat modelling a system. Doing this fluently — with STRIDE as your scaffolding — separates competent practitioners from posers. It is also the deliverable senior engineers produce most often: design reviews framed as threat models.
________________________________________
Module 4.10 — The MITRE ATT&CK Framework
Concept
ATT&CK is a publicly maintained knowledge base of adversary tactics and techniques observed in real attacks. It is structured as a matrix:
•	Tactics — what the attacker is trying to achieve (the why). 14 of them, including Initial Access, Execution, Persistence, Privilege Escalation, Defence Evasion, Credential Access, Discovery, Lateral Movement, Collection, Command and Control, Exfiltration, Impact.
•	Techniques — how they achieve it (the how). Hundreds of them, often with sub-techniques.
Why ATT&CK matters
It gives the entire industry a common language. Instead of saying "the attacker did some kind of phishing thing", you say T1566 — Phishing. Detection rules, threat intelligence reports, breach disclosures, SIEM alerts — all cross-reference ATT&CK technique IDs. Speaking ATT&CK fluently is non-negotiable for blue team work.
Three techniques worth knowing in detail
T1078 — Valid Accounts
Adversaries use stolen credentials to log in legitimately. This is the #1 initial access vector across breach reports year after year. Detection ideas: impossible travel, sign-ins from anonymising VPNs, sign-ins to dormant accounts, sign-ins outside business hours.
T1190 — Exploit Public-Facing Application
Adversaries exploit a vulnerability in an internet-facing app to gain access. WAFs help; patching matters; detection includes exception spikes, unusual outbound traffic from web servers, new processes spawned by web server users.
T1486 — Data Encrypted for Impact
The ransomware technique. Files are encrypted, often with attacker-controlled keys, and a ransom is demanded. Detection: anomalous file rename rates, mass write activity, unusual processes accessing many files.
Why this matters in cloud security
Sentinel, Defender for Cloud, every modern SIEM, every red team report, every threat intelligence feed — they all reference ATT&CK IDs. When you write a detection rule, you cite the technique it covers. When you read a breach report, you parse the ATT&CK chain to understand what happened.
________________________________________
Week 4 Lab Exercises
Lab 4.1 — Generate, sign, verify
mkdir -p ~/code/cloudsec-lab/notes
cd ~/code/cloudsec-lab

openssl genrsa -out lab/private.pem 2048
openssl rsa -in lab/private.pem -pubout -out lab/public.pem

echo "This message is from Dinesh on $(date)" > lab/message.txt
openssl dgst -sha256 -sign lab/private.pem -out lab/signature.bin lab/message.txt
openssl dgst -sha256 -verify lab/public.pem -signature lab/signature.bin lab/message.txt
Document in notes/crypto-walkthrough.md:
# Crypto walkthrough

Generated a 2048-bit RSA key pair using OpenSSL.

- `private.pem` — private key, kept locally and chmod 600
- `public.pem`  — public key, can be shared

Created a message file. Signed its SHA-256 hash with the private key, producing `signature.bin`.

Verified the signature using only the public key. Output: "Verified OK".

When I changed one character of `message.txt` and re-ran verification, it returned "Verification failure" — confirming the integrity guarantee.
Lab 4.2 — Three ATT&CK techniques
In notes/attack-techniques.md:
# Three MITRE ATT&CK techniques

## T1078 — Valid Accounts (Initial Access, Persistence, Privilege Escalation, Defense Evasion)

How it works: an attacker uses legitimate credentials — stolen, purchased, or guessed — to sign into an account. They appear as a normal user, which is why this technique evades most signature-based detection. Common sub-techniques include T1078.001 (Default Accounts), T1078.002 (Domain Accounts), and T1078.004 (Cloud Accounts).

Detection idea: impossible travel — a single account signing in from two countries within a window shorter than commercial flight time. In Sentinel: query SigninLogs for the same UserPrincipalName from two distinct geographic regions, calculate distance and elapsed time, flag if speed exceeds 1000 km/h.

## T1190 — Exploit Public-Facing Application (Initial Access)

How it works: an attacker exploits a known vulnerability — SQL injection, RCE, deserialization — in an internet-exposed application to gain initial access to the network. Examples include Log4Shell (CVE-2021-44228) and the MOVEit Transfer SQLi (CVE-2023-34362).

Detection idea: unusual child process spawned by the web server user. A web app should not be invoking `bash`, `cmd.exe`, `powershell`, `wget`, or `curl` to download payloads. Falco rule on AKS: alert when nginx pod parent spawns shell or download utility.

## T1486 — Data Encrypted for Impact (Impact)

How it works: ransomware encrypts files on disk, often with a key derived from an attacker-controlled key, then demands payment for the decryption key. Modern ransomware also exfiltrates first ("double extortion") to threaten data leak even if the victim has backups.

Detection idea: high-volume file rename or write rate from a single process. EDR rules can baseline normal per-process file activity per hour and alert on 10x deviations. File integrity monitoring tools detect mass changes to file extensions (e.g. .docx → .locked).
Lab 4.3 — STRIDE on a web app
In notes/stride-webapp.md:
# STRIDE threat model — generic three-tier web app

## Architecture

Internet ──[TLS]──> Frontend (browser) │ [HTTPS] ▼ API Server │ [TLS / private] ▼ Database

Trust boundaries:
1. Internet → Frontend
2. Frontend → API
3. API → Database

## Threats by component

### Frontend (browser-side JavaScript)

| Threat | Example | Mitigation |
|---|---|---|
| S — Spoofing | XSS that steals a session cookie | CSP header, HttpOnly + Secure cookies |
| T — Tampering | Modified JavaScript injecting fraudulent calls | Subresource Integrity (SRI) hashes |
| I — Information disclosure | Sensitive data cached in localStorage | Avoid localStorage for tokens; short-lived JWTs in memory |

### API server

| Threat | Example | Mitigation |
|---|---|---|
| S — Spoofing | Forged JWT | Verify signature, audience, issuer; reject "alg: none" |
| T — Tampering | Mass-assignment of admin=true | Allow-list deserialization fields |
| R — Repudiation | "I never made that change" | Append-only audit log with user, action, timestamp, request ID |
| I — Info disclosure | SQL injection dumps user table | Parameterised queries; least-privilege DB user; ORM |
| D — DoS | Expensive query loops | Per-user rate limit; query timeouts; circuit breakers |
| E — EoP | IDOR — accessing /api/orders/123 belongs to other user | Per-resource authorisation check on every endpoint |

### Database

| Threat | Example | Mitigation |
|---|---|---|
| T — Tampering | Direct DB connection alters records | Network isolation; only API can reach DB |
| I — Info disclosure | Backup file in public bucket | Encrypt backups; private storage; access reviewed quarterly |
| D — DoS | Storage exhaustion | Quotas; alerts at 80% full |

## Top mitigations summary

1. mTLS between Frontend → API and API → Database
2. WAF in front of Frontend with OWASP CRS
3. Per-resource authorisation in every API endpoint (do not trust UUIDs)
4. Append-only audit log streaming to a SIEM
5. Quarterly access reviews on database and storage
Week 4 Verification
•	[ ] notes/crypto-walkthrough.md — written and demonstrates the verify-failure case.
•	[ ] notes/attack-techniques.md — three techniques with detection ideas.
•	[ ] notes/stride-webapp.md — full STRIDE analysis with mitigations.
•	[ ] You can describe OAuth 2.0 authorisation code flow without notes.
•	[ ] You can describe the difference between OIDC and SAML in two sentences.
•	[ ] You can explain why SMS is the weakest MFA method.
________________________________________
CAPSTONE
Final integration exercise
Pick one real system you understand — your home network, a small web app you use, your work intranet. Produce a 2-page document covering:
1.	Component diagram — what's connected to what.
2.	Linux commands you'd use to investigate each component (Module 2.4–2.9 material).
3.	Network analysis — IP ranges, ports, protocols, where TLS terminates (Module 3.1–3.9 material).
4.	Identity & access — how users authenticate, what authorisation is in place (Module 4.1–4.8 material).
5.	STRIDE table for the system (Module 4.9).
6.	Top three ATT&CK techniques that would be relevant attacks against it, and one detection idea for each (Module 4.10).
Push to your GitHub repo as notes/capstone.md. Show it to a peer or post it to your LinkedIn. This document, more than any cert, demonstrates that you understand the foundations.
Self-assessment quiz
Answer without notes. If you can't answer 18+ of these correctly, repeat the relevant module.
1.	What does chmod 4755 mean?
2.	What's the difference between kill -9 and kill -15?
3.	What does the set -euo pipefail line do?
4.	How many usable hosts in a /27?
5.	What are the three packets of a TCP handshake?
6.	Which DNS record type is used to specify mail servers?
7.	In a TLS 1.3 handshake, how many round trips before encrypted application data?
8.	What's a stateful vs stateless firewall?
9.	Define authentication and authorisation in one sentence each.
10.	Why is SMS the weakest MFA method?
11.	Why is AES-GCM preferred over AES-CBC?
12.	What is salting in password hashing, and why?
13.	What does an X.509 certificate contain at minimum?
14.	What is PKCE and which OAuth flow uses it?
15.	How does an OIDC ID token differ from an OAuth access token?
16.	What does the "I" in STRIDE stand for, and give an example.
17.	What does the MITRE ATT&CK technique ID T1078 refer to?
18.	What's the difference between a cluster and a node in Kubernetes? (bonus, looking ahead)
19.	What's the difference between a security group and a network ACL in AWS? (bonus)
20.	What's the principle of least privilege?
Where to go next
You have completed the foundations. Next phase is hands-on Azure with Terraform — see Phase B of the master study plan. You should now be able to:
•	Read cloud security documentation and understand the assumed Linux/networking/identity context.
•	Recognise common misconfigurations on sight.
•	Build small automation scripts in Bash without copy-pasting.
•	Explain the trust model of any system you encounter.
That's the platform on which everything else is built. Good luck with Phase B.
________________________________________
End of course book — Cloud Security Foundations, Weeks 2–4 Version 1.0

