#!/bin/bash -e

SOURCES_FILE=/etc/apt/sources.list

if [ $NO_CD ]; then
    #If there are packages in itech.packages that are not installed, download them from the Debian repository.
    echo -n "Checking installed packages..."
    TO_INSTALL_PACKAGES=`./helpers/find-missing-packages.sh`
    echo "done"

    if [ -n "$TO_INSTALL_PACKAGES" ]; then
	echo 
	echo Need to download the following packages $TO_INSTALL_PACKAGES
	echo
	read -p "Press ENTER to start download. (CTRL+C to abort)"

        echo Updating package list...
	echo '
deb http://archive.debian.org/debian-security lenny/updates main contrib non-free
deb http://archive.debian.org/debian lenny main contrib non-free
' > $SOURCES_FILE
	apt-get update
	UPDATE_STATUS=$?
	if [ $UPDATE_STATUS != 0 ]; then
	    echo Could not update Debian package list. Check internet connections and try again.
	    exit $UPDATE_STATUS
	fi

	echo Downloading packages...
	apt-get install -y --allow-unauthenticated --no-install-recommends -d $TO_INSTALL_PACKAGES
	INSTALL_STATUS=$?
	if [ $INSTALL_STATUS != 0 ]; then
	    echo Could not download packages. Check internet connections and try again.
	    exit $INSTALL_STATUS
	fi
	echo Package download complete.
	exit 0
    fi
else
    #Set the CD as our package repository and update.
    echo deb file:/cdrom/debian stable main non-free > $SOURCES_FILE
    apt-get update &>/dev/null
    exit $?
fi
