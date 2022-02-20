SCHEME=$1
USER=$2
PASSWORD=$3

if [ $(lsblk|grep disk|grep vda|sed 's/ .*$//') == vda ]
then
	DISK=vda
else
	DISK=sda
fi

echo Freeing System \(only when run 2cnd time so ignore errors please\)
umount -R /dev/${DISK}1
sleep 2
umount -R /dev/${DISK}2
sleep 2
umount -R /dev/${DISK}3
sleep 2
umount -R /mnt
sleep 2
df

echo Setting vi
ln -s /usr/bin/vim /usr/bin/vi

MEMTOTAL=$(grep MemTotal /proc/meminfo | awk ' { print $2 }')

echo Partitioning disk
sgdisk --zap-all /dev/$DISK
sleep 2
sfdisk --delete /dev/$DISK
sleep 2

if [ $SCHEME == "UEFI" ]
then
fdisk /dev/$DISK <<EOF
g
n
p


+500M
t
1
n


+${MEMTOTAL}k
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
mkswap /dev/${DISK}2
swapon /dev/${DISK}2

echo Formatting disks
mkfs.fat -F 32 /dev/${DISK}1
mkfs.ext4 -F /dev/${DISK}3
mkfs.ext4 -F /dev/${DISK}4

echo Mounting
mount /dev/${DISK}3 /mnt
mkdir /mnt/home
mount /dev/${DISK}4 /mnt/home
mkdir /mnt/efi
mount /dev/${DISK}1 /mnt/efi

else

fdisk /dev/$DISK <<EOF
o
n
p


+2G
t
82
n
p


+45G
t

83
n




t

83
a
2
w
EOF

fdisk -l

echo Swap
mkswap /dev/${DISK}1
swapon /dev/${DISK}1

echo Formatting disks
mkfs.ext4 -F /dev/${DISK}2
mkfs.ext4 -F /dev/${DISK}3

echo Mounting
mount /dev/${DISK}2 /mnt
mkdir /mnt/home
mount /dev/${DISK}3 /mnt/home
fi


echo Copying files
cp -ax / /mnt
cp mkinitcpio.conf /mnt/etc
cp -vaT /run/archiso/bootmnt/arch/boot/$(uname -m)/vmlinuz-linux /mnt/boot/vmlinuz-linux
sleep 2
genfstab -U /mnt >> /mnt/etc/fstab

cp sudoers /mnt/etc
cp yay-11.0.2-1-x86_64.pkg.tar.zst /mnt
cp AUR /mnt/home

echo Going CHROOT
arch-chroot /mnt /bin/bash <<EOF >LOG 2>&1
cp /home/AUR .

pacman -Sy
pacman -Syu --noconfirm

echo LOCALE and stuff > /dev/tty
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
export LANG=en_US.UTF-8
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
ln -s /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
echo Arch-TEST > /etc/hostname
sed -i "/localhost/s/$/ Arch-VM" /etc/hosts
echo "root:$PASSWORD" | chpasswd

echo Adding user $USER >/dev/tty
groupadd -r autologin
useradd -G autologin,wheel,power -m $USER
echo "$USER:$PASSWORD" | chpasswd
cat <<SU >> /etc/sudoers
## Same thing without a password
$USER ALL=(ALL) NOPASSWD: ALL
SU

echo Chowning $USER >/dev/tty
chown -R ${USER} /home/$USER
sleep 2

echo Pacman Keys >/dev/tty
pacman-key --init 
sleep 3
pacman-key --populate archlinux
sleep 3
sudo pacman -Syu --noconfirm
sleep 2


echo Installing yay >/dev/tty

pacman -U yay-11.0.2-1-x86_64.pkg.tar.zst --noconfirm

systemctl enable --now sshd.service

ln -s /usr/bin/vim /usr/bin/vi

echo cleaning up >/dev/tty

sed -i 's/Storage=volatile/#Storage=auto/' /etc/systemd/journald.conf
rm /etc/udev/rules.d/81-dhcpcd.rules
systemctl disable pacman-init.service choose-mirror.service
rm -r /etc/systemd/system/{choose-mirror.service,pacman-init.service,etc-pacman.d-gnupg.mount,getty@tty1.service.d}
rm /etc/systemd/scripts/choose-mirror
rm /etc/systemd/system/getty@tty1.service.d/autologin.conf
rm /root/{.automated_script.sh,.zlogin}
rm /etc/mkinitcpio-archiso.conf
rm -r /etc/initcpio

echo mkinitcpio >/dev/tty

mkinitcpio -P

echo Installing grub >/dev/tty
if [ $1 == "UEFI" ]
then
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB

grub-mkconfig -o /boot/grub/grub.cfg
else
grub-install /dev/$DISK

grub-mkconfig -o /boot/grub/grub.cfg

fi

echo Installing AUR packages >/dev/tty

su $USER -P -c 'yay --noconfirm --needed -S - < /home/AUR'

echo installing paru >/dev/tty

su $USER -c 'yay -S paru-bin --noconfirm'

echo Installing dusk >/dev/tty

su $USER -c 'yay --noconfirm -S yajl'
su $USER -c 'yay --noconfirm -S imlib2'


git clone https://github.com/bakkeby/dusk

chown -R ${USER}:${USER} /home/$USER

cd dusk
make
sudo make install

EOF

echo moving dusk >/dev/tty

cp mirrorlist /mnt/etc/pacman.d/

mkdir -p /mnt/home/$USER/.config/{picom,v,sxhkd}

cp picom.conf /mnt/home/$USER/.config/picom
cp .aliases.all /mnt/home/$USER/
cp VM_xinitrc /mnt/home/$USER/.xinitrc


