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
# This is a bash script managing all needed things for our university
#
# install / remove apps
# connect / disconnect wifi
# more to come
# }}}

# TODO profit!
# check needed progs at each stage
# build pkgs func
# print status msgs and keep log

# Environment vars {{{
FOSS_AUEB="http://foss.aueb.gr/"	

PREFIX="/tmp/aueb"
LOG="${PREFIX}/aueb.log"
BUILD_DIR="${PREFIX}/aueb_pkg_src"
BUILD_FLAGS="--prefix=/usr LDFLAGS=\"-Wl,--no-as-needed\""

# wifi log files
WPAERR="${PREFIX}/wpa_aueb.err"
WPALOG="${PREFIX}/wpa_aueb.log"
WPACONF="/etc/wpa_supplicant/wpa_aueb.conf"

# 3rd party packages installation destination
VENDORS_DIR="/opt"

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
		[arch]="openjdk6 base-devel wireless_tools wpa_supplicant" 
		[build]="omnet spim" 
		[extra]="xampp" )

# }}}

# TODO crete arch-like vars for each package, the idea is that
# each parckege will be a function that resets the vars (url/pkgname/etc)
# applications that need to be built from source ~ custom function-packages {{{

function omnet() {
	pkgname="omnetpp"
	pkgver=4.1
	pkgrel=41
	pkgdesc="OMNeT++ is an extensible, modular, component-based C++ simulation \
	 library and framework, primarily for building network simulators."
	arch=('i686' 'x86_64')
	url="http://www.omnetpp.org/"
	license=('ACADEMIC PUBLIC LICENSE')
	groups=('none')
	depends=('akaroa')
	src=(${FOSS_AUEB}sources/${pkgname}-${pkgver}-src.tgz)
	md5sums=('acc78fbc9f4b6ca921d11fabcec55c44')
}

function spim() {
	pkgname="spim"
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
	src=(${FOSS_AUEB}sources/${pkgname}.tar.gz)
	md5sums=('146558e8256f2b7577fb825fdc76a04f')
}

function xampp() {
	pkgname="xampp"
	pkgver="1.7.3a"
	pkgdesc="The Linux version of XAMPP"
	arch=('i686' 'x86_64')
	url="http://www.apachefriends.org/en/xampp-linux.html"
	src=(${FOSS_AUEB}sources/${pkgname}-linux-${pkgver}.tar.gz)
	md5sum=('89c13779cf6f0925d5c1c400d31a1cc3')
}

function quartus() {
	pkgname="quartus"
	pkgver="10.0sp1"
	pkgdesc="Quartus II Web Edition Software Version 10.0 Service Pack 1 for Linux"
	arch=('i686' 'x86_64')
	url="https://www.altera.com/download/software/quartus-ii-we"
	legalurl="http://www.altera.com/common/legal.html"
	legalnotice="This is NOT FOSSoftware Please visit $legalurl before \
				proceeding. If you proceed it means that you understand \
				and agree with the above legal notice"
	src=(${FOSS_AUEB}sources/${pkgname}-linux-${pkgver}.sh)
	md5sum=('eab8466927e83c38d2a449842d3f372d')
}

function nessus() {
	pkgname="Nessus"
	pkgver="4.2.2"
	pkgdesc="Nessus, the network vulnerability scanner"
	url="http://www.tenable.com/nessus/"
	legalurl="http://www.nessus.org/download/index.php?product=nessus42-linux"
	legalnotice="This is NOT FOSSoftware Please visit $legalurl before \
				proceeding. If you proceed it means that you understand \
				and agree with the above legal notice"
	case "$(uname -m)" in
		"i686")		src="http://downloads.nessus.org/nessus3dl.php?file=${pkgname}-${pkgver}-linux-generic32.tar.gz\&licence_accept=yes\&t=03f10f511cb59f4d076d2a2428b42ae8"
					md5sum="fd976ebbc028e703ffc5969e43b31c79" ;;
		"x86_64")	src="http://downloads.nessus.org/nessus3dl.php?file=${pkgname}-${pkgver}-linux-generic64.tar.gz\&licence_accept=yes\&t=03f10f511cb59f4d076d2a2428b42ae8"
					md5sum="8f197f47748cea442551f2907c153558" ;;
		*)			echo "unknown architecture: "$(uname -m)". Assuming i686."
					src="http://downloads.nessus.org/nessus3dl.php?file=${pkgname}-${pkgver}-linux-generic32.tar.gz\&licence_accept=yes\&t=03f10f511cb59f4d076d2a2428b42ae8"
					md5sum="fd976ebbc028e703ffc5969e43b31c79" ;;
	esac
}
# }}}

# generic funcs {{{ 
# check for root priviledges
function check_root() {
	(( "$(id -u)" )) \
	&& echo "You must have root priviledges to run this script" \
	&& exit 1
}

# usage message
function usage() {
cat << EOF
usage: "$(basename "$0")" option suboption [distro]

	Options are:
	apps [app_opts]			application management
	wifi [wifi_opts]		wifi connection management
	
	Application options are:
	install				install all applications
	remove				remove all applications

	Wifi options are:
	connect				connect to wireless
	disconnect			disconnect from wireless

	distro				the linux distribution
EOF
exit 1
}

# log given input
function log() {
	echo "$@" >> "$LOG"
}

# not provided the distro, try to figure it out
# this is based on the LinuxStandardBase
function set_distro() {
	if [ -n "$1" ]
	then 
		DISTRO="$1" 
		[ -n "${PMSI["$DISTRO"]}" ] && set -- "${@:1:$#-1}" && return \
		|| echo "unknown distribution: "$DISTRO"" && usage
	fi
	DISTRO="$(lsb_release -i | cut -d":" -f2- | \
		awk '{ print $1 }' | tr [[:upper:]] [[:lower:]])"
	[ -n "${PMSI["$DISTRO"]}" ] && return
	DISTRO="$(lsb_release -d | cut -d":" -f2- | \
		awk '{ print $1 }' | tr [[:upper:]] [[:lower:]])"
	[ -n "${PMSI["$DISTRO"]}" ] && return
	echo "Cannot determine distribution. Please provide it to the script."
	usage
}
# }}}

# applications management {{{
# extract an archive
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

# clean build directory
function cleanbuild() {
	rm -r $BUILD_DIR/*
}

# get and extract remote archive
function getarchivedfiles() {
	wget "$source"
	extract "$pkgname"	
}

# FIXME what is $1 , where is this used ?!
# get required files
function getfiles() {
	getarchivedfiles 
	mv "$pkgname" "$1" 
}

# Build a package from source
function buildpkgs() {
	getarchivedfiles
	./configure --${CONF_FLAGS}
	make && make install
}

# Build the packages from source
function buildpkgs() {
	[ -e "$BUILD_DIR" ] || mkdir -p "$BUILD_DIR"
	local curpath="$PWD"
	cd "$BUILD_DIR"
	for pkgbuild_func in ${APPS["build"]}
	do
		$pkgbuild_func
		buildpkg
		cleanbuild
	done
}

# FIXME Install archived-ready packages
# TODO extract package to $VENDORS_DIR and link executables
function readypkgs() {
	echo ${APPS["extra"]}
	echo "not implemented yet"
}

# Install packages using PMS
function installpkgs() {
	${PMSI["$DISTRO"]} ${APPS["common"]} ${APPS["$DISTRO"]}
	(( $? )) && echo Failure || echo Success
}

# main install function
function install() {
	installpkgs
	buildpkgs
	readypkgs
}

# remove packages using PMS
function removepkgs() {
	${PMSR["$DISTRO"]} ${APPS["common"]} ${APPS["$DISTRO"]}
	(( $? )) && echo Failure || echo Success
}

# FIXME remove packages installed from source
function removebuildpkgs() {
	echo "not implemented yet"
}

# main remove function
function remove() { 
	removepkgs
	removebuildpkgs
}

# manage application installation
function apps() {
	case "$1" in
		install)	check_root; install ;;
		remove)		check_root; remove  ;;
		*)			echo "unknown argument: "$1"" && usage ;;
	esac
}
# }}}

# wifi management {{{
# find the interface
function set_iface() {
	[ -n "$IFACE" ] && return
	IFACE="$(iwconfig 2>&1 | grep -v "no\|^$" | head -1 | awk '{ print $1 }')"
	[ -z "$IFACE" ] && echo "No wireless interface found" && exit 1
}

# create wpa_supplicant configuration file
function wifi_conf() {
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

# try to close running network managers
function handle_nm() {
	[ "$1" == "start" ] && local action="start" || local action="stop"
	# find the initscripts
	[ -e "/etc/rc.d" ] && local RC_PATH="/etc/rc.d"
	[ -e "/etc/init.d" ] && local RC_PATH="/etc/init.d"
	[ -z "$RC_PATH" ] && echo "where are the init scripts stored ?" && return
	# check for common network managers
	[ -e "$RC_PATH/networkmanager" ] && "$RC_PATH/networkmanager" status
	(( ! $? )) && "$RC_PATH/networkmanager" $action && return
	[ -z "$RC_PATH/knetworkmanager" ] && "$RC_PATH/knetworkmanager" status
	(( ! $? )) && "$RC_PATH/knetworkmanager" $action && return
	[ -e "$RC_PATH/wicd" ] && "$RC_PATH/wicd" status
	(( ! $? )) && "$RC_PATH/wicd" $action && return
	echo "no active network managers found"
}

# connect to wifi
function connectwifi() {
	wifi_conf
	handle_nm "stop"
	ifconfig "$IFACE" down
	ifconfig "$IFACE" up
	wpa_supplicant -Dwext -i"$IFACE" -c"$WPACONF" 1>"$WPALOG" 2>"$WPAERR"
}

# disconnect from wifi
function disconnectwifi() {
	ifconfig "$IFACE" down
	handle_nm "start"
}

# manage wifi connection
function wifi() {
	case "$1" in
		connect)	check_root; set_iface; connectwifi ;;
		disconnect)	check_root; set_iface; disconnectwifii ;;
		*)			echo "unknown argument: "$1"" && usage ;;
	esac
}
# }}}  

(( $# > 3 )) && echo "too many arguments" && usage
set_distro $3
mkdir -p "$PREFIX"

case "$1" in 
	wifi)	shift; wifi "$@" ;;
	apps)	shift; apps "$@" ;;
	*)		echo "unknown argument: "$1"" && usage ;;
esac

# vim: set nonumber nospell foldmethod=marker:foldmarker={{{,}}}:foldlevel=0
