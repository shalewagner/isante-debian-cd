#!/bin/bash -e

thisVersionPrefix=$1
SVN_REVISION=$2
NO_CD=$3
export NO_CD=$NO_CD

thisVersion="$thisVersionPrefix ($SVN_REVISION)"
export thisVersion=$thisVersion


if [ $EUID -ne 0 ]; then
  echo "You must be root to perform an upgrade."
  exit 1
fi


#get OLD_SVN_REVISION and oldVersion
if [ -e /var/lib/dpkg/info/isante.list ]; then
    OLD_SVN_REVISION=`LANG=C dpkg -s isante | grep ^Version | sed -n 's/.*\?~\([0-9+]*\)-[0-9]*/\1/p'`
    oldVersion=`LANG=C dpkg -s isante | grep ^Version | sed -n 's/.*\? \(.*\)~[0-9+]*-[0-9]*/\1/p'`
    oldVersion="$oldVersion ($OLD_SVN_REVISION)"
elif [ -e /var/lib/dpkg/info/itech.list ]; then
    #before version 12.1 the package was called itech
    OLD_SVN_REVISION=`LANG=C dpkg -s itech | grep ^Version | sed -n 's/.*\?rr\([0-9]*\)-[0-9]*/\1/p'`
    if [[ -z $OLD_SVN_REVISION ]]; then
	echo "Could not find an old iSanté installation."
	exit 1
    fi
    
    #Find the version of the currently installed isante application
    #If it can not figure out the version use the string UNKNOWN
    if [ $OLD_SVN_REVISION -le 2848 ]; then
	oldVersion="7.0RC1 ($OLD_SVN_REVISION)"
	oldVersionShort=070rc01
    elif [ $OLD_SVN_REVISION -le 3794 ]; then
	oldVersion="7.0RC2 ($OLD_SVN_REVISION)"
	oldVersionShort=070rc02
    elif [ $OLD_SVN_REVISION -le 4187 ]; then
	oldVersion="8.0RC1 ($OLD_SVN_REVISION)"
	oldVersionShort=080rc01
    elif [ $OLD_SVN_REVISION -le 4197 ]; then
	oldVersion="8.0RC2 ($OLD_SVN_REVISION)"
	oldVersionShort=080rc02
    elif [ $OLD_SVN_REVISION -le 5223 ]; then
	oldVersion="9.0RC1 ($OLD_SVN_REVISION)"
	oldVersionShort=090rc01
    elif [ $OLD_SVN_REVISION -le 5412 ]; then
	oldVersion="9.0RC2 ($OLD_SVN_REVISION)"
	oldVersionShort=090rc02
    elif [ $OLD_SVN_REVISION -gt 5412 ]; then
	oldVersion="9.0RC3 ($OLD_SVN_REVISION)"
    oldVersionShort=090rc03
    else
	oldVersionShort=UNKNOWN
	echo "Current iSanté installation can not be upgraded."
	exit 1
    fi

    case $oldVersionShort in
	070rc01) CANT_UPGRADE=1;;
	070rc02) CANT_UPGRADE=1;;
	080rc01) CANT_UPGRADE=1;;
	080rc02) CANT_UPGRADE=1;;
    esac

    if [ $CANT_UPGRADE ]; then
	echo "Current iSanté installation $oldVersion too old to upgrade."
	exit 1
    fi
else
    echo "iSanté not installed. Can not upgrade."
    exit 1
fi
export oldVersion=$oldVersion


if [[ $OLD_SVN_REVISION =~ '[0-9]*' ]]; then
    if [[ $SVN_REVISION =~ '[0-9]*' ]]; then
	if [[ $OLD_SVN_REVISION -ge $SVN_REVISION ]]; then
	    echo "Upgrade unnecessary."
	    exit
	fi
    fi
fi

logFile="/var/log/itech/upgrade-$thisVersionPrefix~$SVN_REVISION.log"
touch "$logFile"
./upgrade-procedures.sh 2>&1| tee -a "$logFile"
