#!/bin/bash -e

#Make sure there is a working Debian repository available and retrieve any needed packages.
./repository.sh
REPOSITORY_STATUS=$?
if [ $REPOSITORY_STATUS != 0 ]; then
    echo Upgrade can not continue.
    exit $REPOSITORY_STATUS
fi

#Give the user a chance to abort after the potentially long step of downloading packages.
echo
echo "Will now upgrade iSanté from $oldVersion to version $thisVersion."
echo
read -p "Press ENTER to continue. (CTRL+C to abort)"

#Set Apache to show a server maintenance message.
echo -n "Shutting down application..."
find /etc/apache2/sites-available -type f -printf "%f\n" | xargs -i a2dissite {} > /dev/null
cp -f helpers/maintenance-apache.conf /etc/apache2/sites-available/maintenance
cp -f helpers/maintenance.html /var/www/
a2ensite maintenance > /dev/null
invoke-rc.d apache2 reload > /dev/null
echo "done"

#Take a backup using the current installation.
invoke-rc.d cron stop > /dev/null #make sure non of the scheduled tasks run during the backup
./backup.sh

#Setup any new required Debian packages.
./packages.sh

#run setup-isante.pl to configure the server
setup-isante.pl
