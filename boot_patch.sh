#!/bin/sh

#######################################################################################
# Magisk Boot Image Patcher
#######################################################################################

#################
# Unpack
#################

lz4 "boot.img.lz4" "boot.img"

./libmagiskboot.so unpack "boot.img"

#################
# Binary Patches
#################

# Remove Real-time Kernel Protection (RKP)
./libmagiskboot.so hexpatch "kernel" \
  49010054011440B93FA00F71E9000054010840B93FA00F7189000054001840B91FA00F7188010054 \
  A1020054011440B93FA00F7140020054010840B93FA00F71E0010054001840B91FA00F7181010054

# Remove Defeat Exploit (DEFEX)
# Before: [mov w2, #-221]   (-__NR_execve)
# After:  [mov w2, #-32768]
./libmagiskboot.so hexpatch "kernel" 821B8012 E2FF8F12

# Disable Process Authentication (PROCA)
# proca_config -> proca_magisk
./libmagiskboot.so hexpatch "kernel" \
  70726F63615F636F6E66696700 \
  70726F63615F6D616769736B00

# Force kernel to load rootfs for legacy SAR devices
# skip_initramfs -> want_initramfs
./libmagiskboot.so hexpatch "kernel" \
  736B69705F696E697472616D667300 \
  77616E745F696E697472616D667300

#################
# Repack
#################

./libmagiskboot.so repack "boot.img"

#################
# Clean
#################

./libmagiskboot.so cleanup

# Reset any error code
true
