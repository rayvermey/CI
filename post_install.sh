if [ $(type dusk >/dev/null 2>&1) ] 
then
	echo Dusk installed
else
	echo "Installing Dusk & Picom & st & Variety & Feh and right variety script"
	sudo pacman --needed -S picom variety feh yajl dmenu
#	sed 's/"i3"/"i3" "dusk" /'  .config/variety/scripts/set_wallpaper > .config/variety/scripts/set_wallpaper.new
	cp /etc/xdg/picom.conf ~/.config/picom
	sed 's/"vsync = true;"/"vsync = false;"/' .config/picom/pioom.conf > .config/picom/pioom.conf.new 
	mv .config/picom/pioom.conf.new  .config/picom/pioom.conf
#	mv .config/variety/scripts/set_wallpaper.new > .config/variety/scripts/set_wallpaper
	mkdir -p ~/.config/picom
	mkdir ~/git
	cd ~/git
	#git clone https://github.com/bakkeby/dusk
	#git clone https://github.com/bakkeby/st-flexipatch
	echo Making Dusk
	cd ~/git/dusk
	#make && sudo make install
	echo Making st
	cd ~/git/st-flexipatch
	#make && sudo make install
	echo Creating .xinitrc
	cat <<XINITRC > ~/.xinitrc
	xrandr -s 1920x1080 &
	picom &
	variety &
	exec dusk
XINITRC
	
fi
