# CI
Clean and fast install of any Arch distro

Steps to take:

1) Boot up from any Arch iso

2) git clone https://github.com/rayvermey/CI
   
3) cd CI

   run ./install.sh SCHEME USER PASSWORD

   SCHEME = UEFI or LEGACY , this will adjust your diskpartitioning accordingly

   USER = the user you want to be added next to the standard root user
          This user will be added to the sudoers file so you don't need to enter your password anymore
          Adjust to your own taste

   PASSWORD = The password for your USER

4) AUR packages are installed by yay , edit the file AUR to have the right AUR packages installed

5) I am a huge fan of the DUSK windowmanager so that is the one installed.
   Ofcourse you can change that later

6) Have FUN!
