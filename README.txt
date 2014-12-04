This directory contains everything needed to build an iSanté installation CD and upgrade .sh script.

To use this first check to make sure the custom-installer is up to date and that a link called isante-source points to a valid iSanté SVN checkout. 

To build the media you'll need the following Debian packages installed: 

   make gettext ghc6 libghc6-parsec-dev libghc6-cgi-dev libxml-twig-perl ant-optional g++ libboost-date-time-dev libmysqlclient15-dev fakeroot debhelper php5-dev makeself simple-cdd imagemagick libc6-pic

You will also need dependencies for building the Debian installer. Get those with this command

   sudo apt-get build-dep debian-installer

To build development, testing or production media use the following commands respectively.

   build.sh
   build.sh test
   build.sh release


build.sh - script to build upgrade package and .iso images using simple-cdd
custom-installer/ - This directory contains some custom installer packages needed for special kernel drivers and branding. See custom-installer/README.txt
images/ - for holding .iso images and upgrade scripts
isante-source - this symbolic should point to an SVN checkout of the iSanté source
isante-cdd-*.conf - configuration parameters for simple-cdd
local-packages*/ - locally built packages that can be included in the CD
profiles/isante-*.description - description of the profile used to create the CD
profiles/isante-*.packages - names of packages that will be included on the CD
profiles/isante-*.postinst - script to be run after Debian installation
profiles/isante-*.preseed - debconf parameters that will be loaded before CD installer starts
README.txt - this README
tmp/ - holds files used to build the CD
upgrade - upgrade script that is put on the CD in simple-cdd/upgrade
upgrade-package/ - individual components of the upgrade script 
