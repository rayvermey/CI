parted -s /dev/vda1 mklabel gpt
parted -s /dev/vda1 mkpart primary fat32 1MiB 512MiB
parted -s /dev/vda1 set 1 esp on
parted -s /dev/vda2 mkpart primary ext4 512MiB 30GB
parted -s /dev/vda2 mklabel root
parted -s /dev/vda3 mkpart primary ext4 512MiB 100%
parted -s /dev/vda3 mklabel home

