echo Freeing System
umount /dev/vda1
sleep 2
umount /dev/vda2
sleep 2
umount /dev/vda3
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


+30G
t

20
n



t

20
w
EOF

echo Formatting disks
mkfs.fat -F 32 /dev/vda1
mkfs.ext4 -F -F /dev/vda2
mkfs.ext4 -F -F /dev/vda3


echo Mounting
mount /dev/vda2 /mnt
mkdir /mnt/boot
mkdir /mnt/home
mount /dev/vda1 /mnt/boot
sleep 2
mount /dev/vda3 /mnt/home


echo Swap
dd if=/dev/zero of=/mnt/.swapfile bs=1M count=$(($MEMTOTAL / 1000)) status=progress
chmod 0600 /mnt/.swapfile
mkswap -U clear /mnt/.swapfile
swapon /mnt/.swapfile

echo Pacstrap
pacstrap /mnt base base-devel linux linux-firmware vim openssh dhclient networkmanager neofetch wget


echo FSTAB
genfstab -U /mnt >> /mnt/etc/fstab

cp yay-11.0.2-1-x86_64.pkg.tar.zst /mnt/root
cp yay-11.0.2-1-x86_64.pkg.tar.zst /mnt/


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


echo INSTALLING Window Manager DUSK offcourse
pacman -Syy
pacman -S xorg xorg-server xorg-apps xorg-xinit --noconfirm --needed
pacman -S noto-fonts ttf-ubuntu-font-family ttf-dejavu ttf-freefont terminus-font ttf-font-awesome --noconfirm --needed  
pacman -S variety feh picom --noconfirm --needed

echo Adding user Ray
groupadd -r autologin
useradd -G autologin,wheel,power -m ray
echo "ray:qazwsx12" | chpasswd
cat <<SU >> /etc/sudoers
## Same thing without a password
ray ALL=(ALL) NOPASSWD: ALL
SU

echo Installing needed tools
pacman -S gparted git dmenu zsh chromium vivaldi yajl bash-completion zsh-completions  pipewire-audio pipewire-media-session pipewire-pulse pavucontrol volumeicon exa expac --noconfirm --needed


echo Installing yay

pacman -U yay-11.0.2-1-x86_64.pkg.tar.zst --noconfirm

systemctl enable --now sshd.service

su ray -c "yay --noconfirm -R libxft xorg-x11perf"

echo INstalling AUR packages

su ray -c "yay -S jotta-cli alias-tips-git autojump autokey-common autokey-gtk downgrade gconf gitahead-bin gtk-theme-config insync nerd-fonts-hack otf-font-awesome-4 p7zip-gui pamac-all pcloud-drive pkgbrowser snapd snapd-glib spice-vdagent wttr topgrade  --noconfirm"

#echo Preparing Jotta & Rclone

#cp /root/ai.sh /mnt

#mkdir -p /DATA/cloud/Jotta
#mkdir -p /home/ray/.config

#pacman -S rclone --noconfirm

##cp -r /FILES/rclone /home/ray/.config/rclone


#mkdir JOTTA
#cd JOTTA
#tar xvf /FILES/jotta-cli-0.8.36055_linux_x86.tar
#cp -r usr/* /usr
#cp -r etc/* /etc
#cd ..

#cp /FILES/jottad.service /etc/systemd/system/
#systemctl enable --now jottad.service

#cp /FILES/rclone-mount.service /etc/systemd/system/
#systemctl enable --now rclone-mount.service


#picom --config /home/ray/.config/picom.conf -b
ln -s /usr/bin/vim /usr/bin/vi

#mkdir -p /DATA/cloud/Jotta
#chown -R ray:ray /DATA/

echo Installing Dusk and st
cd /home/ray
mkdir git
cd git
git clone https://github.com/bakkeby/dusk
git clone https://github.com/bakkeby/st-flexipatch
cd dusk
make && sudo make install
cd ../st-flexipatch
make && sudo make install

cd


echo Creating .xinitrc
cat <<XINITRC > /home/ray/.xinitrc
export DESKTOP_SESSION=dusk
xrandr -s 1920x1080 
picom &
variety &
volumeicon &
spice-vdagent &
exec dusk

XINITRC

systemctl enable --now NetworkManager
chown -R ray:ray /home/ray

echo Installing Bootloader
bootctl --path=/boot install


EOF

echo Preparing Bootloader
PARTUUID=$(blkid -o value -s PARTUUID /dev/vda2)
cat <<BOOT > /mnt/boot/loader/entries/arch.conf
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=PARTUUID=$PARTUUID rw
BOOT


cat <<LOADER > /mnt/boot/loader/loader.conf
default arch
timeout 4
console-mode max
editor no

LOADER

cp /root/CI/picom.conf /mnt/home/ray/.config
cp /root/CI/.bashrc /mnt/home/ray
sudo cp /root/CI/getty@.service /mnt/usr/lib/systemd/system/getty@.service
cd /mnt/home/ray/.config/
tar xvf /root/CI/VARIETY.tar
