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

# FIXME crete arch-like vars for each package, each
# FIXME parckege will be a function that resets the vars (url/pkgname/etc)
# Applications that need to be built from source {{{

# custom pkgbuilds
function omnet() {
	pkgname="omnetpp"
	pkgver=4.1
	pkgrel=41
	pkgdesc="OMNeT++ is an extensible, modular, component-based C++ simulation\
	 library and framework, primarily for building network simulators."
	arch=('i686' 'x86_64')
	url="http://www.omnetpp.org/"
	license=('ACADEMIC PUBLIC LICENSE')
	groups=('none')
	depends=('akaroa')
	source=(${FOSS_AUEB}sources/${pkgname}-${pkgver}-src.tgz)
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
	source=(${FOSS_AUEB}sources/${pkgname}.tar.gz)
	md5sums=('146558e8256f2b7577fb825fdc76a04f')
}

function xampp() {
	pkgname="xampp"
	pkgver="1.7.3a"
	pkgrel="1.7.3a"
	pkgdesc="The Linux version of XAMPP"
	arch=('i686' 'x86_64')
	url="http://www.apachefriends.org/en/xampp-linux.html"
	source=(${FOSS_AUEB}sources/${pkgname}-linux-${pkgver}.tar.gz)
	md5sum=('89c13779cf6f0925d5c1c400d31a1cc3')
}

# ALTERA LICENSE TO COPY INFORMATION {{{
#
#You are licensed to download and copy documentation, software, and other
# materials from this website (including the myAltera and Self-Service 
#Licensing Center portions of this website) provided you agree to the 
#following terms and conditions:
#
#You may use the Materials for informational, non-commercial purposes only.
#You may not alter or modify the Materials in any way.
#You may not use any graphics separate from any accompanying text.
#You may distribute copies of the documentation available at this website 
#only to customers and potential customers of Altera® products. However, 
#you may not charge them for such use. Any other distribution to third parties 
#is prohibited unless you obtain the prior written consent of Altera.
#You may use any software provided on this website provided that you agree 
#to be bound by the terms and conditions of Altera's Program Subscription 
#License Agreement or other applicable license agreement. Unless expressly 
#permitted, you may not modify, reverse engineer, or disassemble any software.
#You may not install any software that is accompanied by or includes a 
#License Agreement unless you first have agreed to the License Agreement terms. 
#If no end user License Agreement accompanies or is included with the software, 
#then such software shall be deemed to be Materials hereunder and this Legal 
#Notice shall govern your use of such software. FURTHER REPRODUCTION OR DISTRIBUTION 
#OF ANY SOFTWARE IS EXPRESSLY PROHIBITED, UNLESS SUCH REPRODUCTION OR DISTRIBUTION 
#IS EXPRESSLY PERMITTED BY THE LICENSE AGREEMENT ACCOMPANYING OR INCLUDED WITH SUCH SOFTWARE.
#You may not use the Materials in any way that may be adverse to Altera´s interests.
#You may not use this website (including, without limitation, any software, 
#documentation, or other Materials you may obtain through your use of this website) 
#(1) in a manner that violates any local, state, national, foreign or 
#international statutes, regulations, rules, orders, treaties, or other laws, 
#(2) to interfere with or disrupt the operation of the website or servers 
#or networks connected to the website, or (3) attempt to gain unauthorized 
#access to any portion of the website or any other accounts, computer systems, 
#servers, or networks connected to the website, whether through hacking, 
#password mining, or any other means.
#All copies of materials that you download or copy from this website must 
#include a copy of this Legal Notice.
#
#Failure to comply with these terms and conditions will terminate the license.
# }}}
function quartus() {
	pkgname="quartus"
	pkgver="10.0sp1"
	pkgrel="10.0"
	pkgdesc="Quartus II Web Edition Software Version 10.0 Service Pack 1 for Linux"
	arch=('i686' 'x86_64')
	url="https://www.altera.com/download/software/quartus-ii-we"
	legalurl="http://www.altera.com/common/legal.html"
	legalnotice="This is NOT FOSSoftware Please visit \
	 $legalurl before proceeding.\
	If you proceed it means that you understand and agree with the above legal notice"
	source=(${FOSS_AUEB}sources/${pkgname}-linux-${pkgver}.sh)
	md5sum=('eab8466927e83c38d2a449842d3f372d')
}

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

# get and extract remote archive
function getarchivedfiles() {
	wget "$source"
	extract "$pkgname"	
}

# get required files FIXME what is $1 , where is this used ?!
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

# FIXME Build the packages from source
function buildpkgs() {
	[ -e "$BUILD_DIR" ] || mkdir -p "$BUILD_DIR"
	local curpath="$PWD"
	cd "$BUILD_DIR"
	for app in ${APPS["build"]}
	do
		$app # FIXME call the app-function :S
		buildpkg
		cleanbuild
	done
}

# FIXME Install archived-ready packages
function readypkgs() {
	echo ${APPS["extra"]}
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
