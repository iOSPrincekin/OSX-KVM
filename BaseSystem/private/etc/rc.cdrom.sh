#!/bin/sh
# Copyright 2000-2019, Apple Inc.

#
#
# NOTICE! 
# Most of rc.cdrom is in rc.install temporarily while portions are migrated to launchd
#
#

echo "rc.cdrom -- Arguments:[$@]"

#
# mount root_device to update vnode information
#
mount -u -o ro /

#
# Sanity check date & time. Pin to 4/1/1976.
#
if [ `date +%s` -lt 197193600 ]; then
  date 040100001976
fi

#
# Prepare PreLogin storage for use.
#
/usr/libexec/rc.prelogindata

#
# launchd passes the "boot mode" to us, if one is set for this boot
#
# in certain boot modes, we tell diskarbitrationd not to automatically
# mount any other volumes. This has to happen here, before launchd
# starts all the daemons, so we can be sure it is set before diskarbitrationd
# starts up.
boot_mode="$1"
if [ ! -z "$boot_mode" ]; then
	case "$boot_mode" in
	"fvunlock" | "kcgen")
		/usr/libexec/PlistBuddy -c "Add :DAAutoMountDisable bool true" /Library/Preferences/SystemConfiguration/com.apple.DiskArbitration.diskarbitrationd.plist
		;;
	esac
fi

# as of 20A180, this is only used by AutomationTrampoline
touch /var/run/rc.cdrom.done
