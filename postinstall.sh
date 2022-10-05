USER=$(whoami)

sudo chown -R $USER:$USER /home/$USER

sudo pacman -Sy
sudo pacman -S --noconfirm archlinux-keyring

sudo pacman -Syu --noconfirm

echo Installing base-devel package

yay --noconfirm --needed -S base-devel fakeroot

echo Installing AUR packages
yay --noconfirm --needed -S - < /home/AUR

echo Installing dusk 

sudo pacman --noconfirm -S yajl
sudo pacman --noconfirm -S imlib2

sudo pacman -S --needed --noconfirm vlc alacritty dmenu dunst rofi startup-notification picom variety feh copyq spice-vdagent autokey-common autokey-gtk flameshot kalu flatpak plocate expac picom
git clone https://github.com/bakkeby/dusk

cd dusk
make
sudo make install

