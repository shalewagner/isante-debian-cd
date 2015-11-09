#!/bin/bash

# update this to the iso url for newer releases
RELEASE_ISO_URL=http://releases.ubuntu.com/14.04/ubuntu-14.04.3-server-i386.iso

# change this for a different output file name
TARGET_FILE_NAME="isante-ubuntu.iso"

# no need to make changes below here unless there is an error

TEMPDIR=temporary-files

RELEASE_ISO=`echo $RELEASE_ISO_URL | awk -F'/' '{print $NF}'`

# changes to script folder so relative paths work correctly
cd ${0%/*}

if [ $EUID -ne 0 ]
then
   echo "This script must be run as root" 1>&2
   exit 1
fi

if [ ! -d "$TEMPDIR" ]
then
  mkdir $TEMPDIR
fi

if [ ! -e "$TEMPDIR/$RELEASE_ISO" ]
then
  wget -P $TEMPDIR $RELEASE_ISO_URL
fi

if [ ! -e "$TARGET_FILE_NAME" ]
then
  rm $TEMPDIR/$TARGET_FILE_NAME
fi

if [ ! -d "$TEMPDIR/iso" ]
then
  mkdir $TEMPDIR/iso
fi

if [ -d "$TEMPDIR/isofiles" ]
then
  echo "removing isofiles folder"
  rm -rf $TEMPDIR/isofiles
fi
mkdir $TEMPDIR/isofiles

MOUNTPOINT=`pwd`/$TEMPDIR/iso/

if mountpoint -q "$MOUNTPOINT"; then
  umount $MOUNTPOINT
fi

# copy the iso files over
mount -o loop ./$TEMPDIR/$RELEASE_ISO $TEMPDIR/iso/
rsync -av $TEMPDIR/iso/ $TEMPDIR/isofiles/
umount $TEMPDIR/iso

cp txt.cfg $TEMPDIR/isofiles/isolinux

# modify the initrd.gz with our preseed file to automate the 
# installer with answers to prompts

mkdir $TEMPDIR/irmod && cd $TEMPDIR/irmod
gzip -d <../isofiles/install/initrd.gz | cpio --extract --verbose --make-directories --no-absolute-filenames
cp ../../preseed.cfg ./
find . | cpio -H newc --create --verbose | gzip -9 > ../isofiles/install/initrd.gz
cd ..
rm -rf irmod/

# update script?

mkisofs -r -J -l -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table -z -iso-level 4 -c isolinux/isolinux.cat -o $TARGET_FILE_NAME -joliet-long isofiles/

cd ..
