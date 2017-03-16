#!/bin/sh
# cloudmin-debian-install.sh
# Copyright 2005-2009 Virtualmin, Inc.
#
# Installs Cloudmin and all dependencies on a Debian or Ubuntu system

if [ "$SERIAL" = "" ]; then
	SERIAL=*****
fi
if [ "$KEY" = "" ]; then
	KEY=*****
fi
VER=1.1

# Define functions
yesno () {
	while read line; do
		case $line in
			y|Y|Yes|YES|yes|yES|yEs|YeS|yeS) return 0
			;;
			n|N|No|NO|no|nO) return 1
			;;
			*)
			printf "\nPlease enter y or n: "
			;;
		esac
	done
}

# Ask the user first
cat <<EOF
***********************************************************************
*           Welcome to the Cloudmin installer, version $VER           *
***********************************************************************

 Operating systems supported by this installer are:

 Debian 4.0 or later on i386 and x86_64
 Ubuntu 8.04 or later on i386 and x86_64

 If your OS is not listed above, this script will fail (and attempting
 to run it on an unsupported OS is not recommended, or...supported).
EOF
printf " Continue? (y/n) "
if ! yesno
then exit
fi
echo ""

# Cleanup old repo files
grep -v cloudmin.virtualmin.com /etc/apt/sources.list >/etc/apt/sources.list.clean
mv /etc/apt/sources.list.clean /etc/apt/sources.list

# Check for apt-get
echo Checking for apt-get ..
if [ ! -x /usr/bin/apt-get ]; then
	echo .. not installed. The Cloudmin installer requires APT to download packages
	echo ""
	exit 1
fi
echo .. found OK
echo ""

# Make sure we have wget
echo "Installing wget .."
apt-get -y install wget
echo ".. done"
echo ""

# Check for wget or curl
echo "Checking for curl or wget..."
if [ -x "/usr/bin/curl" ]; then
	download="/usr/bin/curl -s "
elif [ -x "/usr/bin/wget" ]; then
	download="/usr/bin/wget -nv -O -"
else
	echo "No web download program available: Please install curl or wget"
	echo "and try again."
	exit 1
fi
echo "found $download"
echo ""

# Validate licence with wget
echo Validating Cloudmin serial number and key ..
$download "http://${SERIAL}:${KEY}@cloudmin.virtualmin.com/images/images.txt" >/dev/null
if [ "$?" != 0 ]; then
	echo .. license does not appear to be valid
	exit 1
fi
echo .. done
echo ""

# Create Cloudmin licence file
echo Creating Cloudmin licence file ..
cat >/etc/server-manager-license <<EOF
SerialNumber=$SERIAL
LicenseKey=$KEY
EOF
chmod 600 /etc/server-manager-license
echo .. done
echo ""

# Download GPG keys
echo Downloading GPG keys for packages ..
$download "http://software.virtualmin.com/lib/RPM-GPG-KEY-virtualmin" >/tmp/RPM-GPG-KEY-virtualmin
if [ "$?" != 0 ]; then
	echo .. download failed
	exit 1
fi
$download "http://software.virtualmin.com/lib/RPM-GPG-KEY-webmin" >/tmp/RPM-GPG-KEY-webmin
if [ "$?" != 0 ]; then
	echo .. download failed
	exit 1
fi
echo .. done
echo ""

# Import keys
echo Importing GPG keys ..
apt-key add /tmp/RPM-GPG-KEY-virtualmin && apt-key add /tmp/RPM-GPG-KEY-webmin
if [ "$?" != 0 ]; then
	echo .. import failed
	exit 1
fi
echo .. done
echo ""

# Setup the APT sources file
echo Creating APT repository for Cloudmin packages ..
cat >>/etc/apt/sources.list <<EOF
deb http://$SERIAL:$KEY@cloudmin.virtualmin.com/debian binary/
EOF
apt-get update
echo .. done
echo ""

# APT install Perl, modules and other dependencies
echo Installing required Perl modules using APT ..
apt-get -y install perl openssl libio-pty-perl libio-stty-perl libnet-ssleay-perl libwww-perl libdigest-hmac-perl libxml-simple-perl libcrypt-ssleay-perl libauthen-pam-perl cron bind9 openssh-server openssh-client lsof
if [ "$?" != 0 ]; then
	echo .. install failed
	exit 1
fi
apt-get install -y libjson-perl
apt-get install -y bind9utils
apt-get install -y dhcp3-server
apt-get install -y libdigest-sha1-perl
echo .. done
echo ""

# APT install webmin, theme and Cloudmin
echo Installing Cloudmin packages using APT ..
apt-get -y install webmin
apt-get -y install webmin-server-manager webmin-virtual-server-theme webmin-virtual-server-mobile webmin-security-updates && apt-get -y install webmin-cloudmin-services
if [ "$?" != 0 ]; then
	echo .. install failed
	exit 1
fi
echo .. done
echo ""

# Configure Webmin to use theme
echo Configuring Webmin ..
grep -v "^preroot=" /etc/webmin/miniserv.conf >/tmp/miniserv.conf.$$
echo preroot=authentic-theme >>/tmp/miniserv.conf.$$
cat /tmp/miniserv.conf.$$ >/etc/webmin/miniserv.conf
rm -f /tmp/miniserv.conf.$$
grep -v "^theme=" /etc/webmin/config >/tmp/config.$$
echo theme=authentic-theme >>/tmp/config.$$
cat /tmp/config.$$ >/etc/webmin/config
rm -f /tmp/config.$$
/etc/webmin/restart
echo .. done
echo ""

# Setup BIND zone for virtual systems
basezone=`hostname -d`
if [ "$basezone" = "" ]; then
	basezone=example.com
fi
zone="cloudmin.$basezone"
echo Creating DNS zone $zone ..
/usr/share/webmin/server-manager/setup-bind-zone.pl --zone $zone --auto-view
if [ "$?" != 0 ]; then
  echo .. failed
else
  echo xen_zone=$zone >>/etc/webmin/server-manager/config
  echo kvm_zone=$zone >>/etc/webmin/server-manager/config
  echo citrix_zone=$zone >>/etc/webmin/server-manager/config
  echo openvz_zone=$zone >>/etc/webmin/server-manager/config
  echo lxc_zone=$zone >>/etc/webmin/server-manager/config
  echo vserver_zone=$zone >>/etc/webmin/server-manager/config
  echo zone_zone=$zone >>/etc/webmin/server-manager/config
  echo .. done
fi
echo ""

# Open Webmin firewall port
echo Opening port 10000 on host firewall ..
/usr/share/webmin/firewall/open-ports.pl 10000 10001 10002 10003 10004 10005 843
if [ "$?" != 0 ]; then
  echo .. failed
else
  echo .. done
fi
echo ""

# Tell user
hostname=`hostname`
echo Cloudmin has been successfully installed. You can login to it at :
echo https://$hostname:10000/

# All done!
