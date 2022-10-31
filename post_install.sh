sudo pacman -Syy

if [ $(type dusk >/dev/null 2>&1) ] 
then
	echo Dusk installed
else
	echo "Installing Dusk & Picom & st & Variety & Feh and right variety script"
	sudo pacman --needed -S picom variety feh yajl dmenu

	mkdir ~/.config/picom
	cp picom.conf  ~/.config/picom/picom.conf
	cp set_wallpaper.new ~/.config/variety/scripts/set_wallpaper
	sudo cp kde_settings.conf /etc/sddm.conf.d/kde_settings.conf
	mkdir ~/git
	cd ~/git
	git clone https://github.com/bakkeby/dusk
	git clone https://github.com/bakkeby/st-flexipatch
	echo Making Dusk
	cd ~/git/dusk
	make && sudo make install
	echo Making st
	cd ~/git/st-flexipatch
	make && sudo make install
	echo Creating .xprofile
	cat <<XINITRC > ~/.xprofile
xrandr -s 1920x1080 &
picom &
variety &
XINITRC
	
fi
