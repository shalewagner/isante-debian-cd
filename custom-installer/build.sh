#!/bin/bash -e

VERSION_STRING="with iSanté $1"

IMAGE_DIR_DI='debian-installer-20090123lenny9/build/boot/x86/pics'
IMAGE_DIR_ROOTSKEL='rootskel-gtk-1.15/src/usr/share/graphics'

convert $IMAGE_DIR_DI/klowner-original.png -gravity northeast \
    -pointsize 16 -stroke none -fill white -annotate +10+8 "$VERSION_STRING" \
    $IMAGE_DIR_DI/klowner.png

convert $IMAGE_DIR_ROOTSKEL/logo_debian-original.png -gravity northeast \
    -pointsize 16 -stroke none -fill white -annotate +10+8 "$VERSION_STRING" \
    $IMAGE_DIR_ROOTSKEL/logo_debian.png


(cd rootskel-gtk-1.15 && fakeroot ./debian/rules binary)
(cd rootskel-gtk-1.15 && fakeroot ./debian/rules clean)
mv -f rootskel-gtk_1.15-100_i386.udeb debian-installer-20090123lenny9/build/localudebs/
rm -f debian-installer-20090123lenny9/build/apt.udeb/cache/archives/rootskel-gtk*

fakeroot make -C debian-installer-20090123lenny9/build all_clean
fakeroot make -C debian-installer-20090123lenny9/build build_cdrom_isolinux
rsync -a debian-installer-20090123lenny9/build/dest/* installer/i386/images/

cat firmware.cpio.gz >> installer/i386/images/cdrom/initrd.gz
cat firmware.cpio.gz >> installer/i386/images/cdrom/gtk/initrd.gz
