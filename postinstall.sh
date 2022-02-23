echo Installing base-devel package

yay --noconfirm --needed -S base-devel fakeroot
echo Installing libxft-bgra package needed for dusk

yay --noconfirm --needed -S libxft-bgra

echo Installing AUR packages
yay --noconfirm --needed -S - < /home/AUR

echo Installing dusk 

pacman --noconfirm -S yajl
pacman --noconfirm -S imlib2


git clone https://github.com/bakkeby/dusk

chown -R ${USER}:${USER} /home/$USER

cd dusk
make
sudo make install

