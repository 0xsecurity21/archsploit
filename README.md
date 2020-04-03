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

**Connect to the internet using Wireless connection**

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

#### CREATE HARD DRIVE PARTITION

We will now see the first crucial part of this tutorial. There are a few points to check carefully before to start the partitioning of your system. You must know if your system is running under UEFI or BIOS mode. If you are not sure, the best way is to run the following command.

```bash
ls /sys/firmware/efi/efivars
```

If this directory exists, you are running under UEFI system.

**Identify your hard drive path**

You'll now use "`fdisk`" command to see the partition label of your current hard drive in which you want to install Arch Linux.

```bash
fdisk -l
```

**Output**

<a class="gallery-item" href="https://neoslab.com/uploads/posts/2020/02/how-to-install-arch-linux-with-lvm-and-luks-disk-encryption-2.png" data-fancybox="How to Install Arch Linux with LVM and LUKS Disk Encryption" data-options="{'caption':'How to Install Arch Linux with LVM and LUKS Disk Encryption'}"><img src="https://neoslab.com/uploads/posts/2020/02/how-to-install-arch-linux-with-lvm-and-luks-disk-encryption-2.png" alt="How to Install Arch Linux with LVM and LUKS Disk Encryption"/></a>

Once you identified the path of your current hard drive referenced in this tutorial by "`/dev/sda`", run the below command to start to create a new GPT entry in your hard drive and wipe your disk.

```
sgdisk --zap-all /dev/sda
wipefs -a /dev/sda
```

* * *

#### CREATE PARTITION FOR UEFI SYSTEM

**Create the Partition**

In most tutorials, they show you how to create the partition using a GUI interface. Here we will be using a pure command line to create our partition from a single line of code.

```bash
parted -s /dev/sda mklabel gpt mkpart primary fat32 1MiB 512MiB mkpart primary ext4 512MiB 100% set 1 boot on
sgdisk -t=1:ef00 /dev/sda
```

**Setup the LVM**

To enable and setup our LVM (Logical Volume Management) in our drive using "`sgdisk`" enter the below command:

```bash
sgdisk -t=2:8e00 /dev/sda
```

**Encrypt your Disk**

To encrypt the hard drive we will use "`cryptsetup`" command and "`LUKS`" encryption format. Please be sure to replace the "passphrase" string by your password.

```bash
echo -n "passphrase" | cryptsetup --key-size=512 --key-file=- luksFormat --type luks2 /dev/sda2
echo -n "passphrase" | cryptsetup --key-file=- open /dev/sda2 lvm
pvcreate /dev/mapper/lvm
vgcreate vg /dev/mapper/lvm
lvcreate -l 100%FREE -n root vg
```

**Format the Partitions**

It's now the time to format our partitions. To do this, we will use "`wipefs`" and "`mkfs`" commands line.

```bash
wipefs -a /dev/sda1
wipefs -a /dev/mapper/vg-root
mkfs.fat -n ESP -F32 /dev/sda1
mkfs.ext4 -L root /dev/mapper/vg-root
```

**Mount your Disk for Trim Device**

A trim command (known as TRIM in the ATA command set, and UNMAP in the SCSI command set) allows an operating system to inform a solid-state drive (SSD) which blocks of data are no longer considered in use and can be wiped internally.

```bash
mount -o "defaults,noatime" /dev/mapper/vg-root /mnt
mkdir /mnt/boot
mount -o "defaults,noatime" /dev/sda1 /mnt/boot
```

**Mount your Disk for Standard Device**

```bash
mount -o /dev/mapper/vg-root /mnt
mkdir /mnt/boot
mount -o /dev/sda1 /mnt/boot
```

* * *

#### CREATE PARTITION FOR BIOS SYSTEM

**Create the Partition**

Mostly tutorials show you how to create the partition using GUI tools. Here we will be using a pure command line to create our partitions from a single line of code.

```bash
parted -s /dev/sda mklabel gpt mkpart primary fat32 1MiB 128MiB mkpart primary ext4 128MiB 512MiB mkpart primary ext4 512MiB 100% set 1 boot on
sgdisk -t=1:ef02 /dev/sda
```

**Setup the LVM**

To enable and setup our LVM (Logical Volume Management) in our drive using "`sgdisk`" enter the below command:

```bash
sgdisk -t=3:8e00 /dev/sda
```

**Encrypt your Disk**

To encrypt the hard drive we will use "`cryptsetup`" command and "`LUKS`" encryption format. Please be sure to replace the "passphrase" string by your password.

```bash
echo -n "passphrase" | cryptsetup --key-size=512 --key-file=- luksFormat --type luks2 /dev/sda3
echo -n "passphrase" | cryptsetup --key-file=- open /dev/sda3 lvm
pvcreate /dev/mapper/lvm
vgcreate vg /dev/mapper/lvm
lvcreate -l 100%FREE -n root vg
```

**Format the Partitions**

It's now the time to format our partitions. To do this, we will use "`wipefs`" and "`mkfs`" commands line.

```bash
wipefs -a /dev/sda1
wipefs -a /dev/sda2
wipefs -a /dev/mapper/vg-root
mkfs.fat -n BIOS -F32 /dev/sda1
mkfs.ext4 -L boot /dev/sda2
mkfs.ext4 -L root /dev/mapper/vg-root
```

**Mount your Disk for Trim Device**

A trim command (known as TRIM in the ATA command set, and UNMAP in the SCSI command set) allows an operating system to inform a solid-state drive (SSD) which blocks of data are no longer considered in use and can be wiped internally.

```bash
mount -o "defaults,noatime" /dev/mapper/vg-root /mnt
mkdir /mnt/boot
mount -o "defaults,noatime" /dev/sda2 /mnt/boot
```

**Mount your Disk for Standard Device**

```bash
mount -o /dev/mapper/vg-root /mnt
mkdir /mnt/boot
mount -o /dev/sda2 /mnt/boot
```

* * *

#### CREATE HARD DRIVE SWAP

If you wish to allocate a drive Swap simply uses the following commands. In usually drive SWAP is equal at two times the system RAM. For example, if you have 2GB of RAM, the value of the SWAP will be 4GB.

```bash
fallocate -l 4GiB /mnt/swap
chmod 600 /mnt/swap
mkswap /mnt/swap
```

* * *

#### SELECT APPROPRIATE MIRROR

This can be a big problem while installing Arch Linux. If you just go on installing it you might find that the downloads are way too slow. It's because the mirror list located in "/etc/pacman.d/mirrorlist" has a huge number of mirrors but not in good order.

The top mirror is chosen automatically and it may not always be a good choice. First, synchronize the "pacman" repository so that you can download and install the software.

```bash
pacman -Syy
```

We'll now install reflector to be able to use the fastest mirrors located in your country. We furthermore, create a backup of our current mirror list file in case we need to recover it later.

```bash
pacman -Syu reflector
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak

# You'll need to edit the country referenced here by "FR" with your country code
reflector -c "FR" -f 12 -l 10 -n 12 --save /etc/pacman.d/mirrorlist
```

* * *

#### INSTALL ARCH LINUX BASE SYSTEM

Now that we already created our necessary partitions and formatted them. We are ready to proceed with the installation of Arch Linux base system.

```bash
pacstrap /mnt base base-devel linux linux-firmware nano net-tools
```

* * *

#### INSTALL LINUX HEADERS AND LONG TIME SUPPORT KERNEL

The LTS kernel in Arch Linux is often recommended installing if you want to make your Arch system more stable.

```bash
arch-chroot /mnt pacman -Syu linux-headers linux-lts
```

* * *

#### CREATE FSTAB FILE

After base system installation is completed we need to create "fstab" file. Then verify the "fstab" entries using "`cat`" command.

```bash
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab
```

**If you created a Hard Drive Swap**

```bash
echo "# Swap" >> /mnt/etc/fstab
echo "/swap none swap defaults 0 0" >> /mnt/etc/fstab
echo "" >> /mnt/etc/fstab
echo "vm.swappiness=10" > /mnt/etc/sysctl.d/99-sysctl.conf
```

**If your Hard Drive support TRIM feature**

```bash
arch-chroot /mnt sed -i 's/relatime/noatime/' /etc/fstab
arch-chroot /mnt systemctl enable fstrim.timer
```

* * *

#### ARCH LINUX BASIC CONFIGURATION

Now, let us switch to the newly installed Arch Linux base system using the following command:

```bash
arch-chroot /mnt /bin/bash
```

**Setting Timezone**

To set up your system timezone, you can first list all the available timezones to grab the correct name of the one you are looking for.

```bash
timedatectl list-timezones
```

And then set it up replacing "<your-timezone>" with your desired time zone.

```bash
ln -s -f <your-timezone> /etc/localtime
```

**Synchronize the machine time**

Next, we will synchronize the time on our machine. This can be done using "`hwclock`" as described below.

```bash
hwclock --systohc
```

**Setting Locale**

This is what sets the language, numbering, date and currency formats for your system. The file "/etc/locale.gen" contains all the local settings and system language in a commented format. You can simply use "`sed`" to edit it and uncomment the language you want to use. In this example, we'll use "en_US.UTF8" as the preferred language for our installation.

```bash
sed -i 's/#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
```

Now we'll generate the locale "config" file in "/etc" directory along with the required "KEYMAP" using the below commands one by one.

```bash
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "LANGUAGE=en_US" >> /etc/locale.conf
echo "LC_ALL=en_US.UTF-8" >> /etc/locale.conf
export LANG=en_US.UTF-8
export LANGUAGE=en_US
echo "KEYMAP=fr-latin1" > /etc/vconsole.conf
```

**Set ‘root' User Password**

Before to move further or either forget to do it, we'll set the root password.

```bash
passwd
```

**Network Configuration**

Create a "/etc/hostname" file and add the hostname entry to this file. The hostname is basically the name that your computer is using to register on the network. In this example, we'll set the hostname as "archlinux".

```bash
echo "archlinux" > /etc/hostname
```

Next, we'll install and enable the required "Network Manager" package:

```bash
pacman -Syu networkmanager
systemctl enable NetworkManager.service
```

Now, we'll edit our "hosts" file and append the following into our host's configuration. In the below example, I use "archlinux" as hostname, but you must replace this value by the one you want to use (The same you used into "/etc/hostname" file in the previous step).

```bash
echo -e "127.0.0.1\tlocalhost" >> /etc/hosts
echo -e "::1\t\tlocalhost" >> /etc/hosts
echo -e "127.0.1.1\tarchlinux" >> /etc/hosts
```

**Create System User**

We need to create our system user before to move further using the below command:


```bash
# useradd -m -g [initial_group] -G [additional_groups] -s [login_shell] [username]
useradd -m -g users -G wheel,storage,optical,power -s /bin/bash "username"
```

Then set up the password for this new user by running:

```bash
passwd "username"
```

**Setup User Permission**

Now we have to allow users to do administrative tasks To do so, we'll install "sudo". Furthermore, we'll also install "bash-completion" for auto-completing commands and "xdg-user-dirs" to manage user's directories.

```bash
pacman -Syu bash-completion sudo xdg-user-dirs
```

Once that is done, we'll allow the users in "wheel" group to be able to perform administrative tasks with "`sed`". Run the following command to edit the sudoers:

```bash
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
```

**Virtualization**

If you are installing Arch Linux on a Virtualbox Environment, we'll need to install the required packages for correct virtualization of our environment.

```bash
pacman -Syu virtualbox-guest-utils virtualbox-guest-modules-arch
```

* * *

#### INSTALL AND CONFIGURE MKINITCPIO

Mkinitcpio is a Bash script used to create an initial ramdisk environment. The initial ramdisk is in essence, a very small environment that loads various kernel modules and sets up necessary things before handing over control to init. This makes it possible to have, for example, encrypted root file systems and root file systems on a software RAID array.

Mkinitcpio allows for easy extension with custom hooks, has autodetection at runtime, and many other features.

```bash
pacman -Syu lvm2
sed -i 's/ block / block keyboard keymap /' /etc/mkinitcpio.conf
sed -i 's/ filesystems keyboard / encrypt lvm2 filesystems /' /etc/mkinitcpio.conf
sed -i 's/#COMPRESSION="lzma"/COMPRESSION="lzma"/' /etc/mkinitcpio.conf
mkinitcpio -P
```

* * *

#### INSTALL GRUB BOOTLOADER

This is the second crucial step of this tutorial and some points differ for UEFI and BIOS systems. The first thing we'll need to do is to grab the Partition UUID of our system.

**For UEFI System**

```bash
partuuid=$(blkid -s PARTUUID -o value /dev/sda2)
```

**For BIOS System**

```bash
partuuid=$(blkid -s PARTUUID -o value /dev/sda3)
```

According to the variable we just created, we'll now generate the "`GRUB_CMDLINE_LINUX`" value in order to use it to our configuration.

**For TRIM Device**

```bash
grub_cmdline_linux=$(echo cryptdevice=PARTUUID=${partuuid}:lvm:allow-discards)
```

**For Standard Device**

```bash
grub_cmdline_linux=$(echo cryptdevice=PARTUUID=${partuuid}:lvm)
```

Once we've completed the above steps, we can proceed with the installation and configuration of the system GRUB bootloader.


```bash
pacman -Syu grub dosfstools
sed -i 's/GRUB_DEFAULT=0/GRUB_DEFAULT=saved/' /etc/default/grub
sed -i 's/#GRUB_SAVEDEFAULT="true"/GRUB_SAVEDEFAULT="true"/' /etc/default/grub
sed -i -E 's/GRUB_CMDLINE_LINUX_DEFAULT="(.*) quiet"/GRUB_CMDLINE_LINUX_DEFAULT="\1"/' /etc/default/grub
sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="'$grub_cmdline_linux'"/' /etc/default/grub
echo "" >> /etc/default/grub
echo "# Arch Linux" >> /etc/default/grub
echo "GRUB_DISABLE_SUBMENU=y" >> /etc/default/grub
```

**For UEFI System**

```bash
pacman -Syu efibootmgr
grub-install --target=x86_64-efi --bootloader-id=grub --efi-directory=/boot --recheck
```

**For BIOS System**

```bash
grub-install --target=i386-pc --recheck /dev/sda
```

We can generate our GRUB configuration file using the below command:

```bash
grub-mkconfig -o "/boot/grub/grub.cfg"
```

**For Virtualbox Environment**

If you are installing Arch Linux on a Virtualbox Environment, you will need to append the path of your "grubx64.efi" file into the "startup.nsh" file.

```bash
echo -n "\EFI\grub\grubx64.efi" > "/boot/startup.nsh"
```

* * *

#### CONFIGURE MULTILIB REPOSITORIES

I personally recommend to enable **multilib** repositories. To do this, edit the pacman configuration file in "/etc/pacman.conf" using "`sed`" and uncomment both lines:

```bash
curl --silent -o /tmp/config.txt "https://raw.githubusercontent.com/neoslabdev/archlinux/master/etc/pacman.conf"
rm -f /etc/pacman.conf
mv /tmp/pacman.conf /etc/pacman.conf
pacman -Sy
```

* * *

#### INSTALL ADVANCED LINUX SOUND ARCHITECTURE (ALSA)

Now we are going to install the API for sound card device drivers, in order to get some sound out of our machine:

```bash
pacman -Syu alsa-utils pulseaudio
pacman -Syu alsa-oss alsa-lib
```

ALSA by default has all channels muted, all of which will need to be unmuted manually. This can be done using amixer:

```bash
amixer sset Master unmute
```

To check and make sure your speakers are working, just run:

```bash
speaker-test -c 2
```

* * *

#### INSTALL GRAPHICAL DRIVER

We'll now prepare everything our system will require before to install our Graphical Display Driver. First of all, we'll install "`xorg`" and "`mesa`" packages utilities.

```bash
pacman -Syu mesa mesa-libgl
pacman -Syu xorg xorg-server xorg-server
```

Now we can install our Graphical Display Driver using the below commands according to your VGA Manufacturer.

**Install Radeon Drivers**

```bash
pacman -Syu xf86-video-ati
```

**Install Nvidia Drivers**

```bash
pacman -Syu nvidia nvidia-utils nvidia-settings opencl-nvidia
```

**Install Intel Drivers**

```bash
pacman -Syu xf86-video-intel
```

**Install Default Drivers**

```bash
pacman -Syu xf86-video-vesa
```

* * *

#### INSTALL DESKTOP ENVIRONMENT

We are now going to set up our graphical environment. Below you can find the commands line that you will need to install Gnome, KDE, XFCE, Mate, Cinnamon or LXDE according to the one you wish to install.

**Install Gnome Desktop**

```bash
pacman -Syu gnome gnome-extra
systemctl enable gdm.service
```

**Install KDE Desktop**

```bash
pacman -Syu plasma-meta plasma-wayland-session kde-applications-meta
systemctl enable sddm.service
```

**Install XFCE Desktop**

```bash
pacman -Syu xfce4 xfce4-goodies lightdm lightdm-gtk-greeter
systemctl enable lightdm.service
```

**Install Mate Desktop**

```bash
pacman -Syu mate mate-extra lightdm lightdm-gtk-greeter
systemctl enable lightdm.service
```

**Install Cinnamon Desktop**

```bash
pacman -Syu cinnamon lightdm lightdm-gtk-greeter
systemctl enable lightdm.service
```

**Install LXDE Desktop**

```bash
pacman -Syu lxde lxdm
systemctl enable lxdm.service
```

* * *

#### UPDATE / UPGRADE AND REMOVE ORPHANED PACKAGES

To keep your system clean and secure, I personally suggest you to occasionally remove orphans package and their configuration files using the below comand:

```bash
pacman -Syu
pacman -R $(pacman -Qdtq)
```

* * *

#### THE PACMAN PACKAGE MANAGER

In ArchLinux you will have to install new software using pacman it’s very easy actually.

If you want to install something you only need to run:

```bash
sudo pacman -S
```

If you want to search for a package:

```bash
sudo pacman -Ss
```

To remove a single package, leaving all of its dependencies installed

```bash
sudo pacman -R
```

To remove a package and its dependencies which are not required by any other installed package

```bash
sudo pacman -Rs
```

To remove a package, its dependencies and all the packages that depend on the target package:

```bash
sudo pacman -Rsc
```

To remove a package, which is required by another package, without removing the dependent package:

```bash
sudo pacman -Rdd
```

The pacman packages manager also saves important configuration files when removing certain applications and names them with the extension ".pacsave". In order to prevent the creation of these backup files use the -n option:

```bash
pacman -Rn
```

To force the refresh of all package lists:

```bash
pacman -Syy
```

And one of the most important, if you want to update your system:

```bash
sudo pacman -Syu
```

The pacman packages manager stores its downloaded packages in "/var/cache/pacman/pkg/" and does not remove the old or uninstalled versions automatically, therefore it is necessary to deliberately clean up that folder periodically to prevent such folder to grow indefinitely in size. The built-in option to remove all the cached packages that are not currently installed is:

```bash
sudo pacman -Sc
```

To list all packages no longer required as dependencies (orphans):

```bash
sudo pacman -Qdt
```

And finally to delete them (apt autoremove):

```bash
pacman -R $(pacman -Qdtq)
```
