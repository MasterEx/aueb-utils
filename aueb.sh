#!/usr/bin/env bash
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
# check needed progs at each stage
# build pkgs func
# print status mesg and keep log
# profit!

# Environment vars {{{
PREFIX="/tmp/aueb"
LOG="${PREFIX}/aueb.log"
BUILD_DIR="${PREFIX}/aueb_pkg_src"
BUILD_FLAGS="--prefix=/usr LDFLAGS=\"-Wl,--no-as-needed\""

# wifi log files
WPAERR="${PREFIX}/wpa_aueb.err"
WPALOG="${PREFIX}/wpa_aueb.log"
WPACONF="/etc/wpa_supplicant/wpa_aueb.conf"

# Package Managers installation/removal of apps
declare -A PMSI
PMSI=(	[ubuntu]="apt-get install"
		[arch]="pacman -S" )
declare -A PMSR
PMSR=(	[ubuntu]="apt-get remove"
		[arch]="pacman -Rs" )

# Applications throught the PMS
declare -A APPS
APPS=(	[common]="netbeans scilab geany nmap tcsh wireshark"
		[ubuntu]="openjdk-6-jdk build-essential wireless-tools wpasupplicant spim"
		[arch]="openjdk6 base-devel wireless_tools wpa_supplicant" )

# }}}

# FIXME crete arch-like vars for each package, each
# FIXME parckege will be a function that resets the vars (url/pkgname/etc)
# Applications that need to be built from source {{{

# custom pkgbuilds
function omnet() {
	pkgname=omnet
	pkgver=4.1
	pkgrel=41
	pkgdesc="OMNeT++ is an extensible, modular, component-based C++ simulation\
	 library and framework, primarily for building network simulators."
	arch=('i686' 'x86_64')
	url="http://www.omnetpp.org/"
	license=('ACADEMIC PUBLIC LICENSE')
	groups=('none')
	depends=('akaroa')
	source=(http://www.omnetpp.org/omnetpp/doc_download/2217-$pkgname-$pkgver-source--ide-tgz)
	md5sums=('acc78fbc9f4b6ca921d11fabcec55c44')
}

function spim() {
	pkgname=spim
	pkgver=8.0
	pkgrel=1
	pkgdesc="A MIPS32 simulator"
	arch=('i686' 'x86_64')
	url="http://pages.cs.wisc.edu/~larus/$pkgname.html"
	license=('custom:BSD')
	groups=('emulators')
	depends=('libxaw')
	makedepends=('bison' 'flex' 'm4' 'imake')
	conflicts=(xspim)
	provides=(xspim)
	source=(http://www.cs.wisc.edu/~larus/SPIM/${pkgname}-${pkgver}.tar.gz)
	md5sums=('146558e8256f2b7577fb825fdc76a04f')
}

#LAMPP="http://www.apachefriends.org/download.php?xampp-linux-1.7.3a.tar.gz"
# ACCEPT THE AGREEMENT
#NESSUS="http://www.nessus.org/download/index.php?product=nessus42-linux"
# register to download Quartus
#QUARTUS="https://www.altera.com/servlets/download3?swcode=WWW-SWD-QII-WE-100SP1-LNX&l=en"
# }}}

# Usage message {{{ 
function usage() {
cat << EOF
usage: $(basename "$0") option suboption distro

	Options are:
	apps [app_opts]			application management
	wifi [wifi_opts]		wifi connection management
	
	Application options are:
	install				install all applications
	remove				remove all applications

	Wifi options are:
	connect				connect to wireless
	disconnect			disconnect from wireless

	distro				the linux distribution [supported:ubuntu,arch]
EOF
exit 1
}
# }}}

# Applications management {{{
# Extract an archive
function extract() {
	if [ -f "$1" ] ; then
		case "$1" in
			*.tar.bz2)   tar xvjf "$1"    ;;
			*.tar.gz)    tar xvzf "$1"    ;;
			*.bz2)       bunzip2 "$1"     ;;
			*.rar)       unrar x "$1"     ;;
			*.gz)        gunzip "$1"      ;;
			*.tar)       tar xvf "$1"     ;;
			*.tbz2)      tar xvjf "$1"    ;;
			*.tgz)       tar xvzf "$1"    ;;
			*.zip)       unzip "$1"       ;;
			*.Z)         uncompress "$1"  ;;
			*.7z)        7z x "$1"        ;;
			*)           echo "I don't know how to extract \"$1\"..." ;;
		esac
	else
		echo "\"$1\" is not a valid file"
	fi
}

# empty build directory
function cleanbuild() {
	rm -r $BUILD_DIR/*
}

# FIXME Build a package from source
function buildpkgs() {
	wget "$pkg_url"
	extract "$pkg"
	./configure --${CONF_FLAGS}
	make && make install
	cleanbuild
}

# Install packages using PMS
function installpkgs() {
	${PMSI["$DISTRO"]} ${APPS["common"]} ${APPS["$DISTRO"]}
	(( $? )) && echo Failure || echo Success
}

# main install function
function install() {
	installpkgs
	[ -e "$BUILD_DIR" ] || mkdir -p $BUILD_DIR
	local curpath="$PWD"
	cd $BUILD_DIR
	buildpkgs
	cd "$curpath"
}

# remove packages using PMS
function removepkgs() {
	${PMSR["$DISTRO"]} ${APPS["common"]} ${APPS["$DISTRO"]}
	(( $? )) && echo Failure || echo Success
}

# main remove function
function remove() { 
	removepkgs
	removebuildpkgs
}

# manage application installation
function apps() {
	case "$1" in
		install)	install	;;
		remove)		remove	;;
		*)			usage	;;
	esac
}
# }}}

# FIXME is a network manager running? which one? how to stop/restart it? 
# wifi management {{{
# connect to wifi
function connectwifi() {
	wpa_wifi
	/etc/{rc,init}.d/{networkmanager,wicd} stop &>/dev/null
	ifconfig "$IFACE" down
	ifconfig "$IFACE" up
	wpa_supplicant -Dwext -i "$IFACE" -c "$WPACONF" 1>"$WPALOG" 2>"$WPAERR"
}

# disconnect from wifi
function disconnectwifi() {
	ifconfig "$IFACE" down
	/etc/{rc,init}.d/{networkmanager,wicd} start &>/dev/null
}

# create wpa_supplicant configuration file
function wpa_wifi() {
	[ -e "$WPACONF" ] && return
	mkdir -p "$(dirname ${WPACONF})"
	cat > "$WPACONF" << EOF
ctrl_interface=${PREFIX}/wpa_aueb
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
	IFACE="$(iwconfig 2>&1 | grep -v "no\|^$" | head -1 | awk '{ print $1 }')"
	[ -z "$IFACE" ] && echo "No wireless interface found" && exit 1
	case "$1" in
		connect)	connectwifi		;;
		disconnect)	disconnectwifii	;;
		*)			usage			;;
	esac
}
# }}}  

# Main run 
[ -n "$3" ] && DISTRO="$3" || usage
[ "$DISTRO" == "ubuntu" -o "$DISTRO" == "arch" ] || usage
mkdir -p "$PREFIX"
case "$1" in 
	wifi) wifi "$2" ;;
	apps) apps "$2" ;;
	*) usage
esac

# vim: set nonumber nospell foldmethod=marker:foldmarker={{{,}}}:foldlevel=0
