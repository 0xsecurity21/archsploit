#!/usr/bin/env bash

## ---------------- ##
## Define Variables ##
## ---------------- ##

## Colour Output
## -------------
color_d9534f="\033[01;31m"	# Issues/Errors
color_5cb85c="\033[01;32m"	# Success
color_f0ad4e="\033[01;33m"	# Warnings/Information
color_0275d8="\033[01;34m"	# Heading
color_revert="\033[00m"		# Normal

## Load Banner
## -----------
function showbanner()
{
	clear
	echo -e "${color_d9534f}                  _               _       _ _       ${color_revert}"
	echo -e "${color_d9534f}    __ _ _ __ ___| |__  ___ _ __ | | ___ (_) |_     ${color_revert}"
	echo -e "${color_d9534f}   / _' | '__/ __| '_ \/ __| '_ \| |/ _ \| | __|    ${color_revert}"
	echo -e "${color_d9534f}  | (_| | | | (__| | | \__ \ |_) | | (_) | | |_     ${color_revert}"
	echo -e "${color_d9534f}   \__,_|_|  \___|_| |_|___/ .__/|_|\___/|_|\__|    ${color_revert}"
	echo -e "${color_d9534f}                           |_|            v2.0.3    ${color_revert}"
	echo
	echo -e "${color_5cb85c} [i] [Package]: archsploit-deploy${color_revert}"
	echo -e "${color_5cb85c} [i] [Website]: https://archsploit.org${color_revert}"
  	echo
  	sleep 1s
}

## Load Header
## -----------
function loadheader()
{
	echo
    echo -e "${color_0275d8}${@}${color_revert}"
	sleep 2
}

## Load Notice
## -----------
function loadnotice()
{
	echo -e "${color_5cb85c}${@}${color_revert}"
	sleep 5
}

## Load Status
## -----------
function loadstatus()
{
    color_d9534f=$(tput setaf 1)
    color_5cb85c=$(tput setaf 2)
    color_f0ad4e=$(tput setaf 3)
    color_0275d8=$(tput setaf 4)
    color_revert=$(tput sgr0)

    message=$1
    display="[$2]"

    if [ "$3" == "issue" ];
    then
        return="$color_d9534f${display}$color_revert"
    elif [ "$3" == "valid" ];
    then
        return="$color_5cb85c${display}$color_revert"
    elif [ "$3" == "warning" ];
    then
        return="$color_f0ad4e${display}$color_revert"
    elif [ "$3" == "info" ];
    then
        return="$color_f0ad4e${display}$color_revert"
    else
        return="$color_revert${display}$color_revert"
    fi

    let COL=$(tput cols)-${#message}+${#return}-${#display}

    echo -n $message
    printf "%${COL}s\n"  "$return"
}

## Check Internet status
## ---------------------
function checkinternet()
{
	for i in {1..10};
	do
		ping -c 1 -W ${i} www.google.com &>/dev/null && break;
	done

	if [[ "$?" -ne 0 ]];
	then
		cd /tmp/
		echo
		echo -e " ${color_d9534f}[!]${color_revert} An unknown error occured ~ Possible DNS issues or no Internet connection"
		echo -e " ${color_d9534f}[!]${color_revert} Quitting ..."
		echo -e "\n"
		exit 1
	fi
}

## Display Warning
## ---------------
function warning()
{
    echo -e "${color_0275d8} ** Welcome to ArchSploit Installer Script **${color_revert}"
    echo
    echo -e "${color_d9534f} [!] This script will deploy ArchSploit on your system${color_revert}"
    echo -e "${color_d9534f} [!] It's recommended to backup all your data before to proceed${color_revert}"
    echo
    read -p " [?] Do you want to continue ? [y/N] " yn
    case $yn in
        [Yy]* )
			clear
            ;;
        [Nn]* )
            exit
            ;;
        * )
            exit
            ;;
    esac
}

## Load Config File
## ----------------
function loadconfig()
{
	source archsploit.conf
}

## Install Kernels
## ---------------
function kernels()
{
	loadheader "# Step: Install Kernels"
	sudo pacman -Syu linux-headers --noconfirm --needed >/dev/null 2>&1
	loadstatus " [+] Linux Headers" "OK" "valid"

	if [ -n "$kernels_install" ];
	then
		sudo pacman -Syu $kernels_install --noconfirm --needed >/dev/null 2>&1
		loadstatus " [+] Linux Custom Kernels" "OK" "valid"
    fi

	if [ -n "$kernels_headers" ];
	then
		sudo pacman -Syu $kernels_headers --noconfirm --needed >/dev/null 2>&1
		loadstatus " [+] Linux Custom Headers" "OK" "valid"
    fi
}

## Configuration
## -------------
function configuration()
{
	loadheader "# Step: Setup Configuration"
	arch-chroot /mnt timedatectl set-timezone $timezone
	arch-chroot /mnt hwclock --systohc
	loadstatus " [+] System Timezone" "OK" "valid"
	loadstatus " [+] System Clock" "OK" "valid"

	arch-chroot /mnt sed -i "s/#$locale/$locale/" /etc/locale.gen
	arch-chroot /mnt locale-gen >/dev/null 2>&1
	echo "LANG=$language.$charset" >> /mnt/etc/locale.conf
	echo "LANGUAGE=$language" >> /mnt/etc/locale.conf
	echo "KEYMAP=$keyboard" > /mnt/etc/vconsole.conf
	loadstatus " [+] System Language" "OK" "valid"

	echo "$user_hostname" > /mnt/etc/hostname
	pacman -Syu dhcpcd networkmanager --noconfirm --needed >/dev/null 2>&1
	systemctl enable NetworkManager.service >/dev/null 2>&1
	systemctl enable dhcpcd.service >/dev/null 2>&1

	echo -e "127.0.0.1\tlocalhost" >> /mnt/etc/hosts
	echo -e "::1\t\tlocalhost" >> /mnt/etc/hosts
	echo -e "127.0.1.1\t$user_hostname" >> /mnt/etc/hosts
	loadstatus " [+] System Hostname" "OK" "valid"
	loadstatus " [+] System Network" "OK" "valid"

	printf "$root_password\n$root_password" | passwd >/dev/null 2>&1
	useradd -m -g users -G wheel,storage,optical,power -s /bin/bash $user_username
	printf "$user_password\n$user_password" | passwd $user_username >/dev/null 2>&1
	pacman -Syu bash-completion git sudo xdg-user-dirs --noconfirm --needed >/dev/null 2>&1
	sed -i "s/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/" /etc/sudoers
	loadstatus " [+] System Users" "OK" "valid"
}

## Clone Repository
## ----------------
function clonerepo()
{
	loadheader "# Step: Clone Repository"
	cd /tmp/
	sudo git clone https://github.com/archsploit/archsploit >/dev/null 2>&1
	loadstatus " [+] Clone Repository" "OK" "valid"
}

## Add Release
## -----------
function addrelease()
{
	loadheader "# Step: Add Release"
	mkdir -p /etc/archsploit/release/
	mkdir -p /etc/archsploit/packages/
	echo "Distributor ID: ArchSploit" >> /etc/archsploit/release/release.md
	echo "Description: ArchSploit Xisqu v2.0.3" >> /etc/archsploit/release/release.md
	echo "Release: 2.0.3" >> /etc/archsploit/release/release.md
	echo "Codename: Xisqu" >> /etc/archsploit/release/release.md
	echo "Build: 20200515" >> /etc/archsploit/release/release.md
	loadstatus " [+] Add Release" "OK" "valid"
}

## Optimize Virtual Machine
## ------------------------
function virtualmachine()
{
	loadheader "# Step: Optimize Virtual Machine"
    if [ -z "$kernels_install" ];
	then
		sudo pacman -Syu virtualbox-guest-utils virtualbox-guest-dkms --noconfirm --needed >/dev/null 2>&1
		loadstatus " [+] Standard VM Kernels" "OK" "valid"
    else
		sudo pacman -Syu virtualbox-guest-utils virtualbox-guest-modules-arch --noconfirm --needed >/dev/null 2>&1
		loadstatus " [+] Custom VM Kernels" "OK" "valid"
    fi
}

## Configure MultiLib
## ------------------
function multilib()
{
	loadheader "# Step: Configure MultiLib"
	if [ -f "/tmp/archsploit/etc/pacman.conf" ];
	then
		mv /etc/pacman.conf /etc/pacman.conf.bak
		mv /tmp/archsploit/etc/pacman.conf /etc/
		sudo pacman -Sy >/dev/null 2>&1
		loadstatus " [+] Multilib Configuration" "OK" "valid"
	else
		loadstatus " [*] Multilib Configuration" "!!" "issue"
	fi
}

## Install Packages
## ----------------
function packages()
{
	loadheader "# Step: Install Packages()"

	## Basic Packages
	## --------------
	if [ "$pacman_packages_roller" != "null" ];
	then
        sudo pacman -Syu $pacman_packages_roller --noconfirm --needed >/dev/null 2>&1
		loadstatus " [+] File Roller Packages" "OK" "valid"
    fi

	if [ "$pacman_packages_common" != "null" ];
	then
        sudo pacman -Syu $pacman_packages_common --noconfirm --needed >/dev/null 2>&1
		loadstatus " [+] Common Tools Packages" "OK" "valid"
    fi

	if [ "$pacman_packages_utilities" != "null" ];
	then
        sudo pacman -Syu $pacman_packages_utilities --noconfirm --needed >/dev/null 2>&1
		loadstatus " [+] Utilities Packages" "OK" "valid"
    fi

	if [ "$pacman_packages_security" != "null" ];
	then
        sudo pacman -Syu $pacman_packages_security --noconfirm --needed >/dev/null 2>&1
		loadstatus " [+] Security Packages" "OK" "valid"
    fi

	if [ "$pacman_packages_developer" != "null" ];
	then
        sudo pacman -Syu $pacman_packages_developer --noconfirm --needed >/dev/null 2>&1
		loadstatus " [+] Developer Packages" "OK" "valid"
    fi

	if [ "$pacman_packages_python" != "null" ];
	then
        sudo pacman -Syu $pacman_packages_python --noconfirm --needed >/dev/null 2>&1
		loadstatus " [+] Python Packages" "OK" "valid"
    fi

	## Install and Configure DnsMasq
	## -----------------------------
	sudo sed -i "s/#port=5353/port=5353/" /etc/dnsmasq.conf
	sudo systemctl enable dnsmasq.service >/dev/null 2>&1
	loadstatus " [+] DnsMasq Configuration" "OK" "valid"

	## Configure Apache
	## ----------------
	sudo sed -i "s/#LoadModule unique_id_module modules/LoadModule unique_id_module modules/" /etc/httpd/conf/httpd.conf
	if [ -f "/tmp/archsploit/srv/http/index.html" ];
	then
		mv /tmp/archsploit/srv/http/index.html /srv/http/
		sudo systemctl enable httpd.service >/dev/null 2>&1
		loadstatus " [+] Apache Configuration" "OK" "valid"
	else
		loadstatus " [*] Apache Configuration" "!!" "issue"
	fi

	## Configure MySQL Server
	## ----------------------
	sudo mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql >/dev/null 2>&1
	sudo systemctl enable mysqld.service >/dev/null 2>&1
	loadstatus " [+] MySQL Configuration" "OK" "valid"

	## Install PHP Components
	## ----------------------
	mkdir /var/log/php
	if [ -d "/var/log/php" ];
	then
		chown http:root /var/log/php
		loadstatus " [+] PHP Logs Directory" "OK" "valid"
	else
		loadstatus " [*] PHP Logs Directory" "!!" "issue"
	fi

	if [ -f "/tmp/archsploit/etc/httpd/conf/httpd.conf" ];
	then
		mv /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.bak
		mv /tmp/archsploit/etc/httpd/conf/httpd.conf /etc/httpd/conf/
		loadstatus " [+] PHP Configuration" "OK" "valid"
	else
		loadstatus " [*] PHP Configuration" "!!" "issue"
	fi

	if [ -f "/tmp/archsploit/srv/http/info.php" ];
	then
		mv /tmp/archsploit/srv/http/info.php /srv/http/
		loadstatus " [+] PHP Info File" "OK" "valid"
	else
		loadstatus " [*] PHP Info File" "!!" "issue"
	fi
}

## Terminate Installation
## ----------------------
function terminate()
{
	loadheader "# Step: Terminate Installation"

	## Configure User Bashrc
	## ---------------------
	if [ -f "/tmp/archsploit/etc/skel/bashrc.txt" ];
	then
		rm -f /home/$user_username/.bashrc
		mv /tmp/archsploit/etc/skel/bashrc.txt /home/$user_username/.bashrc
		chown 1000:users /home/$user_username/.bashrc
		loadstatus " [+] Bashrc Configuration" "OK" "valid"
	else
		loadstatus " [*] Bashrc Configuration" "!!" "issue"
	fi

	## Configure Bash History
	## ----------------------
	echo "# Bash History" >> /home/$user_username/.bash_logout
	echo "# ------------" >> /home/$user_username/.bash_logout
	echo "history -c" >> /home/$user_username/.bash_logout
	loadstatus " [+] History Configuration" "OK" "valid"

	## Configure ArchSploit-Clean
	## --------------------------
	if [ -f "/tmp/archsploit/usr/local/bin/archsploit-clean" ];
	then
		mv /tmp/archsploit/usr/local/bin/archsploit-clean /usr/local/bin/archsploit-clean
		chmod +x /usr/local/bin/archsploit-clean
		loadstatus " [+] Arch Clean Configuration" "OK" "valid"
	else
		loadstatus " [*] Arch Clean Configuration" "!!" "issue"
	fi

	## Configure ArchSploit-Gresource
	## ------------------------------
	if [ -f "/tmp/archsploit/usr/local/bin/archsploit-gresource" ];
	then
		mv /tmp/archsploit/usr/local/bin/archsploit-gresource /usr/local/bin/archsploit-gresource
		chmod +x /usr/local/bin/archsploit-gresource
		loadstatus " [+] Arch Gresource Configuration" "OK" "valid"
	else
		loadstatus " [*] Arch Gresource Configuration" "!!" "issue"
	fi

	## Configure ArchSploit-Packages
	## -----------------------------
	if [ -f "/tmp/archsploit/usr/local/bin/archsploit-packages" ];
	then
		mv /tmp/archsploit/usr/local/bin/archsploit-packages /usr/local/bin/archsploit-packages
		chmod +x /usr/local/bin/archsploit-packages
		loadstatus " [+] Arch Packages Configuration" "OK" "valid"
	else
		loadstatus " [*] Arch Packages Configuration" "!!" "issue"
	fi

	## Configure ArchSploit-Update
	## ---------------------------
	if [ -f "/tmp/archsploit/usr/local/bin/archsploit-update" ];
	then
		mv /tmp/archsploit/usr/local/bin/archsploit-update /usr/local/bin/archsploit-update
		chmod +x /usr/local/bin/archsploit-update
		loadstatus " [+] Arch Update Configuration" "OK" "valid"
	else
		loadstatus " [*] Arch Update Configuration" "!!" "issue"
	fi

	## Clean Deskop Launchers
	## ----------------------
	rm -f /usr/share/applications/lstopo.desktop
	rm -f /usr/share/applications/java-java-openjdk.desktop
	rm -f /usr/share/applications/jconsole-java-openjdk.desktop
	rm -f /usr/share/applications/jshell-java-openjdk.desktop
	rm -f /usr/share/applications/qv4l2.desktop
	rm -f /usr/share/applications/qvidcap.desktop
	loadstatus " [+] Clean Deskop Launchers" "OK" "valid"

	## --------------------- ##
	## CLEAN TEMPORARY FILES ##
	## --------------------- ##

	## Delete Machine Logs
	## -------------------
	find /var/log/ -type f -name '*.gz' -exec sudo rm -f {} \; >/dev/null 2>&1
	find /var/log/ -type f -name '*.old' -exec sudo rm -f {} \; >/dev/null 2>&1
	find /var/log/ -type f -name '*.1' -exec sudo rm -f {} \; >/dev/null 2>&1
	find /var/log/ -type f -name '*.log' -exec sudo rm -f {} \; >/dev/null 2>&1
	loadstatus " [+] Clean System Logs" "OK" "valid"

	## Delete Temporary Folders and Files
	## ----------------------------------
	rm -rf /tmp/*
	loadstatus " [+] Clean Temporary Files" "OK" "valid"

	loadnotice "ArchSploit Installer Completed"
	sleep 5
}

## Launch
## ------
function launch()
{
	clear
    showbanner
	loadconfig
	checkinternet
    warning
	kernels
	configuration
	clonerepo
	addrelease

	if [ "$virtualbox" == "true" ];
	then
        virtualmachine
    fi

	multilib
	packages
	terminate
}

## -------- ##
## Callback ##
## -------- ##

launch
