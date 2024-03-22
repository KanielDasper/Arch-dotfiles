# My Current Environment

![dekstop-env](https://github.com/KanielDasper/arch-linux-dotfiles/assets/112337013/2c569fbc-f31b-46d8-a1fb-90a01121e107)

**Disclaimer**: *The following guide is an exerpt from the ArchWiki wherein some steps have been modified to fit my own likings and installationpreferences. This worked for me though, so maybe this guide may suit you more than what is explained on the wiki.*

**For dot-files**: *copy the contents of st/config.def.h and dwm/config.def.h which contain the cosmetic enchancements to the desktop*

# Step 1: The Arch Installation

Step 1 is a guide for installing Arch Linux using the live system booted from an installation medium made from an official installation image. The installation medium provides accessibility features which are described on the page Install Arch Linux with accessibility options. For alternative means of installation.

Before installing, it would be advised to view the FAQ of ArchWiki. Code examples may contain placeholders (formatted in italics) that must be replaced manually.

This guide is kept concise and you are advised to follow the instructions in the presented order per section. For more detailed instructions, see the respective ArchWiki articles or the various programs' man pages, both linked from this guide. For interactive help, the IRC channel and the forums are also available.

Arch Linux should run on any x86_64-compatible machine with a minimum of 512 MiB RAM, though more memory is needed to boot the live system for installation. A basic installation should take less than 2 GiB of disk space. As the installation process needs to retrieve packages from a remote repository, this guide assumes a working internet connection is available.

## **Pre-installation:**

Acquire an installation image
Visit the Download page and, depending on how you want to boot, acquire the ISO file or a netboot image, and the respective GnuPG signature.

Verify signature
It is recommended to verify the image signature before use, especially when downloading from an HTTP mirror, where downloads are generally prone to be intercepted to serve malicious images.

On a system with GnuPG installed, do this by downloading the ISO PGP signature (under Checksums in the page Download) to the ISO directory, and verifying it with:

```
$ gpg --keyserver-options auto-key-retrieve --verify archlinux-version-
x86_64.iso.sig
```

Alternatively, from an existing Arch Linux installation run:

```bash
$ pacman-key -v archlinux-version-x86_64.iso.sig
```

**Note:**
The signature itself could be manipulated if it is downloaded from a mirror site, instead of from archlinux.org as above. In this case, ensure that the public key, which is used to decode the signature, is signed by another, trustworthy key. The gpg command will output the fingerprint of the public key.

Another method to verify the authenticity of the signature is to ensure that the public key's fingerprint is identical to the key fingerprint of the Arch Linux developer who signed the ISO-file. See Wikipedia:Public-key cryptography for more information on the public-key process to authenticate keys.

### **Prepare an installation medium:**

The installation image can be supplied to the target machine via a USB flash drive, an optical disc or a network with PXE: follow the appropriate article to prepare yourself an installation medium from the chosen image.

### **Boot the live environment:**

**Note:** Arch Linux installation images do not support Secure Boot. You will need to disable Secure Boot to boot the installation medium. If desired, Secure Boot can be set up after completing the installation.
Point the current boot device to the one which has the Arch Linux installation medium. Typically it is achieved by pressing a key during the POST phase, as indicated on the splash screen. Refer to your motherboard's manual for details.
When the installation medium's boot loader menu appears, select Arch Linux install medium and press Enter to enter the installation environment.

**Tip:**
The installation image uses GRUB for UEFI and syslinux for BIOS booting. Use respectively e or Tab to enter the boot parameters. See README.bootparams for a list. A common example of manually defined boot parameter would be the font size. For better readability on HiDPI screens—when they are not already recognized as such

You will be logged in on the first virtual console as the root user, and presented with a Zsh shell prompt.
To switch to a different console—for example, to view this guide with Lynx alongside the installation—use the Alt+arrow shortcut. To edit configuration files, mcedit(1), nano and vim are available. See pkglist.x86_64.txt for a list of the packages included in the installation medium.

### **Set the console keyboard layout and font**

The default console keymap is US. Available layouts can be listed with:

```bash
$ localectl list-keymaps
```

To set the keyboard layout, pass its name to loadkeys(1). For example, to set a Danish keyboard layout:

```bash
$ loadkeys dk-latin1
```

Console fonts are located in /usr/share/kbd/consolefonts/ and can likewise be set with setfont(8) omitting the path and file extension. For example, to use one of the largest fonts suitable for HiDPI screens, run:

```bash
$ setfont ter-120b
```

### **Verify the boot mode**
To verify the boot mode, check the UEFI bitness:

```bash
$ cat /sys/firmware/efi/fw_platform_size
```

If the command returns 64, then system is booted in UEFI mode and has a 64-bit x64 UEFI. If the command returns 32, then system is booted in UEFI mode and has a 32-bit IA32 UEFI; while this is supported, it will limit the boot loader choice to systemd-boot. If the file does not exist, the system may be booted in BIOS (or CSM) mode. If the system did not boot in the mode you desired (UEFI vs BIOS), refer to your motherboard's manual.

### **Connect to the internet**
To set up a network connection in the live environment, go through the following steps:

- Ensure your network interface is listed and enabled, for example with ip-link(8):

```bash
$ ip link
```

For wireless and WWAN, make sure the card is not blocked with rfkill.

### **Connect to the network:**
Ethernet—plug in the cable.
Wi-Fi—authenticate to the wireless network using iwctl.
Mobile broadband modem—connect to the mobile network with the mmcli utility.
Configure your network connection:
DHCP: dynamic IP address and DNS server assignment (provided by systemd-networkd and systemd-resolved) should work out of the box for Ethernet, WLAN, and WWAN network interfaces.

The connection may be verified with ping:

```bash
$ ping archlinux.org
```

Note: In the installation image, systemd-networkd, systemd-resolved, iwd and ModemManager are preconfigured and enabled by default. That will not be the case for the installed system.

### **Update the system clock**
In the live environment systemd-timesyncd is enabled by default and time will be synced automatically once a connection to the internet is established.

Use timedatectl(1) to ensure the system clock is accurate:

```bash
$ timedatectl
```

## **Partition the disks**
When recognized by the live system, disks are assigned to a block device such as /dev/sda, /dev/nvme0n1 or /dev/mmcblk0. To identify these devices, use lsblk or fdisk l.

```bash
$ cfdisk
```

Results ending in rom, loop or airootfs may be ignored. mmcblk* devices ending in rpbm, boot0 and boot1 can be ignored.

**Note**: If the disk does not show up, make sure the disk controller is not in RAID mode.

**Tip:** Check that your NVMe drives and Advanced Format hard disk drives are using the optimal logical sector size before partitioning.
The following partitions are required for a chosen device:

- One partition for the root directory /.
- For booting in UEFI mode: an EFI system partition.
- If you want to create any stacked block devices for LVM, system encryption or RAID, do it now.

Use a partitioning tool like cfdisk to modify partition tables. When entering the *cfdisk* interface you should create 3 seperate partitions in the following order:

- a 100M Partition which will be named sda1
- a 4GB Partition which will be name sda2
- the rest of the available storage as a partition named sda3

### **Format the partitions**
Once the partitions have been created, each newly created partition must be formatted with an appropriate file system. See File systems#Create a file system for details.

For example, to create an Ext4 file system on /dev/root_partition, run:

```bash
$ mkfs.ext4 /dev/sda3
```

If you created a partition for swap, initialize it with mkswap(8):

```bash
$ mkswap /dev/sda2
```

**Note:** For stacked block devices replace /dev/*_partition with the appropriate block device path.
If you created an EFI system partition, format it to FAT32 using mkfs.fat(8).

**Warning:** Only format the EFI system partition if you created it during the partitioning step. If there already was an EFI system partition on disk beforehand, reformatting it can destroy the boot loaders of other installed operating systems.

```bash
$ mkfs.fat -F 32 /dev/sda1
```

**Mount the file systems**
Mount the root volume to /mnt. Our root volume is sda3, so the command will be the following:

```bash
$ mount /dev/sda3 /mnt
```

Create any remaining mount points (such as /mnt/boot) and mount the volumes in their corresponding hierarchical order.

Tip: Run mount with the --mkdir option to create the specified mount point. Alternatively, create it using mkdir(1) beforehand.
For UEFI systems, mount the EFI system partition:

```bash
$ mkdir -p /mnt/boot/efi

```
Afterwards, mount sda1 in the newly created directory: 

```
$ mount /dev/sda1 /dev/boot/efi
```

If you created a swap volume, enable it with swapon(8):

```bash
$ swapon /dev/sda2
```

genfstab will later detect mounted file systems and swap space.

## **Installation**
Select the mirrors
Packages to be installed must be downloaded from mirror servers, which are defined in /etc/pacman.d/mirrorlist. On the live system, after connecting to the internet, reflector updates the mirror list by choosing 20 most recently synchronized HTTPS mirrors and sorting them by download rate.

The higher a mirror is placed in the list, the more priority it is given when downloading a package. You may want to inspect the file to see if it is satisfactory. If it is not, edit the file accordingly, and move the geographically closest mirrors to the top of the list, although other criteria should be taken into account.

This file will later be copied to the new system by pacstrap, so it is worth getting right.

### **Install essential packages**
Note: No software or configuration (except for /etc/pacman.d/mirrorlist) gets carried over from the live environment to the installed system.
Use the pacstrap(8) script to install the base package, Linux kernel and firmware for common hardware:

### **pacstrapping the /mnt**
**Tip:**
You can substitute linux with a kernel package of your choice, or you could omit it entirely when installing in a container.
You could omit the installation of the firmware package when installing in a virtual machine or container.
The base package does not include all tools from the live installation, so installing more packages may be necessary for a fully functional base system. You should however install these packages before proceeding with the installation in this guide:

- base
- linux
- linux-firmware
- sof-firmware
- grub
- vim
- nano
- networkmanager
- efibootmgr
- base-devel

The command for pacstrapping will look like this:

```bash
$ pacstrap /mnt base linux linux-firmware sof-firmware grub
  vim nano networkmanager efibootmgr base-devel
```

## **Configure the system**
### **Fstab**
Generate an fstab file (use -U or -L to define by UUID or labels, respectively):

```bash
$ genfstab -U /mnt >> /mnt/etc/fstab
```

Check the resulting /mnt/etc/fstab file with *cat*, and edit it in case of errors.

### **Chroot**
Change root into the new system:

```bash
$ arch-chroot /mnt
```
 
### **Time**
Set the time zone:

```bash
$ ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
```

Run hwclock to generate /etc/adjtime:

```bash
$ hwclock --systohc
```

This command assumes the hardware clock is set to UTC. See System time#Time standard for details.

To prevent clock drift and ensure accurate time, set up time synchronization using a Network Time Protocol (NTP) client such as systemd-timesyncd.

### **Localization of the system**
Edit /etc/locale.gen and uncomment en_US.UTF-8 UTF-8 and other needed UTF-8 locales. Generate the locales by running:
 
```bash
$ locale-gen
```

Create the locale.conf(5) file, and set the LANG variable accordingly:

```bash
$ vim /etc/locale.conf
```

uncomment **LANG=da_DK.UTF-8** in the vim editor with *x* in Normal-mode and then *:wq*.

If you set the console keyboard layout, make the changes persistent in vconsole.conf(5):

```bash
$ vim /etc/vconsole.conf
```

add KEYMAP=dk-latin1 to the file and *:wq*

### **Network configuration**
Create the hostname file:

```bash
$ vim /etc/hostname
```

add **yourhostname** and *:wq* to save the file. 

Complete the network configuration for the newly installed environment. That may include installing suitable network management software, configuring it if necessary and enabling its systemd unit so that it starts at boot.

### **Initramfs**
Creating a new initramfs is usually not required, because mkinitcpio was run on installation of the kernel package with pacstrap.

For LVM, system encryption or RAID, modify mkinitcpio.conf(5) and recreate the initramfs image:

```bash
 $ mkinitcpio -P
```

### **Root password**
Set the root password:

```bash
$ passwd
```

### **Add users with sudo priveliges**
Users should be created under the group *wheel* wherein their sudo priviliges will be granted:

```bash
$ adduser -m -G wheel -s myusername
```
This creates the user and password for the user-account can be created similiarly to the root password with *passwd myusername*

Now you should navigate the the visudo options and uncomment the line, so the 'wheel' group is granted sudo priviliges when providing a password. Enter the file with the following command:

```bash
$ EDITOR=vim visudo
```

### **Boot loader**
Choose and install a Linux-capable boot loader. If you have an Intel or AMD CPU, enable microcode updates in addition.

Here you should use Grub as your bootloader for arch linux. For installing grub as your bootloader use the following command:

```bash
$ grub-install 
```
after you have installed the bootloader you need to make a config file for the grub bootloader with the following command:

```bash
$ grub-mkconfig -O /dev/grub/grub.cfg
```

### **Reboot**
Exit the chroot environment by typing exit or pressing Ctrl+d.

*Optionally manually unmount all the partitions with:*

```bash
$ umount -R /mnt 
```

this allows noticing any "busy" partitions, and finding the cause with fuser.

Finally, restart the machine by typing:

```bash
$ reboot
```

Any partitions still mounted will be automatically unmounted by systemd. Remember to remove the installation medium and then login into the new system with the root account.

### **Post-installation**
See General recommendations for system management directions and post-installation tutorials (like creating unprivileged user accounts, setting up a graphical user interface, sound or a touchpad).

For a list of applications that may be of interest, see List of applications.

# Step 2: Installing necessary packages
