#!/bin/bash -e

echo -n "Running backup..."
if [ -e /usr/share/isante/htdocs/support/backup-db-linux.sh ]; then
    /bin/bash /usr/share/isante/htdocs/support/backup-db-linux.sh
elif [ -e /usr/share/itech/htdocs/support/backup-db-linux.sh ]; then
    #for versions before 12.1
    /bin/bash /usr/share/itech/htdocs/support/backup-db-linux.sh
else
    echo "could not find backup script."
    exit 1
fi
echo "done"
