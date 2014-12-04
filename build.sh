#!/bin/bash -e

#gather information about this system
RELEASE_CODENAME=`lsb_release --short --codename`
ARCHITECTURE=`dpkg-architecture -qDEB_BUILD_ARCH`
BUILD_FLAVOR="$RELEASE_CODENAME-$ARCHITECTURE"


#build isante Debian packages
if [[ -z $1 ]]; then
    make -C isante-source dev
elif [[ $1 = "test" ]]; then
    make -C isante-source test
elif [[ $1 = "release" ]]; then
    make -C isante-source release
else
    echo "Don't know how to build a $1"
    exit 1
fi
rm -f local-packages-$BUILD_FLAVOR/isante-live-config*.deb
rm -f local-packages-$BUILD_FLAVOR/isante_*.deb
cp `ls -t1 isante-source/debian/built-packages/isante_*.deb | head -1` local-packages-$BUILD_FLAVOR/
cp `ls -t1 isante-source/debian/built-packages/isante-live-config*.deb | head -1` local-packages-$BUILD_FLAVOR/
SVN_REVISION=`LANG=C dpkg-deb --info local-packages-$BUILD_FLAVOR/isante_*.deb | grep "^ Version" | sed -n 's/.*\?~\([0-9+]*\)-[0-9]*/\1/p'`
thisVersionPrefix=`LANG=C dpkg-deb --info local-packages-$BUILD_FLAVOR/isante_*.deb | grep "^ Version" | sed -n 's/.*\? \(.*\)~[0-9+]*-[0-9]*/\1/p'`


#build additional packages not included with Debian
PACKAGES="confconsole turnkey-pylib python-dialog"
for PACKAGE in $PACKAGES; do
    (cd local-source/$PACKAGE && fakeroot ./debian/rules binary)
    (cd local-source/$PACKAGE && fakeroot ./debian/rules clean)
    rm -f local-packages-$BUILD_FLAVOR/$PACKAGE*.deb
    mv local-source/$PACKAGE*.deb local-packages-$BUILD_FLAVOR/
done


#build 
rm -rf temp-build
mkdir temp-build
find upgrade-package -type f -not -path '*/.svn/*' -exec install -D {} temp-build/{} \;
cp -f profiles/isante-$BUILD_FLAVOR.preseed temp-build/upgrade-package/itech.preseed
cp -f profiles/isante-$BUILD_FLAVOR.packages temp-build/upgrade-package/itech.packages
makeself --bzip2 ./temp-build/upgrade-package \
    upgrade "iSante Upgrade" ./upgrade.sh $thisVersionPrefix $SVN_REVISION
mkdir temp-build/upgrade-package/debs/
cp local-packages-$BUILD_FLAVOR/*.deb temp-build/upgrade-package/debs/
makeself --bzip2 ./temp-build/upgrade-package \
    "images/update-package-$thisVersionPrefix~$SVN_REVISION.sh" \
    "iSante Upgrade" ./upgrade.sh $thisVersionPrefix $SVN_REVISION 1
rm -rf temp-build


#build custom Debian installer
cd custom-installer && ./build.sh "$thisVersionPrefix ($SVN_REVISION)" && cd ../


#build CD
pwdLocation=`which pwd`
export simple_cdd_dir=`$pwdLocation`

build-simple-cdd \
    --locale fr_FR.UTF-8 \
    --keyboard us \
    --conf isante-cdd-$BUILD_FLAVOR.conf \
    --graphical-installer \
    --force-preseed
