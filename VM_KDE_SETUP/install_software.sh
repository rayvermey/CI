echo Installing needed software
sudo pacman -S --noconfirm --needed ferdium-bin
yay -S --noconfirm --needed autokey-gtk 
yay -S --noconfirm --needed flameshot
yay -S --noconfirm --needed vivaldi-snapshot

/usr/local/bin/data/tozsh
/usr/local/bin/data/kvm

echo Setting up rclone mounts

sudo mkdir -p /DATA/cloud/Jotta
sudo mkdir -p /DATA/cloud/Google_Drive
sudo mkdir -p /DATA/SHARED
sudo mkdir -p /MEDIA/Jotta_photos

sudo cp -r etc/* /etc/systemd/system

mkdir ~/.config/rclone
cp .config/rclone.conf ~/.config/rclone

systemctl enable --now rclone-mount-google_drive
systemctl enable --now rclone-mount-photos
systemctl enable --now rclone-mount
systemctl enable --now rclone-mount-shared


