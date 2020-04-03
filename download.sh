#!/usr/bin/env bash

## Remove Previous Version
rm -f archlinux.conf
rm -f archlinux.sh

## Download Script and Configuration File
wget https://raw.githubusercontent.com/archsploit/archsploit/master/archsploit.conf
wget https://raw.githubusercontent.com/archsploit/archsploit/master/archsploit.sh

## Change User Permission
chmod +x archlinux.sh
