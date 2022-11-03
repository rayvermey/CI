UUID=$(sudo blkid /dev/sda1 | cut -d" " -f7 | sed 's/PARTUUID="//' | sed 's/"//')
echo $UUID

cat <<BOOT > BOO
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=PARTUUID=$UUID rw
BOOT
cat BOO
