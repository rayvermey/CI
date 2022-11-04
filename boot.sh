echo Freeing System
umount /dev/vda1
sleep 2
umount /dev/vda3
sleep 2
umount /dev/vda3
sleep 2
umount /dev/vda4
sleep 2
swapoff /dev/vda2
sleep 2

echo Setting vi
ln -s /usr/bin/vim /usr/bin/vi

echo Mirrors
reflector -c NL > /etc/pacman.d/mirrorlist
pacman -Syy


MEMTOTAL=$(grep MemTotal /proc/meminfo | awk ' { print $2 }')

echo Partitioning disk
sgdisk --zap-all /dev/vda
sleep 2
sfdisk --delete /dev/vda
sleep 2
fdisk -l

fdisk /dev/vda <<EOF
g
n


+500M
Y
t
1
n


+${MEMTOTAL}k
Y
t

19
n


+30G
t

20
n



t

28
w
EOF

echo Swap
mkswap /dev/vda2
swapon /dev/vda2

echo Formatting disks
mkfs.fat -F 32 /dev/vda1
mkfs.ext4 -F -F /dev/vda3
mkfs.ext4 -F -F /dev/vda4

echo Mounting
mount /dev/vda3 /mnt
mkdir /mnt/boot
mkdir /mnt/home
mount /dev/vda1 /mnt/boot
sleep 2
mount /dev/vda4 /mnt/home


echo Pacstrap
pacstrap /mnt base base-devel linux linux-firmware vim openssh dhclient networkmanager neofetch wget

echo FSTAB
genfstab -U /mnt >> /mnt/etc/fstab

cp yay-11.0.2-1-x86_64.pkg.tar.zst /mnt/root
cp yay-11.0.2-1-x86_64.pkg.tar.zst /mnt/


#echo Preparing Bootloader
#PARTUUID=$(blkid -o value -s PARTUUID /dev/vda3)
#cat <<BOOT > /root/CI/arch.conf
#title   Arch Linux
#linux   /vmlinuz-linux
#initrd  /initramfs-linux.img
#options root=PARTUUID=$PARTUUID rw
#BOOT

#cat <<LOADER > /root/CI/loader.conf
#default arch
#timeout 4
#console-mode max
#editor no

#LOADER

#bootctl --path=/boot update


echo CHROOT
arch-chroot /mnt <<EOF
echo LOCALE and stuff
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
export LANG=en_US.UTF-8
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
ln -s /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
echo Arch-VM > /etc/hostname
#sed -i "/localhost/s/$/ Arch-VM" /etc/hosts
mkinitcpio -p linux
echo "root:qazwsx12" | chpasswd


echo Adding user Ray
groupadd -r autologin
useradd -G autologin,wheel,power -m ray
echo "ray:qazwsx12" | chpasswd
cat <<SU >> /etc/sudoers
## Same thing without a password
ray ALL=(ALL) NOPASSWD: ALL
SU

ln -s /usr/bin/vim /usr/bin/vi


echo Installing Bootloader
bootctl --path=/boot install
#cat <<LOADER > /boot/loader/loader.conf

#bootctl --path=/boot update
echo Preparing Bootloader
PARTUUID=$(blkid -o value -s PARTUUID /dev/vda3)
echo 1 $PARTUUID > partuuid.txt
cat <<BOOT > /boot/loader/entries/arch.conf
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=PARTUUID=$PARTUUID rw
BOOT

echo 2 $PARTUUID >> partuuid.txt

cat <<LOADER > /boot/loader/loader.conf
default arch
timeout 4
console-mode max
editor no

LOADER

bootctl --path=/boot update
EOF
