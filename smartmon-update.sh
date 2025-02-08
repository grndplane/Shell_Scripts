#!/bin/bash
#
# Update the smartmon database
#
echo
clear
echo Current smartmon database date
echo
ls -l /var/lib/smartmontools/drivedb
echo
echo
echo Updating the smartmon database
echo
echo
#
rm drivedb.h
wget https://raw.githubusercontent.com/mirror/smartmontools/master/drivedb.h
sudo mv /var/lib/smartmontools/drivedb/drivedb.h /var/lib/smartmontools/drivedb/drivedb.h.old
sudo mv drivedb.h /var/lib/smartmontools/drivedb/
sudo chown -c root:root /var/lib/smartmontools/drivedb/drivedb.h
echo
echo Finished updating the smartmon database
echo
echo
ls -l /var/lib/smartmontools/drivedb
echo
