#!/bin/bash
# {{{ 
# ----------------------------------------------------------------------------
# "THE BEER-WARE LICENSE" (Revision 42):
# Periklis Ntanasis <pntanasis@gmail.com> and Ivan c00kiemon5ter Kanakarakis 
# <ivan.kanak@gmail.com> wrote this file. As long as you retain this notice you
# can do whatever you want with this stuff. If we meet some day, and you think
# this stuff is worth it, you can buy us a beer in return!
# ----------------------------------------------------------------------------
#
# This is a bash script managing all needed things 
# for our university
#
# install / remove apps
# connect / disconnect wifi
# more to come
# }}}

# TODO
# check needed progs (eg extract) at each stage
# build pkgs func
# print status mesg and keep log
# dstro arg
# PMS install/remove arg
# profit!

 # Environment vars {{{
BUILD_DIR="/tmp/src/"
BUILD_FLAGS="--prefix=/usr LDFLAGS=\"-Wl,--no-as-needed\""

# Log files
WPAERR="/tmp/wpa_aueb.err"
WPALOG="/tmp/wpa_aueb.log"
WPACONF="/tmp/wpa_aueb.conf"

## Package Managers
PMS=(	[ubuntu]="apt-get install"
		[arch]="pacman -S" )

## Applications throught the PMS
APPS=(	[common]="netbeans scilab geany nmap spim tcsh wireshark"
		[ubuntu]="openjdk-6-jdk build-essential"
		[arch]="openjdk6 base-devel" )

# }}}

# FIXME Applications that need to be built from source {{{
LAMPP="http://www.apachefriends.org/download.php?xampp-linux-1.7.3a.tar.gz"
OMNET="http://www.omnetpp.org/omnetpp/doc_download/2217-omnet-41-source--ide-tgz"
# ACCEPT THE AGREEMENT
NESSUS="http://www.nessus.org/download/index.php?product=nessus42-linux"
# register to download Quartus
QUARTUS="https://www.altera.com/servlets/download3?swcode=WWW-SWD-QII-WE-100SP1-LNX&l=en"
# }}}

# Usage message {{{
function usage() {
cat << EOF
usage: $(basename $0) [option [suboption]]

	Options are:
	apps [app_opts]			application management
	wifi [wifi_opts]		wifi connection management
	
	Application options are:
	install				install all applications
	remove				remove all applications

	Wifi options are:
	connect				connect to wireless
	disconnect			disconnect from wireless
EOF
}
# }}}

# Applications management {{{
# Extract an archive
function extract() {
	if [ -f $1 ] ; then
		case $1 in
			*.tar.bz2)   tar xvjf $1    ;;
			*.tar.gz)    tar xvzf $1    ;;
			*.bz2)       bunzip2 $1     ;;
			*.rar)       unrar x $1     ;;
			*.gz)        gunzip $1      ;;
			*.tar)       tar xvf $1     ;;
			*.tbz2)      tar xvjf $1    ;;
			*.tgz)       tar xvzf $1    ;;
			*.zip)       unzip $1       ;;
			*.Z)         uncompress $1  ;;
			*.7z)        7z x $1        ;;
			*)           echo "I don't know how to extract \"$1\"..." ;;
		esac
	else
		echo "\"$1\" is not a valid file"
	fi
}

# FIXME Build a package from source
function buildpkgs() {
	mkdir -p $BUILD_DIR
	cd $BUILD_DIR
	wget $pkg_url
	extract $pkg
	./configure --${CONF_FLAGS}
	make && make install
}

# FIXME for loop..
# Install a package using PMS
function installpkgs() {
	${PMS[$distro]} ${APPS["common"]} ${APPS[$distro]}
}

# main install function
function install() {
	installpkgs
	buildpkgs
}

# main remove function
function remove() { 
	echo cookies
}

# manage application installation
function apps() {
	case $1 in
		install)	install	;;
		remove)		remove	;;
		*)			usage && exit 1	;;
	esac
}
# }}}

# wifi management {{{
# connect to wifi
function connectwifi() {
	wpa_wifi
	/etc/{rc,init}.d/{networkmanager,wicd} stop &>/dev/null
	ifconfig $IFACE down
	ifconfig $IFACE up
	wpa_supplicant -Dwext -i$IFACE -c $WPACONF 1>$WPALOG 2>$WPAERR
}

# disconnect from wifi
function disconnectwifi() {
	ifconfig $IFACE down
	/etc/{rc,init}.d/{networkmanager,wicd} start &>/dev/null
	rm $WPACONF
}

# create wpa_supplicant configuration file
function wpa_wifi() {
cat > ${WPACONF} << EOF
ctrl_interface=/tmp/wpa_aueb
eapol_version=1
ap_scan=1
fast_reauth=1
network={
      ssid="AUEB-Wireless"
      key_mgmt=WPA-EAP
      pairwise=CCMP TKIP
      eap=PEAP
      phase2="auth=MSCHAPV2"
      identity="aueb"
      password="wireless"
}
EOF
}

# manage wifi connection
function wifi() {
	case $1 in
		connect)	connectwifi		;;
		disconnect)	disconnectwifii	;;
		*)			usage && exit 1	;;
	esac
	IFACE="$(iwconfig 2>&1 | grep -v "no\|^$" | head -1 | awk '{ print $1 }')"
}
# }}}  

# Main run 
case $1 in 
	wifi) wifi $2 ;;
	apps) apps $2 ;;
	*) usage
esac

# vim: set nonumber nospell foldmethod=marker:foldmarker={{{,}}}:foldlevel=0
