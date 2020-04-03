#!/usr/bin/env bash
set -e

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
	echo -e "${color_d9534f}                           |_|            v2.0.2    ${color_revert}"
	echo
	echo -e "${color_5cb85c} [i] [Package]: archsploit-installer${color_revert}"
	echo -e "${color_5cb85c} [i] [Website]: https://neoslab.com${color_revert}"
  	echo
  	sleep 1s
}

## Load Status
## -----------
loadstatus()
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
    echo -e "${color_0275d8} ** Welcome to Arch Linux Installation Script **${color_revert}"
    echo
    echo -e "${color_d9534f} [!] This script will format all your system partitions${color_revert}"
    echo -e "${color_d9534f} [!] All your data and content will be permanently lost${color_revert}"
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

## Load Keyboard Settings
## ----------------------
function setkeyboard()
{
	echo
    echo -e "${color_0275d8}# Step: setkeyboard()${color_revert}"
	sleep 5

	loadkeys $keyboard
	loadstatus " [+] Keyboard Settings" "OK" "valid"
}

## Detect System Config
## --------------------
function detectsystem()
{
	echo
    echo -e "${color_0275d8}# Step: detectsystem()${color_revert}"
	sleep 5

    if [ -d /sys/firmware/efi ];
	then
        system_mode="uefi"
    else
		system_mode="bios"
    fi

    if [ -n "$(echo $hdd_label | grep "^/dev/[a-z]d[a-z]")" ];
	then
        disk_sata="true"
		disk_name="SATA"
    elif [ -n "$(echo $hdd_label | grep "^/dev/nvme")" ];
	then
        disk_nvme="true"
		disk_name="NVMe"
    elif [ -n "$(echo $hdd_label | grep "^/dev/mmc")" ];
	then
        disk_mmcd="true"
		disk_name="MMC"
    fi

    if [ -n "$(lscpu | grep GenuineIntel)" ];
	then
        intel_chipset="true"
    fi

	loadstatus " [+] System Mode" "$system_mode" "valid"
	loadstatus " [+] Disk Type" "$disk_name" "valid"
	loadstatus " [+] Disk TRIM" "$hdd_trim" "valid"
	loadstatus " [+] Intel Chipset" "$intel_chipset" "valid"
	loadstatus " [+] VirtualBox" "$virtualbox" "valid"
}

## Create Disk Partitions
## ----------------------
function partitions()
{
	echo
    echo -e "${color_0275d8}# Step: partitions()${color_revert}"
	sleep 5

    sgdisk --zap-all $hdd_label >/dev/null 2>&1
    wipefs -a $hdd_label >/dev/null 2>&1

    if [ "$system_mode" == "uefi" ];
	then
        if [ "$disk_sata" == "true" ];
		then
            part_boot="${hdd_label}1"
            part_root="${hdd_label}2"
        fi

        if [ "$disk_nvme" == "true" ];
		then
            part_boot="${hdd_label}p1"
            part_root="${hdd_label}p2"
        fi

        if [ "$disk_mmcd" == "true" ];
		then
            part_boot="${hdd_label}p1"
            part_root="${hdd_label}p2"
        fi

        parted -s $hdd_label mklabel gpt mkpart primary fat32 1MiB 512MiB mkpart primary $hdd_system 512MiB 100% set 1 boot on
        sgdisk -t=1:ef00 $hdd_label >/dev/null 2>&1
        sgdisk -t=2:8e00 $hdd_label >/dev/null 2>&1
    fi

    if [ "$system_mode" == "bios" ];
	then
        if [ "$disk_sata" == "true" ];
		then
            part_bios="${hdd_label}1"
            part_boot="${hdd_label}2"
            part_root="${hdd_label}3"
        fi

        if [ "$disk_nvme" == "true" ];
		then
            part_bios="${hdd_label}p1"
            part_boot="${hdd_label}p2"
            part_root="${hdd_label}p3"
        fi

        if [ "$disk_mmcd" == "true" ];
		then
            part_bios="${hdd_label}p1"
            part_boot="${hdd_label}p2"
            part_root="${hdd_label}p3"
        fi

        parted -s $hdd_label mklabel gpt mkpart primary fat32 1MiB 128MiB mkpart primary $hdd_system 128MiB 512MiB mkpart primary $hdd_system 512MiB 100% set 1 boot on
        sgdisk -t=1:ef02 $hdd_label >/dev/null 2>&1
        sgdisk -t=3:8e00 $hdd_label >/dev/null 2>&1
    fi

	echo -n "$hdd_passkey" | cryptsetup --key-size=512 --key-file=- luksFormat --type luks2 $part_root
    echo -n "$hdd_passkey" | cryptsetup --key-file=- open $part_root lvm
	sleep 15

    pvcreate /dev/mapper/lvm >/dev/null 2>&1
    vgcreate vg /dev/mapper/lvm >/dev/null 2>&1
    lvcreate -l 100%FREE -n root vg >/dev/null 2>&1

	path_root="/dev/mapper/vg-root"
	if [ "$system_mode" == "uefi" ];
	then
        wipefs -a $part_boot >/dev/null 2>&1
        wipefs -a $path_root >/dev/null 2>&1
        mkfs.fat -n ESP -F32 $part_boot >/dev/null 2>&1
        mkfs."$hdd_system" -L root $path_root >/dev/null 2>&1
		loadstatus " [+] UEFI Partitions" "OK" "valid"
    fi

    if [ "$system_mode" == "bios" ];
	then
        wipefs -a $part_bios >/dev/null 2>&1
        wipefs -a $part_boot >/dev/null 2>&1
        wipefs -a $path_root >/dev/null 2>&1
        mkfs.fat -n BIOS -F32 $part_bios >/dev/null 2>&1
        mkfs."$hdd_system" -L boot $part_boot >/dev/null 2>&1
        mkfs."$hdd_system" -L root $path_root >/dev/null 2>&1
		loadstatus " [+] BIOS Partitions" "OK" "valid"
    fi

	if [ "$hdd_trim" == "true" ];
	then
        part_opts="defaults,noatime"
		loadstatus " [+] TRIM Options" "OK" "valid"
    fi

    mount -o "$part_opts" "$path_root" /mnt
    mkdir /mnt/boot
    mount -o "$part_opts" "$part_boot" /mnt/boot
	loadstatus " [+] Mount Partitions" "OK" "valid"

    if [ -n "$hdd_swap" -a "$hdd_system" != "btrfs" ];
	then
        fallocate -l $hdd_swap /mnt/swap >/dev/null 2>&1
        chmod 600 /mnt/swap
        mkswap /mnt/swap >/dev/null 2>&1
		loadstatus " [+] Disk SWAP" "OK" "valid"
    fi
}

## Load Mirror
## -----------
function loadmirror()
{
	echo
    echo -e "${color_0275d8}# Step: loadmirror()${color_revert}"
	sleep 5

	pacman -Syy >/dev/null 2>&1
	pacman -S "reflector" --noconfirm --needed >/dev/null 2>&1
	cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
	reflector -c "FR" -f 12 -l 10 -n 12 --save /etc/pacman.d/mirrorlist
	loadstatus " [+] Configure Mirror" "OK" "valid"
}

## Install Base System
## -------------------
function basesystem()
{
	echo
    echo -e "${color_0275d8}# Step: basesystem()${color_revert}"
	sleep 5

	pacstrap /mnt base base-devel git linux linux-firmware nano net-tools >/dev/null 2>&1
	loadstatus " [+] Base System" "OK" "valid"
}

## Install Kernels
## ---------------
function kernels()
{
	echo
    echo -e "${color_0275d8}# Step: kernels()${color_revert}"
	sleep 5

	arch-chroot /mnt pacman -Syu linux-headers --noconfirm --needed >/dev/null 2>&1
	loadstatus " [+] Linux Headers" "OK" "valid"

	if [ -n "$kernels_install" ];
	then
		arch-chroot /mnt pacman -Syu $kernels_install --noconfirm --needed >/dev/null 2>&1
		loadstatus " [+] Linux Custom Kernels" "OK" "valid"
    fi

	if [ -n "$kernels_headers" ];
	then
		arch-chroot /mnt pacman -Syu $kernels_headers --noconfirm --needed >/dev/null 2>&1
		loadstatus " [+] Linux Custom Headers" "OK" "valid"
    fi
}

## Build FSTAB
## -----------
function buildfstab()
{
	echo
	echo -e "${color_0275d8}# Step: buildfstab()${color_revert}"
	sleep 5

	genfstab -U /mnt >> /mnt/etc/fstab
	cat /mnt/etc/fstab >/dev/null 2>&1

	if [ -n "$hdd_swap" ];
	then
		echo "# Swap" >> /mnt/etc/fstab
		echo "/swap none swap defaults 0 0" >> /mnt/etc/fstab
		echo "" >> /mnt/etc/fstab
		echo "vm.swappiness=10" > /mnt/etc/sysctl.d/99-sysctl.conf
    fi

	if [ "$hdd_trim" == "true" ];
	then
		arch-chroot /mnt sed -i "s/relatime/noatime/" /etc/fstab
		arch-chroot /mnt systemctl enable fstrim.timer >/dev/null 2>&1
    fi

	loadstatus " [+] Genfstab File" "OK" "valid"
}

## Configuration
## -------------
function configuration()
{
	echo
	echo -e "${color_0275d8}# Step: configuration()${color_revert}"
	sleep 5

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
	arch-chroot /mnt pacman -Syu dhcpcd networkmanager --noconfirm --needed >/dev/null 2>&1
	arch-chroot /mnt systemctl enable NetworkManager.service >/dev/null 2>&1
	arch-chroot /mnt systemctl enable dhcpcd.service >/dev/null 2>&1

	echo -e "127.0.0.1\tlocalhost" >> /mnt/etc/hosts
	echo -e "::1\t\tlocalhost" >> /mnt/etc/hosts
	echo -e "127.0.1.1\t$user_hostname" >> /mnt/etc/hosts
	loadstatus " [+] System Hostname" "OK" "valid"
	loadstatus " [+] System Network" "OK" "valid"

	printf "$root_password\n$root_password" | arch-chroot /mnt passwd >/dev/null 2>&1
	arch-chroot /mnt useradd -m -g users -G wheel,storage,optical,power -s /bin/bash $user_username
	printf "$user_password\n$user_password" | arch-chroot /mnt passwd $user_username >/dev/null 2>&1
	arch-chroot /mnt pacman -Syu bash-completion sudo xdg-user-dirs --noconfirm --needed >/dev/null 2>&1
	arch-chroot /mnt sed -i "s/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/" /etc/sudoers
	loadstatus " [+] System Users" "OK" "valid"
}

## Clone Repository
## ----------------
function clonerepository()
{
	echo
	echo -e "${color_0275d8}# Step: clonerepository()${color_revert}"
	sleep 5

	arch-chroot /mnt git clone https://github.com/archsploit/archsploit >/dev/null 2>&1
	mv /mnt/archsploit /mnt/tmp
	loadstatus " [+] Clone Repository" "OK" "valid"
}

## Optimize Virtual Machine
## ------------------------
function virtualmachine()
{
	echo
	echo -e "${color_0275d8}# Step: virtualmachine()${color_revert}"
	sleep 5

    if [ -z "$kernels_install" ];
	then
		arch-chroot /mnt pacman -Syu virtualbox-guest-utils virtualbox-guest-dkms --noconfirm --needed >/dev/null 2>&1
		loadstatus " [+] Standard VM Kernels" "OK" "valid"
    else
		arch-chroot /mnt pacman -Syu virtualbox-guest-utils virtualbox-guest-modules-arch --noconfirm --needed >/dev/null 2>&1
		loadstatus " [+] Custom VM Kernels" "OK" "valid"
    fi
}

## Configure Mkinitcpio
## --------------------
function mkinitcpio()
{
	echo
	echo -e "${color_0275d8}# Step: mkinitcpio()${color_revert}"
	sleep 5

	arch-chroot /mnt pacman -Syu lvm2 --noconfirm --needed >/dev/null 2>&1
	arch-chroot /mnt sed -i "s/ block / block keyboard keymap /" /etc/mkinitcpio.conf
	arch-chroot /mnt sed -i "s/ filesystems keyboard / encrypt lvm2 filesystems /" /etc/mkinitcpio.conf
	arch-chroot /mnt sed -i "s/#COMPRESSION=\"${kernels_deflate}\"/COMPRESSION=\"${kernels_deflate}\"/" /etc/mkinitcpio.conf
	arch-chroot /mnt mkinitcpio -P >/dev/null 2>&1
	loadstatus " [+] Mkinitcpio Configuration" "OK" "valid"
}

## Setup Bootloader
## ----------------
function bootloader()
{
	echo
	echo -e "${color_0275d8}# Step: bootloader()${color_revert}"
	sleep 5

	if [ "$intel_chipset" == "true" -a "$virtualbox" != "true" ];
	then
        arch-chroot /mnt pacman -Syu intel-ucode --noconfirm --needed >/dev/null 2>&1
		loadstatus " [+] Intel Microcode" "OK" "valid"
    fi

	if [ "$system_mode" == "uefi" ];
	then
        partuuid=$(blkid -s PARTUUID -o value /dev/sda2)
    fi

    if [ "$system_mode" == "bios" ];
	then
        partuuid=$(blkid -s PARTUUID -o value /dev/sda3)
    fi

	if [ "$hdd_trim" == "true" ];
	then
		grub_cmdline_linux=$(echo cryptdevice=PARTUUID=${partuuid}:lvm:allow-discards)
	else
		grub_cmdline_linux=$(echo cryptdevice=PARTUUID=${partuuid}:lvm)
    fi

	arch-chroot /mnt pacman -Syu grub dosfstools --noconfirm --needed >/dev/null 2>&1
	arch-chroot /mnt sed -i "s/GRUB_DEFAULT=0/GRUB_DEFAULT=saved/" /etc/default/grub
	arch-chroot /mnt sed -i "s/#GRUB_SAVEDEFAULT=\"true\"/GRUB_SAVEDEFAULT=\"true\"/" /etc/default/grub
	arch-chroot /mnt sed -i -E "s/GRUB_CMDLINE_LINUX_DEFAULT=\"(.*)\"/GRUB_CMDLINE_LINUX_DEFAULT=\"quiet splash fastboot\"/" /etc/default/grub
	arch-chroot /mnt sed -i "s/GRUB_CMDLINE_LINUX=\"\"/GRUB_CMDLINE_LINUX=\"$grub_cmdline_linux\"/" /etc/default/grub
	echo "" >> /mnt/etc/default/grub
	echo "# Arch Linux" >> /mnt/etc/default/grub
	echo "GRUB_DISABLE_SUBMENU=y" >> /mnt/etc/default/grub

	if [ "$system_mode" == "uefi" ];
	then
		arch-chroot /mnt pacman -Syu efibootmgr --noconfirm --needed >/dev/null 2>&1
		arch-chroot /mnt grub-install --target=x86_64-efi --bootloader-id=grub --efi-directory=/boot --recheck >/dev/null 2>&1
		loadstatus " [+] UEFI Bootloader" "OK" "valid"
    fi

    if [ "$system_mode" == "bios" ];
	then
        arch-chroot /mnt grub-install --target=i386-pc --recheck /dev/sda >/dev/null 2>&1
		loadstatus " [+] BIOS Bootloader" "OK" "valid"
    fi

	arch-chroot /mnt grub-mkconfig -o "/boot/grub/grub.cfg" >/dev/null 2>&1
	loadstatus " [+] GRUB Configuration" "OK" "valid"

	if [ "$virtualbox" == "true" ];
	then
        echo -n "\EFI\grub\grubx64.efi" > "/mnt/boot/startup.nsh"
		loadstatus " [+] GRUB Virtualbox" "OK" "valid"
    fi
}

## Configure MultiLib
## ------------------
function multilib()
{
	echo
	echo -e "${color_0275d8}# Step: multilib()${color_revert}"
	sleep 5

	if [ -f "/mnt/tmp/archsploit/etc/pacman.conf" ];
	then
		mv /mnt/etc/pacman.conf /mnt/etc/pacman.conf.bak
		mv /mnt/tmp/archsploit/etc/pacman.conf /mnt/etc/
		arch-chroot /mnt pacman -Sy >/dev/null 2>&1
		loadstatus " [+] Multilib Configuration" "OK" "valid"
	else
		loadstatus " [+] Multilib Configuration" "Error" "issue"
	fi
}

## Install and Configure ALSA
## --------------------------
function alsautils()
{
	echo
	echo -e "${color_0275d8}# Step: alsautils()${color_revert}"
	sleep 5

	arch-chroot /mnt pacman -Syu alsa-utils pulseaudio --noconfirm --needed >/dev/null 2>&1
	arch-chroot /mnt pacman -Syu alsa-oss alsa-lib --noconfirm --needed >/dev/null 2>&1
	arch-chroot /mnt amixer sset Master unmute >/dev/null 2>&1
	loadstatus " [+] ALSA Configuration" "OK" "valid"
}

## Install Display Drivers
## -----------------------
function displaydrivers()
{
	echo
	echo -e "${color_0275d8}# Step: displaydrivers()${color_revert}"
	sleep 5

    display_drivers="null"
	case "$graphical_display" in
        "radeon" )
            display_drivers="xf86-video-ati"
            ;;
        "nvidia" )
            display_drivers="nvidia nvidia-utils nvidia-settings opencl-nvidia"
            ;;
        "intel" )
            display_drivers="xf86-video-intel"
            ;;
        "default" )
            display_drivers="xf86-video-vesa"
            ;;
    esac

	arch-chroot /mnt pacman -Syu mesa mesa-libgl --noconfirm --needed >/dev/null 2>&1
	loadstatus " [+] Mesa Packages" "OK" "valid"

	arch-chroot /mnt pacman -Syu xorg xorg-server --noconfirm --needed >/dev/null 2>&1
	loadstatus " [+] Xorg Packages" "OK" "valid"

	if [ "$display_drivers" != "null" ];
	then
        arch-chroot /mnt pacman -Syu $display_drivers --noconfirm --needed >/dev/null 2>&1
    fi

	loadstatus " [+] Display Drivers" "OK" "valid"
}

## Install Gnome Desktop
## ---------------------
function install_gnome()
{
	arch-chroot /mnt pacman -Syu gdm gedit gnome-backgrounds gnome-color-manager gnome-control-center gnome-disk-utility gnome-font-viewer gnome-initial-setup gnome-keyring gnome-logs gnome-menus gnome-remote-desktop gnome-screenshot gnome-session gnome-settings-daemon gnome-shell gnome-shell gnome-shell-extensions gnome-software gnome-system-monitor gnome-terminal gnome-themes-extra gnome-tweak-tool nautilus --noconfirm --needed >/dev/null 2>&1
    arch-chroot /mnt systemctl enable gdm.service >/dev/null 2>&1
}

## Install KDE Desktop
## -------------------
function install_kde()
{
	arch-chroot /mnt pacman -Syu plasma-meta plasma-wayland-session kde-applications-meta --noconfirm --needed >/dev/null 2>&1
    arch-chroot /mnt systemctl enable sddm.service >/dev/null 2>&1
}

## Install XFCE Desktop
## --------------------
function install_xfce()
{
	arch-chroot /mnt pacman -Syu xfce4 xfce4-goodies lightdm lightdm-gtk-greeter --noconfirm --needed >/dev/null 2>&1
    arch-chroot /mnt systemctl enable lightdm.service >/dev/null 2>&1
}

## Install Mate Desktop
## --------------------
function install_mate()
{
	arch-chroot /mnt pacman -Syu mate mate-extra lightdm lightdm-gtk-greeter --noconfirm --needed >/dev/null 2>&1
    arch-chroot /mnt systemctl enable lightdm.service >/dev/null 2>&1
}

## Install Cinnamon Desktop
## -------------------------
function install_cinnamon()
{
	arch-chroot /mnt pacman -Syu cinnamon lightdm lightdm-gtk-greeter --noconfirm --needed >/dev/null 2>&1
    arch-chroot /mnt systemctl enable lightdm.service >/dev/null 2>&1
}

## Install LXDE Desktop
## --------------------
function install_lxde()
{
	arch-chroot /mnt pacman -Syu lxde lxdm --noconfirm --needed >/dev/null 2>&1
    arch-chroot /mnt systemctl enable lxdm.service >/dev/null 2>&1
}

## Install Desktop GUI
## -------------------
function desktop()
{
	echo
	echo -e "${color_0275d8}# Step: desktop()${color_revert}"
	sleep 5

	case "$desktop_env" in
        "gnome" )
            install_gnome
			loadstatus " [+] Gnome Desktop" "OK" "valid"
            ;;
        "kde" )
            install_kde
			loadstatus " [+] KDE Desktop" "OK" "valid"
            ;;
        "xfce" )
            install_xfce
			loadstatus " [+] XFCE Desktop" "OK" "valid"
            ;;
        "mate" )
            install_mate
			loadstatus " [+] Mate Desktop" "OK" "valid"
            ;;
		"cinnamon" )
			install_cinnamon
			loadstatus " [+] Cinnamon Desktop" "OK" "valid"
			;;
		"lxde" )
			install_lxde
			loadstatus " [+] LXDE Desktop" "OK" "valid"
			;;
    esac
}

## Install Packages
## ----------------
function packages()
{
	echo
	echo -e "${color_0275d8}# Step: packages()${color_revert}"
	sleep 5

	## Basic Packages
	## --------------
	arch-chroot /mnt pacman -Syu git --noconfirm --needed >/dev/null 2>&1
	arch-chroot /mnt sed -i "s/%wheel ALL=(ALL) ALL/%wheel ALL=(ALL) NOPASSWD: ALL/" /etc/sudoers
    arch-chroot /mnt bash -c "echo -e \"$user_password\n$user_password\n$user_password\n$user_password\n\" | su $user_username -c \"cd /home/$user_username && git clone https://aur.archlinux.org/yay.git && (cd yay && makepkg -si --noconfirm) && rm -rf yay\"" >/dev/null 2>&1
    arch-chroot /mnt sed -i "s/%wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) ALL/" /etc/sudoers
	loadstatus " [+] Yay Helper" "OK" "valid"

	if [ "$hdd_system" == "btrfs" ];
	then
		arch-chroot /mnt pacman -Syu btrfs-progs --noconfirm --needed >/dev/null 2>&1
		loadstatus " [+] BTRFS Packages" "OK" "valid"
	fi

	if [ "$pacman_packages_roller" != "null" ];
	then
        arch-chroot /mnt pacman -Syu $pacman_packages_roller --noconfirm --needed >/dev/null 2>&1
		loadstatus " [+] File Roller Packages" "OK" "valid"
    fi

	if [ "$pacman_packages_common" != "null" ];
	then
        arch-chroot /mnt pacman -Syu $pacman_packages_common --noconfirm --needed >/dev/null 2>&1
		loadstatus " [+] Common Tools Packages" "OK" "valid"
    fi

	if [ "$pacman_packages_utilities" != "null" ];
	then
        arch-chroot /mnt pacman -Syu $pacman_packages_utilities --noconfirm --needed >/dev/null 2>&1
		loadstatus " [+] Utilities Packages" "OK" "valid"
    fi

	if [ "$pacman_packages_security" != "null" ];
	then
        arch-chroot /mnt pacman -Syu $pacman_packages_security --noconfirm --needed >/dev/null 2>&1
		loadstatus " [+] Security Packages" "OK" "valid"
    fi

	if [ "$pacman_packages_developer" != "null" ];
	then
        arch-chroot /mnt pacman -Syu $pacman_packages_developer --noconfirm --needed >/dev/null 2>&1
		loadstatus " [+] Developer Packages" "OK" "valid"
    fi

	if [ "$pacman_packages_python" != "null" ];
	then
        arch-chroot /mnt pacman -Syu $pacman_packages_python --noconfirm --needed >/dev/null 2>&1
		loadstatus " [+] Python Packages" "OK" "valid"
    fi

	## Pentesting Tools Packages
	## -------------------------
	if [ "$extra_cracking" != "null" ];
	then
        arch-chroot /mnt pacman -Syu $extra_cracking --noconfirm --needed >/dev/null 2>&1
		loadstatus " [+] Cracking Packages" "OK" "valid"
    fi

	if [ "$extra_forensics" != "null" ];
	then
        arch-chroot /mnt pacman -Syu $extra_forensics --noconfirm --needed >/dev/null 2>&1
		loadstatus " [+] Forensics Packages" "OK" "valid"
    fi

	if [ "$extra_information_gathering" != "null" ];
	then
        arch-chroot /mnt pacman -Syu $extra_information_gathering --noconfirm --needed >/dev/null 2>&1
		loadstatus " [+] Information Gathering Packages" "OK" "valid"
    fi

	if [ "$extra_hardwares" != "null" ];
	then
        arch-chroot /mnt pacman -Syu $extra_hardwares --noconfirm --needed >/dev/null 2>&1
		loadstatus " [+] Hardwares Packages" "OK" "valid"
    fi

	if [ "$extra_networking" != "null" ];
	then
        arch-chroot /mnt pacman -Syu $extra_networking --noconfirm --needed >/dev/null 2>&1
		loadstatus " [+] Networking Packages" "OK" "valid"
    fi

	if [ "$extra_reverse_engineering" != "null" ];
	then
        arch-chroot /mnt pacman -Syu $extra_reverse_engineering --noconfirm --needed >/dev/null 2>&1
		loadstatus " [+] Reverse Engineering Packages" "OK" "valid"
    fi

	if [ "$extra_sniffing_spoofing" != "null" ];
	then
        arch-chroot /mnt pacman -Syu $extra_sniffing_spoofing --noconfirm --needed >/dev/null 2>&1
		loadstatus " [+] Sniffing/Spoofing Packages" "OK" "valid"
    fi

	if [ "$extra_social_engineering" != "null" ];
	then
        arch-chroot /mnt pacman -Syu $extra_social_engineering --noconfirm --needed >/dev/null 2>&1
		loadstatus " [+] Socials Engineering Packages" "OK" "valid"
    fi

	if [ "$extra_stress_testing" != "null" ];
	then
        arch-chroot /mnt pacman -Syu $extra_stress_testing --noconfirm --needed >/dev/null 2>&1
		loadstatus " [+] Stress Testing Packages" "OK" "valid"
    fi

	if [ "$extra_web_applications" != "null" ];
	then
        arch-chroot /mnt pacman -Syu $extra_web_applications --noconfirm --needed >/dev/null 2>&1
		loadstatus " [+] Web Applications Packages" "OK" "valid"
    fi

	if [ "$extra_wireless" != "null" ];
	then
        arch-chroot /mnt pacman -Syu $extra_wireless --noconfirm --needed >/dev/null 2>&1
		loadstatus " [+] Wireless Packages" "OK" "valid"
    fi

	## Install and Configure DnsMasq
	## -----------------------------
	arch-chroot /mnt sed -i "s/#port=5353/port=5353/" /etc/dnsmasq.conf
	arch-chroot /mnt systemctl enable dnsmasq.service >/dev/null 2>&1
	loadstatus " [+] DnsMasq Configuration" "OK" "valid"

	## Configure TOR & Polipo
	## ----------------------
	if [ -f "/mnt/tmp/archsploit/etc/polipo/config.txt" ];
	then
		mv /mnt/etc/polipo/config /mnt/etc/polipo/config.bak
		mv /mnt/tmp/config.txt /mnt/etc/polipo/config
		loadstatus " [+] TOR Configuration" "OK" "valid"
	else
		loadstatus " [+] TOR Configuration" "Error" "issue"
	fi

	## Configure Apache
	## ----------------
	arch-chroot /mnt sed -i "s/#LoadModule unique_id_module modules/LoadModule unique_id_module modules/" /etc/httpd/conf/httpd.conf
	if [ -f "/mnt/tmp/archsploit/srv/http/index.html" ];
	then
		mv /mnt/tmp/archsploit/srv/http/index.html /mnt/srv/http/
		arch-chroot /mnt systemctl enable httpd.service >/dev/null 2>&1
		loadstatus " [+] Apache Configuration" "OK" "valid"
	else
		loadstatus " [+] Apache Configuration" "Error" "issue"
	fi

	## Configure MySQL Server
	## ----------------------
	arch-chroot /mnt mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql >/dev/null 2>&1
	arch-chroot /mnt systemctl enable mysqld.service >/dev/null 2>&1
	loadstatus " [+] MySQL Configuration" "OK" "valid"

	## Install PHP Components
	## ----------------------
	mkdir /mnt/var/log/php
	if [ -d "/mnt/var/log/php" ];
	then
		chown http /mnt/var/log/php
		loadstatus " [+] PHP Logs Directory" "OK" "valid"
	else
		loadstatus " [+] PHP Logs Directory" "Error" "issue"
	fi

	if [ -f "/mnt/tmp/archsploit/etc/httpd/conf/httpd.conf" ];
	then
		mv /mnt/etc/httpd/conf/httpd.conf /mnt/etc/httpd/conf/httpd.conf.bak
		mv /mnt/tmp/archsploit/etc/httpd/conf/httpd.conf /mnt/etc/httpd/conf/
		loadstatus " [+] PHP Configuration" "OK" "valid"
	else
		loadstatus " [+] PHP Configuration" "Error" "issue"
	fi

	if [ -f "/mnt/tmp/archsploit/srv/http/info.php" ];
	then
		mv /mnt/tmp/archsploit/srv/http/info.php /mnt/srv/http/
		loadstatus " [+] PHP Info File" "OK" "valid"
	else
		loadstatus " [+] PHP Info File" "Error" "issue"
	fi

	## Copy Github Tools
	## -----------------
	cp -r /mnt/tmp/archsploit/opt/* /mnt/opt/
}

## Terminate Installation
## ----------------------
function terminate()
{
	echo
	echo -e "${color_0275d8}# Step: terminate()${color_revert}"
	sleep 5

	## Configure User Bashrc
	## ---------------------
	if [ -f "/mnt/tmp/archsploit/etc/skel/bashrc.txt" ];
	then
		rm -f /mnt/home/$user_username/.bashrc
		mv /mnt/tmp/archsploit/etc/skel/bashrc.txt /mnt/home/$user_username/.bashrc
		chown 1000:users /mnt/home/$user_username/.bashrc
		loadstatus " [+] Bashrc Configuration" "OK" "valid"
	else
		loadstatus " [+] Bashrc Configuration" "Error" "issue"
	fi

	## Configure Bash History
	## ----------------------
	echo "# Bash History" >> /mnt/home/$user_username/.bash_logout
	echo "# ------------" >> /mnt/home/$user_username/.bash_logout
	echo "history -c" >> /mnt/home/$user_username/.bash_logout
	loadstatus " [+] History Configuration" "OK" "valid"

	## Download Default Backgrounds
	## ----------------------------
	rm -f /mnt/usr/share/backgrounds/gnome/*
	backgrounds=( arch-linux-bubbles-3840x2160.jpg arch-linux-darkred-3840x2160.jpg arch-linux-fusion-3840x2160.jpg arch-linux-keyboard-3840x2160.jpg arch-linux-minimalism-3840x2160.jpg arch-linux-texture-3840x2160.jpg arch-linux-simple-3840x2160.jpg arch-linux-vintage-3840x2160.jpg arch-linux-waves-3840x2160.jpg )
	for basename in "${backgrounds[@]}"
	do
		if [ -f "/mnt/tmp/archsploit/usr/share/backgrounds/gnome/${basename}" ];
		then
			mv /mnt/tmp/archsploit/usr/share/backgrounds/gnome/${basename} /mnt/usr/share/backgrounds/gnome/
			loadstatus " [+] Background ~ ${basename}" "OK" "valid"
		else
			loadstatus " [+] Background ~ ${basename}" "Error" "issue"
		fi
	done

	## Download Gnome-Background Properties
	## ------------------------------------
	if [ -f "/mnt/tmp/archsploit/usr/share/gnome-background-properties/gnome-backgrounds.xml" ];
	then
		rm -f /mnt/usr/share/gnome-background-properties/*
		mv /mnt/tmp/archsploit/usr/share/gnome-background-properties/gnome-backgrounds.xml /mnt/usr/share/gnome-background-properties/
		loadstatus " [+] Gnome Background Properties" "OK" "valid"
	else
		loadstatus " [+] Gnome Background Properties" "Error" "issue"
	fi

	## Install Dash-to-Dock
	## --------------------
	if [ -d "/mnt/tmp/archsploit/usr/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com" ];
	then
		rm -rf /mnt/usr/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com
		mv /mnt/tmp/archsploit/usr/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com /mnt/usr/share/gnome-shell/extensions/
		loadstatus " [+] Dash to Dock Extension" "OK" "valid"
	else
		loadstatus " [+] Dash to Dock Extension" "Error" "issue"
	fi

	## Install Themes
	## --------------
	if [ -d "/mnt/tmp/archsploit/usr/share/themes" ];
	then
		mv /mnt/tmp/archsploit/usr/share/themes/* /mnt/usr/share/themes/
		loadstatus " [+] Custom Themes" "OK" "valid"
	else
		loadstatus " [+] Custom Themes" "Error" "issue"
	fi

	## Install Shortcuts
	## -----------------
	if [ -d "/mnt/tmp/archsploit/usr/share/applications" ];
	then
		mv /mnt/tmp/archsploit/usr/share/applications/*.desktop /mnt/usr/share/applications/
		loadstatus " [+] Custom Shortcuts" "OK" "valid"
	else
		loadstatus " [+] Custom Shortcuts" "Error" "issue"
	fi

	## Install Icons
	## -------------
	if [ -d "/mnt/tmp/archsploit/usr/share/icons" ];
	then
		mv /mnt/tmp/archsploit/usr/share/icons/* /mnt/usr/share/icons/
		loadstatus " [+] Custom Icons" "OK" "valid"
	else
		loadstatus " [+] Custom Icons" "Error" "issue"
	fi

	## Configure Gnome Shell Gresource
	## -------------------------------
	if [ -f "/mnt/tmp/archsploit/usr/share/gnome-shell/gnome-shell-theme.gresource" ];
	then
		mv /mnt/usr/share/gnome-shell/gnome-shell-theme.gresource /mnt/usr/share/gnome-shell/gnome-shell-theme.gresource.bak
		mv /mnt/tmp/archsploit/usr/share/gnome-shell/gnome-shell-theme.gresource /mnt/usr/share/gnome-shell/
		loadstatus " [+] Gnome Shell Gresource Configuration" "OK" "valid"
	else
		loadstatus " [+] Gnome Shell Gresource Configuration" "Error" "issue"
	fi

	## Configure Gnome Shell Theme
	## ---------------------------
	if [ -d "/mnt/tmp/archsploit/usr/share/gnome-shell/theme" ];
	then
		rm -rf /mnt/usr/share/gnome-shell/theme
		mv /mnt/tmp/archsploit/usr/share/gnome-shell/theme /mnt/usr/share/gnome-shell/
		loadstatus " [+] Gnome Shell Theme Configuration" "OK" "valid"
	else
		loadstatus " [+] Gnome Shell Theme Configuration" "Error" "issue"
	fi

	## Configure ArchSploit-System
	## ---------------------------
	if [ -f "/mnt/tmp/archsploit/usr/local/bin/archsploit-system" ];
	then
		mv /mnt/tmp/archsploit/usr/local/bin/archsploit-system /mnt/usr/local/bin/archsploit-system
		chmod +x /mnt/usr/local/bin/archsploit-system
		loadstatus " [+] Arch system Configuration" "OK" "valid"
	else
		loadstatus " [+] Arch system Configuration" "Error" "issue"
	fi

	## Configure ArchSploit-Installer
	## ------------------------------
	if [ -f "/mnt/tmp/archsploit/usr/local/bin/archsploit-installer" ];
	then
		mv /mnt/tmp/archsploit/usr/local/bin/archsploit-installer /mnt/usr/local/bin/archsploit-installer
		chmod +x /mnt/usr/local/bin/archsploit-installer
		loadstatus " [+] Arch Installer Configuration" "OK" "valid"
	else
		loadstatus " [+] Arch Installer Configuration" "Error" "issue"
	fi

	## Configure Dconf
	## ---------------
	if [ -d "/mnt/tmp/archsploit/etc/dconf" ];
	then
		rm -rf /mnt/etc/dconf
		mv /mnt/tmp/archsploit/etc/dconf /mnt/etc/
		arch-chroot /mnt dconf update
		loadstatus " [+] Dconf Configuration" "OK" "valid"
	else
		loadstatus " [+] Dconf Configuration" "Error" "issue"
	fi

	## --------------------- ##
	## CLEAN TEMPORARY FILES ##
	## --------------------- ##

	## Delete Machine Logs
	## -------------------
	find /mnt/var/log/ -type f -name '*.gz' -exec sudo rm -f {} \; >/dev/null 2>&1
	find /mnt/var/log/ -type f -name '*.old' -exec sudo rm -f {} \; >/dev/null 2>&1
	find /mnt/var/log/ -type f -name '*.1' -exec sudo rm -f {} \; >/dev/null 2>&1
	find /mnt/var/log/ -type f -name '*.log' -exec sudo rm -f {} \; >/dev/null 2>&1
	loadstatus " [+] Clean System Logs" "OK" "valid"

	## Delete Temporary Folders and Files
	## ----------------------------------
	rm -rf /mnt/tmp/*
	loadstatus " [+] Clean Temporary Files" "OK" "valid"

	## Final Notice
	## ------------
	echo
	echo -e "${color_5cb85c}Arch Linux Installed Successfully${color_revert}"
	echo "Don't forget to remove the installation before to boot your system"
	echo "The system will shutdown within 15 seconds"
	sleep 15

	umount -R /mnt/boot
    umount -R /mnt
    shutdown now
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
	setkeyboard
	detectsystem
	partitions
	loadmirror
	basesystem
	kernels
	buildfstab
	configuration
	clonerepository

	if [ "$virtualbox" == "true" ];
	then
        virtualmachine
    fi

	mkinitcpio
	bootloader
	multilib
	alsautils
	displaydrivers
	desktop
	packages
	terminate
}

## -------- ##
## Callback ##
## -------- ##

launch
