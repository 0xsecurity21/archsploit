#!/usr/bin/env bash

## Remove Previous Version
rm -f archlinux.conf
rm -f archlinux.sh

## Download Script and Configuration File
curl -o archsploit.conf https://raw.githubusercontent.com/archsploit/archsploit/master/archsploit.conf
curl -o archsploit.sh https://raw.githubusercontent.com/archsploit/archsploit/master/archsploit.sh

## Change User Permission
chmod +x archsploit.sh
