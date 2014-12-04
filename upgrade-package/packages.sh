#!/bin/bash -e

#If givin 'silent' as the argument then this will change debconf settings so that no questions are asked. Otherwise it will change debconf back to the defaults.
debconf_priority () {
    debconfDataFile=`mktemp`

    if [ $1 -a $1 = "silent" ]
    then
	echo "
debconf debconf/frontend select Noninteractive
debconf debconf/priority select critical" > $debconfDataFile
    else
	echo "
debconf debconf/frontend select Dialog
debconf debconf/priority select high" > $debconfDataFile
    fi

    debconf-set-selections $debconfDataFile
    rm -f $debconfDataFile
}


if [ ! $NO_CD ]; then
    #If there is a new version of debconf we need to install it first.
    #If we don't then installing it will override the changes made by debconf_priority.
    apt-get install -y --allow-unauthenticated --no-install-recommends debconf
fi

#Silence debconf and load any settings from the CD
debconf_priority silent
debconf-set-selections ./itech.preseed

if [ ! $NO_CD ]; then
    #Install this first. If it isn't installed then you get lots of perl warning messages.
    apt-get install -y --allow-unauthenticated --no-install-recommends locales-all

    #Upgrade Debian
    apt-get dist-upgrade -y --allow-unauthenticated -o DPkg::Options::="--force-confnew"
fi

#Remove old itech package from before version 12.1
if [ -e /var/lib/dpkg/info/itech.list ]; then
    apt-get remove -y itech
    rm -rf /usr/share/itech
fi

#Install/Upgrade all the rest of the iSanté related packages.
if [ $NO_CD ]; then
    TO_INSTALL_PACKAGES=`./helpers/find-missing-packages.sh`
    if [ -n "$TO_INSTALL_PACKAGES" ]; then
	apt-get install -y --allow-unauthenticated --no-install-recommends $TO_INSTALL_PACKAGES
    fi
    dpkg -E -i debs/*.deb
else
    apt-get install -y --allow-unauthenticated --no-install-recommends `grep ^[^#] ./itech.packages`
fi

#Put debconf settings back to default and clean up
debconf_priority
apt-get clean
