#!/bin/bash

REQUIRED_PACKAGES=`grep ^[^#] ./itech.packages`
MISSING_PACKAGES=''
EXCLUDED_PACKAGES=''

#exclude any packages included in the debs directory, include any packages they depend on
for file in debs/*.deb; do
    packageName=`dpkg-deb --showformat=\\${Package} --show $file`
    EXCLUDED_PACKAGES="$EXCLUDED_PACKAGES $packageName"
    extraRequiredPackages=`dpkg-deb --showformat=\\${Depends} --show $file | sed 's/ ([^)]*)//g' - | sed 's/,//g' -` #first sed removes version numbers second one removes commas
    REQUIRED_PACKAGES="$REQUIRED_PACKAGES $extraRequiredPackages"
done

function includePackage() {
    excluded=(cirg-backdoor turnkey-pylib python-dialog isante-live-config confconsole mosh)
    if [ -z "$1" ]; then
	return
    fi

    for i in $EXCLUDED_PACKAGES; do
	if [ $i == $1 ]; then
	    return 0
	fi
    done
    
    return 1
}

for package in $REQUIRED_PACKAGES; do
    package_data=`dpkg -s $package 2>/dev/null | grep ^Status | grep -q installed`
    if [ $? != 0 ]; then
	includePackage "$package"
	if [ $? == 1 ]; then
            MISSING_PACKAGES="$MISSING_PACKAGES $package"
	fi
    fi
done

echo $MISSING_PACKAGES
