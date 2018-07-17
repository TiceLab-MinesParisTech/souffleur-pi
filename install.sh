#!/bin/bash

#Check privilege
if [ "$EUID" -ne 0 ]; then
	echo "Please run as root"
	exit
fi

#Global vars
SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"
CONF_PATH=$SCRIPT_PATH/conf

function copy_conf_file {
	SRC=$CONF_PATH$1
	DST=$1
	echo "Copy $DST"
	cp $SRC $DST
}

#Installation
echo "* Install dependencies"
apt-get install openssh-server bridge-utils hostapd dnsmasq avahi-daemon

echo "* Activate ssh daemon"
systemctl enable ssh.service

systemctl disable dhcpcd.service

echo "* Configure network"
copy_conf_file "/etc/network/interfaces"
systemctl restart networking.service

echo "* Configure Hostapd"
copy_conf_file /etc/hostapd/hostapd.conf
copy_conf_file /etc/default/hostapd
#systemctl unmask hostapd.service
systemctl enable hostapd.service

echo "* Configure Dnsmasq"
copy_conf_file /etc/dnsmasq.conf
copy_conf_file /etc/hosts
systemctl enable hostapd.service

echo "* Configure Avahi-daemon"
copy_conf_file /etc/hostname
copy_conf_file /etc/avahi/avahi-daemon.conf
systemctl enable avahi-daemon.service

echo "* Configure Souffleur"
copy_conf_file /etc/default/souffleur
systemctl restart souffleur.service
systemctl enable souffleur.service
