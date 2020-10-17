#### INTRODUCTION

Let’s cut the bullshit, this project is based on Arch Linux and designed with Pentest, Security and Development in mind for the best experience.This installation script of Arch Linux is based on the excellent work of [picodot.dev](https://github.com/picodotdev). The main purpose of this script is to make the Arch Linux installation process easier with a special touch for the Arch Linux Lovers with the aim to promote the culture of pentest and security IT environment.

* * *

#### KEYS FEATURES

Before you try these alternative Arch Linux installation method, I highly recommend installing Arch Linux in the traditional way from the command line, step-by-step using this below tutorial in order for you to gain a deeper understanding of your system and and what goes into installing a desktop Linux operating system.

**What exactly does this script do?**

This method of installing Arch Linux automates the entire installation process of Arch Linux.

**Keys Features**

- System support for UEFI and BIOS Mode
- HDD support for SATA NVMe and MMC Disk
- SSD TRIM support compatibility
- Disk SWAP support enable/disable
- Logical Volume Management on LUKS
- Encrypted Root Partition
- File system formats EXT4, BTRFS and XFS
- Arch Mirror Optimization using Reflector
- Support for "mkinitcpio" Ramdisk Environment
- GRUB bootloader installation and configuration
- Detect and install "Intel processors microcode"
- Enable Arch Linux "Multilib"
- Install advanced linux sound architecture (ALSA)
- Graphical Drivers Installation (Radeon, Nvidia, Intel)
- Install Gnome Desktop Environment
- Install GDM Display managers
- Install VirtualBox Guest Utils
- Full user creation process along with "sudoers" configuration
- Common packages installation

* * *

#### INSTALLATION

**Download a Copy of Arch Linux ISO**

To start in the right order, you'll have to visit the [official Arch download](https://www.archlinux.org/download/) page to copy the most recent Arch Linux ISO link as well as the sha1sum text file link. As soon as you have them, simply open your terminal to execute the following commands, without forgetting to replace the links present in the below example by the one you just grab from the Arch Linux website.

```bash
cd /tmp/

# Replace the ISO link and filename if needed
wget -O archlinux-2020.02.01-x86_64.iso http://mirrors.evowise.com/archlinux/iso/2020.02.01/archlinux-2020.02.01-x86_64.iso

# Replace the sha1sum link and filename if needed
wget -O sha1sums.txt http://mirrors.evowise.com/archlinux/iso/2020.02.01/sha1sums.txt
```

**Verify the ISO Signature**

It is recommended to verify the image signature before to move further, especially when downloading from an HTTP mirror. To do this, we'll simply compare the "sha1sum" from the text file we downloaded previously with a generated "sha1sum" of our ISO.

```bash
sha1sum=$(cat "sha1sums.txt" | head -n1 | awk '{print $1;}')
echo "${sha1sum}" /tmp/archlinux-2020.02.01-x86_64.iso | sha1sum -c
```

**Creating a Bootable Arch Linux USB Drive**

Creating a bootable Arch Linux USB key in a Linux environment is easy. Once you've downloaded and verified your Arch Linux ISO file, you can use the "`dd`" command to copy it over to your USB stick using the following procedure. Plug your USB drive into an available USB port on your system, and run the following command to write the ISO image to your USB drive.

```bash
sudo fdisk -l
```

Once you identified the path of your USB drive, run the below command to create your bootable Arch Linux USB key.

```bash
sudo dd if=/tmp/archlinux-2020.02.01-x86_64.iso of=/usb/path status=progress bs=4M && sync
```

The block size parameter "`bs`" can be increased, and while it may speed up the operation of the "`dd`" command, it can occasionally produce unbootable USB drives, depending on your system and a lot of different factors. The recommended value, "`bs=4M`", is conservative and reliable.

**Boot from the Live USB**

Once you are ready with your bootable Arch Linux USB drive, shut down your system. Plugin your USB and boot your machine again.

**Important:** You may be unable to boot from live USB if **secure boot** is enabled on your system. In such a case you must first disable the secure boot option from your BIOS panel.

**Configure Default Keyboard**

The default keyboard layout in the live session is US. You can list out all the supported keyboard layout using the below command:

```bash
ls /usr/share/kbd/keymaps/**/*.map.gz
```

If you need to change the keyboard layout, you can do it using "`loadkeys`" command. For example, if we want a French keyboard, this is what you'll use:

```bash
loadkeys fr-latin1
```

**Connect to the Internet using Ethernet Cable**

Ensure your network interface is listed and enabled invoking the "`ip`" command:

```bash
ip link
```

If your network interface is not yet enabled, you can enable it using:

```bash
# Replace "device" with your current Ethernet adapter name for example "eth0"
ip link set "device" up
dhcpcd
```

**Connect to the Internet using Wireless Connection**

From the latest version of **Arch Linux** released since June 2020, the package `wifi-menu`, is not present anymore in your live operating system. But you can connect to your WiFi network using the `iwctl` package. In order to do so, the first thing to do is to run the following command in order to get an interactive prompt.

```bash
iwctl
```

Once you are done, you can list the available WiFi devices using:

```bash
device list
```

Then, to scan the network:

```bash
station "device" scan
```

Or you can list all the available networks using:

```bash
station "device" get-networks
```

When you are ready, you can connect to your desidered network with the following command:

```bash
station "device" connect "SSID"
```

When you already connected your machine to the WiFi, you must execute the `exit` command in order to return to terminal and continue the process of the installation of your operating system.

**Verify the connection**

You can now verify the connection doing a simple ping as follow:

```bash
ping archlinux.org -c 3
dhcpcd
```

**Launch The Installation Script**

When you are ready, you will need to grab and configure the installation script. In order to do it, simply use the following command:

```bash
# Download the script and configuration file using wget
curl -s https://raw.githubusercontent.com/archsploit/archsploit/master/download.sh | bash

# Edit the archsploit.conf script with nano
nano archsploit.conf

# Execute the script
./archsploit.sh
```

**Installation of the Pentest Packages**

Designed to be fast, easy to use and provide a minimal yet complete desktop environment. Archsploit let's you choice which Pentest Packages you want to install on your target system. Once you have completed the installation, you will be able to select which packages category you want to setup in your environment. In order to do it, simply log into your machine, open your terminal and use the following commands.

```bash
# List all available Pentest Packages
archsploit-packages -h

# Install specific packages category
archsploit-packages -i <category>

# Install all packages categories
archsploit-packages -i all
```

* * *

For more information on how this automated script works, I encourage you to watch the video below.

[![Video](https://img.youtube.com/vi/Akn5yMBwgCw/maxresdefault.jpg)](https://www.youtube.com/watch?v=Akn5yMBwgCw)

[![Video](https://img.youtube.com/vi/V7GkTPeBTRI/maxresdefault.jpg)](https://www.youtube.com/watch?v=V7GkTPeBTRI)

[![Video](https://img.youtube.com/vi/EoFSs8Kuuuk/maxresdefault.jpg)](https://www.youtube.com/watch?v=EoFSs8Kuuuk)
