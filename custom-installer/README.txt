This directory contains everything you need to build a custom Debian Installer. 

The primary reason we build a custom installer is so that the firmware needed for the network hardware on HP machines is included. 

We also customize the boot menu and add version information to several graphics used in the installer.

Firmware is added to the Debian installer by appending firmware files to the initrd.gz used during boot. firmware.cpio.gz is the current set of firmware that will be appended. This file can be created with the make-firmware.sh script which collects all firmware files currently in /lib/firmware. This process is described here:

            http://wiki.debian.org/DebianInstaller/NetbootFirmware#The_Solution:_Add_Firmware_to_Initramfs

The Debian installer boot menu can be customized to make it work better for our needs. 

This is the procedure for customizing the installer. It only needs to be done once when a new version of the installer is used.

   a. Get latest debian-installer source `apt-get source debian-installer`
   b. Comment out the two text only installer options in build/boot/x86/menu.cfg
   c. Modify build/boot/x86/gtk.cfg so that the graphical install is the default. Change the label if needed:

		menu label ^Install Linux
		menu default
-----------------------------------------------------------------------------------------------------
					menu hshift 13
					menu width 49 

					menu title Installer boot menu${BEEP}
					include ${SYSDIR}stdmenu.cfg
					#include ${SYSDIR}txt.cfg
					#include ${SYSDIR}amdtxt.cfg
					include ${SYSDIR}gtk.cfg
					include ${SYSDIR}amdgtk.cfg
					menu begin advanced
					        menu title Advanced options
					        include ${SYSDIR}stdmenu.cfg
					        label mainmenu
					                menu label ^Back..
					                menu exit
					        include ${SYSDIR}adtxt.cfg
					        include ${SYSDIR}amdadtxt.cfg
					        include ${SYSDIR}adgtk.cfg
					        include ${SYSDIR}amdadgtk.cfg
					menu end
					label help
					        menu label ^Help
					        text help
					   Display help screens; type 'menu' at boot prompt to return to this menu
					        endtext
					        config ${SYSDIR}prompt.cfg 
-----------------------------------------------------------------------------------------------------

   d. `svn mv build/boot/x86/pics/klowner.png build/boot/x86/pics/klowner-original.png`
   e. Add build/boot/x86/pics/klowner.png to the svn:ignore list:

 		`svn propedit svn:ignore build/boot/x86/pics/`

   f. Add the file build/sources.list.udeb.local with contents like:

		deb copy:/home/<user_here>/<root_here>/custom-installer/debian-installer-20090123lenny9/build/ localudebs/
		deb http://archive.debian.org/debian lenny main/debian-installer
		
   g. Update references to the debian-installer source in the files build.sh and README.txt  
