# Post initial setup

It's for setup a server, not for a desktop or hypervisor setup.

 * Setup a simple and minimal Debian, without nothing more tools
 * Don't set up sudo if you don't like it
 * Set a simple root password, it will be changed in the future

After the first restart,

	apt-get install -y vim ssh

> If you choose to install ssh during setup, you don't need to add it here.
> It you prefer another text editor, choose it here.

After that, enable root logging via ssh

	vi /etc/ssh/sshd_config

And set	

	PermitRootLogin yes

And reboot sshd or server.

# First connection

Add your ssh public key

	ssh-copy-id -i ${HOME}/.ssh/id_rsa.pub root@<fresh-server>

Accept server id, and connect to it

	ssh root@<fresh-server>

# Prepare locale console

    export DEBIAN_FRONTEND=noninteractive
    HOSTNAME=$(hostname);
	ADMINMAIL=me@mydomain.com

# Pre-setup

	apt-get update
	apt-get dist-upgrade -y
	apt-get install -y perl-modules git molly-guard open-vm-tools

> open-vm-tools only for a VM in an ESXi host

## Enable ntp

	echo "Servers=0.debian.pool.ntp.org 1.debian.pool.ntp.org 2.debian.pool.ntp.org 3.debian.pool.ntp.org" >> /etc/systemd/timesyncd.conf
	systemctl start systemd-timesyncd.service && systemctl enable systemd-timesyncd.service
	systemctl status systemd-timesyncd.service

# Setup

## Change root password and send it to you

	apt-get install -y postfix mailutils pwgen
	echo "root: $ADMINMAIL" >> /etc/aliases
	newaliases
	NEWPW=$(pwgen 12)
	echo "New root password: $NEWPW" | mail -s "Change root password for $HOSTNAME" root
	echo "The new root password ($NEWPW) will be send by mail to you."
	echo root:$NEWPW | chpasswd

## Security mails (boring but usefull)

	apt-get install -y apticron logcheck
	apticron
	su -s /bin/bash -c "/usr/sbin/logcheck" logcheck

Add some ignore rules

	echo "^\w{3} [ :0-9]{11} [._[:alnum:]-]+ rsyslogd[-[:digit:]]+: action 'action 1[0-9]' resumed \(module 'builtin:ompipe'\) \[try http://www.rsyslog.com/e/[[:digit:]]+ \]$" >> /etc/logcheck/ignore.d.server/rsyslog
	echo "^\w{3} [ :0-9]{11} [._[:alnum:]-]+ rsyslogd[-[:digit:]]+: action 'action 1[0-9]' suspended, next retry is \w{3} \w{3} [ :0-9]{16} \[try http://www.rsyslog.com/e/[[:digit:]]+ \]$" >> /etc/logcheck/ignore.d.server/rsyslog
	echo "^\w{3} [ :0-9]{11} [._[:alnum:]-]+ rsyslogd[[:digit:]]+: action 'action 1[0-9]' resumed \(module 'builtin:ompipe'\) \[try http://www.rsyslog.com/e/[[:digit:]]+ \]$" >> /etc/logcheck/ignore.d.server/rsyslog
	echo "^\w{3} [ :0-9]{11} [._[:alnum:]-]+ rsyslogd: /dev/xconsole$"  >> /etc/logcheck/ignore.d.server/rsyslog
	echo "^\w{3} [ :0-9]{11} [._[:alnum:]-]+ systemd-timesyncd\[[0-9]+\]: interval/delta/delay/jitter/drift [0-9]+s/(\+|\-)[0-9]+.[0-9]+s/[0-9]+.[0-9]+s/[0-9]+.[0-9]+s/(\+|\-)[0-9]+ppm \(ignored\)$" > /etc/logcheck/ignore.d.server/systemd-timesyncd
	echo "^\w{3} [ :0-9]{11} [._[:alnum:]-]+ systemd-timesyncd\[[0-9]+\]: interval/delta/delay/jitter/drift [0-9]+s/(\+|\-)[0-9]+.[0-9]+s/[0-9]+.[0-9]+s/[0-9]+.[0-9]+s/(\+|\-)[0-9]+ppm$" >> /etc/logcheck/ignore.d.server/systemd-timesyncd
	echo "^\w{3} [ :0-9]{11} [._[:alnum:]-]+ systemd-timesyncd\[[0-9]+\]: System time changed. Resyncing.$" >> /etc/logcheck/ignore.d.server/systemd-timesyncd
	echo "^\w{3} [ :0-9]{11} [._[:alnum:]-]+ apache2\[[[:digit:]]+\]: Reloading web server: apache2.$"  >> /etc/logcheck/ignore.d.server/apache
	echo "^\w{3} [ :0-9]{11} [._[:alnum:]-]+ systemd\[[0-9]+\]: Starting Cleanup of Temporary Directories...$" >> /etc/logcheck/ignore.d.server/systemd
	echo "^\w{3} [ :0-9]{11} [._[:alnum:]-]+ systemd\[[0-9]+\]: Started Cleanup of Temporary Directories.$" >> /etc/logcheck/ignore.d.server/systemd
	echo "^\w{3} [ :0-9]{11} [._[:alnum:]-]+ systemd\[[0-9]+\]: Reloading LSB: Apache2 web server.$" >> /etc/logcheck/ignore.d.server/systemd
	echo "^\w{3} [ :0-9]{11} [._[:alnum:]-]+ systemd\[[0-9]+\]: Reloaded LSB: Apache2 web server.$" >> /etc/logcheck/ignore.d.server/systemd
	echo "^\w{3} [ :0-9]{11} [._[:alnum:]-]+ systemd\[[0-9]+\]: Reloading LSB: start Samba SMB/CIFS daemon \(smbd\).$" >> /etc/logcheck/ignore.d.server/systemd
	echo "^\w{3} [ :0-9]{11} [._[:alnum:]-]+ systemd\[[0-9]+\]: Reloaded LSB: start Samba SMB/CIFS daemon \(smbd\).$" >> /etc/logcheck/ignore.d.server/systemd

See more on http://www.expreg.com/memo.php, and http://manpages.ubuntu.com/manpages/natty/man1/logcheck-test.1.html

For create new, use

	logcheck-test --log-file /var/log/syslog.1 ""
	./host-each.sh 'echo "^$"  >> /etc/logcheck/ignore.d.server/'

## Install security updates automatically

	apt-get install -y unattended-upgrades
	dpkg-reconfigure unattended-upgrades
	ls /etc/apt/apt.conf.d/20auto-upgrades

# Optional options

## Mount Windows servers (SMB / CIFS)

	apt-get install -y cifs-utils

fstab use

	//server/mount/path /mnt/dest cifs credentials=/root/server.smbcredentials,dir_mode=0777,file_mode=0777,iocharset=utf8,noserverino	0 0

Add `vers=3.0` for **SMBv3** servers. Add `nounix` for Linux SMB server and remove uid/gid routing.

With a `/root/server.smbcredentials` like

	username=me
	password=mypassword
	domain=myad.domain

## Tweak journald

> See https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/System_Administrators_Guide/s1-Using_the_Journal.html

	vi /etc/systemd/journald.conf
	MaxLevelSyslog=notice
	systemctl restart systemd-journald

	# journalctl -f
	# journalctl -p warning
	# debug (7), info (6), notice (5), warning (4), err (3), crit (2), alert (1), and emerg (0)
	# tail -f /var/log/syslog

## Firewall

	apt-get install -y iptables-persistent

Set rules in `/etc/iptables/up.rules`

	*filter
	:INPUT ACCEPT [0:0]
	:FORWARD ACCEPT [0:0]
	:OUTPUT ACCEPT [0:0]
	-A INPUT -i lo -j ACCEPT
	-A INPUT -d 127.0.0.0/8 ! -i lo -j REJECT --reject-with icmp-port-unreachable
	-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
	-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
	-A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT
	
	# Accept ssh
	-A INPUT -p tcp --dport 22 -j ACCEPT
	
	# Example : accept a tcp port list from all hosts in 192.168.1.0 network
	# -A INPUT -p tcp -m multiport --dports 7000,7001,9160,9042,7199 -s 192.168.1.0/24 -j ACCEPT
	
	-A INPUT -j REJECT --reject-with icmp-port-unreachable
	-A FORWARD -j REJECT --reject-with icmp-port-unreachable
	-A OUTPUT -j ACCEPT
	COMMIT

Switch-on rules now

	iptables-restore < "/etc/iptables/up.rules"

Switch-on rules after networks startup

	echo '#!/bin/sh' > /etc/network/if-pre-up.d/iptables
	echo "/sbin/iptables-restore < /etc/iptables/up.rules" >> /etc/network/if-pre-up.d/iptables
	chmod +x "/etc/network/if-pre-up.d/iptables"

## Keep all installed packages in textfile

	echo "0 5     * * *   root    dpkg -l > /root/dpkg.txt" >> /etc/crontab
	/etc/init.d/cron restart

## Setup Dotdeb

	echo "deb http://packages.dotdeb.org jessie all" >>  /etc/apt/sources.list
	echo "deb-src http://packages.dotdeb.org jessie all" >>  /etc/apt/sources.list
	wget https://www.dotdeb.org/dotdeb.gpg
	apt-key add dotdeb.gpg
	rm dotdeb.gpg
	apt-get update
	apt-get dist-upgrade

## Snmpd

Set `SNMPDOPTS='-LS0-4d [...]`

## Install (declare) Java 8 JRE JVM SE from Oracle

Please read and accept Oracle license before setup. Get correct URL from Oracle website.

> This is and example for **jre1.8.0_45** / **8u111**. Adapt it as you want.

	wget --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u111-b14/jre-8u111-linux-x64.tar.gz
	mkdir -p /opt/jre
	tar -xzf jre-8u111-linux-x64.tar.gz -C /opt/jre
	update-alternatives --remove java /opt/jre/jre1.8.0_45/bin/java
	update-alternatives --install /usr/bin/java java /opt/jre/jre1.8.0_111/bin/java 2000
	# use 200000 for CentOS
	java -version
	rm jre*-linux-x64.tar.gz

### JCE Policies

	apt-get install -y unzip
	wget --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip
	unzip jce_policy-8.zip 
	mv UnlimitedJCEPolicyJDK8/*.jar /opt/jre/jre1.8.0_111/lib/security/
	rm jce_policy-8.zip
	rm -rf UnlimitedJCEPolicyJDK8
