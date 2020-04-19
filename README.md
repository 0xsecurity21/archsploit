#### DOWNLOAD A COPY OF ARCH ISO

To start in the right order, you'll have to visit the [official Arch download](https://www.archlinux.org/download/) page to copy the most recent Arch Linux ISO link as well as the sha1sum text file link. As soon as you have them, simply open your terminal to execute the following commands, without forgetting to replace the links present in the below example by the one you just grab from the Arch Linux website.

```bash
cd /tmp/

# Replace the ISO link and filename if needed
wget -O archlinux-2020.02.01-x86_64.iso http://mirrors.evowise.com/archlinux/iso/2020.02.01/archlinux-2020.02.01-x86_64.iso

# Replace the sha1sum link and filename if needed
wget -O sha1sums.txt http://mirrors.evowise.com/archlinux/iso/2020.02.01/sha1sums.txt
```

* * *

#### VERIFY SIGNATURE

It is recommended to verify the image signature before to move further, especially when downloading from an HTTP mirror. To do this, we'll simply compare the "sha1sum" from the text file we downloaded previously with a generated "sha1sum" of our ISO.

```bash
sha1sum=$(cat "sha1sums.txt" | head -n1 | awk '{print $1;}')
echo "${sha1sum}" /tmp/archlinux-2020.02.01-x86_64.iso | sha1sum -c
```

* * *

#### CREATING A BOOTABLE ARCH LINUX USB DRIVE

Creating a bootable Arch Linux USB key in a Linux environment is easy. Once you've downloaded and verified your Arch Linux ISO file, you can use the "`dd`" command to copy it over to your USB stick using the following procedure. Plug your USB drive into an available USB port on your system, and run the following command to write the ISO image to your USB drive.

```bash
sudo fdisk -l
```

Once you identified the path of your USB drive, run the below command to create your bootable Arch Linux USB key.

```bash
dd if=/tmp/archlinux-2020.02.01-x86_64.iso of=/usb/path status=progress bs=4M && sync
```

The block size parameter "`bs`" can be increased, and while it may speed up the operation of the "`dd`" command, it can occasionally produce unbootable USB drives, depending on your system and a lot of different factors. The recommended value, "`bs=4M`", is conservative and reliable.

* * *

#### BOOT FROM THE LIVE USB

Once you are ready with your bootable Arch Linux USB drive, shut down your system. Plugin your USB and boot your machine again.

<a class="gallery-item" href="https://neoslab.com/uploads/posts/2020/02/how-to-install-arch-linux-with-lvm-and-luks-disk-encryption-1.png" data-fancybox="How to Install Arch Linux with LVM and LUKS Disk Encryption" data-options="{'caption':'How to Install Arch Linux with LVM and LUKS Disk Encryption'}"><img src="https://neoslab.com/uploads/posts/2020/02/how-to-install-arch-linux-with-lvm-and-luks-disk-encryption-1.png" alt="How to Install Arch Linux with LVM and LUKS Disk Encryption"/></a>

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

**Connect to the internet using Ethernet cable**

Ensure your network interface is listed and enabled invoking the "`ip`" command:

```bash
ip link
```

If your network interface is not yet enabled, you can enable it using:

```bash
# Replace "interface" with your current Ethernet adapter name for example "eth0"
ip link set "interface" up
dhcpcd
```

You can now verify the connection doing a simple ping as follow:

```bash
ping archlinux.org -c 3
```

**Connect to the Internet using Wireless connection**

Like the above method, you must ensure your network interface is listed and enabled. Once you are done with this step, you can connect to your WiFi network using the following command:

```bash
# Replace "passphrase" with the password of your WiFi network and "SSID" with your network name
wpa_passphrase "passphrase" | wpa_supplicant -B -i "SSID" -c /dev/stdin
dhcpcd
```

In the same way as above, we'll verify the connection using the ping command:

```bash
ping archlinux.org -c 3
```

* * *

#### ARCH LINUX INSTALLATION SCRIPT

Before you try these alternative Arch Linux installation method, I highly recommend installing Arch Linux in the traditional way from the command line, step-by-step using this [tutorial](https://cybsploit.com/2020/02/23/how-to-install-arch-linux-with-lvm-and-luks-disk-encryption-YzZyRVdDUVZDeHV4MEZYYXBWZU44Zz09) in order for you to gain a deeper understanding of your system and and what goes into installing a desktop Linux operating system.

For those who would like to go further with the help of an automatic installation script for Arch Linux, which has been optimized for the Pentest, I have just created recently on the basis of the excellent work done by [picodot.dev](https://github.com/picodotdev) an installation script which will make the Arch Linux installation process easier.

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
- Install Desktop Environment (Gnome, KDE, XFCE, Mate, Cinnamon, LXDE)
- Install Display managers (GDM, SDDM, Lightdm, lxdm)
- Install VirtualBox Guest Utils
- Full user creation process along with "sudoers" configuration
- Install common packages
- Install pentesting packages

**In summary, the steps look like this:**

- Download the official current release of Arch Linux and boot into it
- Download the script and configuration file using "`wget`"
- Load your preferred keymap with the "`loadkeys`" command
- Edit the archlinux.conf script with "`nano`"
- Change the script permission using "`chmod`"
- Execute the script

```bash
# Load your preferred keymap with the loadkeys command
# For example, if we want a French keyboard, this is what you'll use
loadkeys fr-latin1

# Download the script and configuration file using wget
wget -O - https://raw.githubusercontent.com/archsploit/archsploit/master/download.sh | bash

# Edit the archlinux.conf script with nano
nano archsploit.conf

# Execute the script
./archsploit.sh
```

For more information on how this automated script works, I encourage you to watch the video below.

<iframe src="https://www.youtube.com/embed/tmGLHk2-rBE" allowfullscreen="allowfullscreen" width="800" height="460" frameborder="0"></iframe>
