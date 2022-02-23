# CI
Clean and fast install of any Arch distro

This install.sh script will build a new system from the iso (or distro) you booted
up from.
So all the distro specifics are copied in, ALSO all the installed software.
This can be convinient for ISO builders, no repo software install is needed afterward,
only AUR packages you want.

Steps to take:

1) Boot up from any Arch iso

2) Run:

	 pacman -Sy

	 pacman -S git

	 git clone https://github.com/rayvermey/CI
   
3) cd CI

   run ./install.sh SCHEME USER PASSWORD

   SCHEME = UEFI or LEGACY , this will adjust your diskpartitioning accordingly

   USER = the user you want to be added next to the standard root user
          This user will be added to the sudoers file so you don't need to enter your password anymore
          Adjust to your own taste

   PASSWORD = The password for your USER

4) 	poweroff and change boot order from cd to disk if you are in a vm situation, otherwise remove usb/installation medium
     	boot up and login under account and password given when install.sh was ran!

	AUR packages are installed by yay , edit the file AUR to have the right AUR packages installed

	edit and run postinstall.sh

5) I am a huge fan of the DUSK windowmanager so that is the one installed.
   Ofcourse you can change that later

6) Have FUN!
