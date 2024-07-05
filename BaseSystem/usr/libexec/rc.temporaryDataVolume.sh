#!/bin/sh

echo "rc.temporaryDataVolume -- Arguments:[$@]"

#
# Create a RAM disk with same perms as mountpoint
#
RAMDisk()
{
  mntpt="$1"
  rdsize="$2"
  echo "Creating RAM Disk for $mntpt"
  dev=`hdik -drivekey system-image=yes -nomount "ram://$rdsize"`
  if [ $? -eq 0 ] ; then
    newfs_hfs $dev
    # save & restore fs permissions covered by the mount
    eval `/usr/bin/stat -s "$mntpt"`
    mount -t hfs -o union -o nobrowse $dev "$mntpt"
    chown "$st_uid:$st_gid" "$mntpt"
    chmod "$st_mode" "$mntpt"
  fi
}

if [ -f "/etc/rc.diag.cdrom" ]; then
	. /etc/rc.diag.cdrom
elif [ -x /etc/rc.gh.cdrom ]; then
	. /etc/rc.gh.cdrom
elif [ -d /System/Library/Templates/Data ]; then
	DATA_MB=2560
	if DATA_BLOCKS_ASSIGNMENT=`sysctl kern.bootargs | grep -o 'bs_data_size=[0-9]\+'`; then
		eval "$DATA_BLOCKS_ASSIGNMENT"
		DATA_MB=$bs_data_size
	fi

	set -ex
	/sbin/mount_tmpfs -s $(($DATA_MB*1024*1024)) /System/Volumes/Data

	ditto /System/Library/Templates/Data /System/Volumes/Data/

	# Work around some people who can't do their own mkdir...
	mkdir -p /var/log/dm # rdar://60639245
	mkdir -p /var/tmp/RecoveryTemp
	mkdir -p /var/tmp/InstallerCookies
	mkdir -p /var/tmp/OSISPredicateUpdateProductTemp
	mkdir -p /var/root/Library/Keychains
	mkdir -p /var/root/Library/Containers
	mkdir -p -m 1777 /var/db/mds
	
	# Set the language if we have prev-lang:kbd
	/usr/libexec/setlanguage
	
	# Work around the fact that things seem particularly sensitive to /Volumes
	# being a symlink (rdar://60734851).
	/sbin/mount_tmpfs -s $((32*1024*1024)) /Volumes

	# Mounts the System Recovery volume in the Recovery container and copies the boot
	# objects out of that volume into a newly created Preboot tmpfs volume.
	# This only occurs on ARM based Macs; on Intel this exits 0 without doing any work.
	/usr/libexec/prebootensurer
	set +ex
else
	# Mount all our writable temporary locations first. For tmpfs to be safe
	# (since we cannot -o union), the paths must be empty in the BaseSystem.
	/sbin/mount_tmpfs /private/tmp
	/sbin/mount_tmpfs /private/var/tmp
	/sbin/mount_tmpfs /private/var/folders

	RAMDisk /var/log 20480
	mkdir -p /var/log/dm
	RAMDisk /var/log/dm 20480
	RAMDisk /Volumes 1024
	RAMDisk /var/run 1024
	RAMDisk /var/rpc/ncacn_np 1024 # 512 KB

	RAMDisk /System/Installation 1024

	VAR_DB_BLOCKS=20480
	if VAR_DB_EXTRA_ASSIGNMENT=`sysctl kern.bootargs | grep -o 'bs_var_db_extra=[0-9]\+'`; then
		eval "$VAR_DB_EXTRA_ASSIGNMENT"
		VAR_DB_BLOCKS=$(($VAR_DB_BLOCKS + $bs_var_db_extra))
	fi
	RAMDisk /var/db $VAR_DB_BLOCKS
    RAMDisk /var/db/com.apple.xpc.roleaccountd.staging 4096 # 2 MB
	RAMDisk /var/root/Library 8192
	RAMDisk /Library/ColorSync/Profiles/Displays 2048

	mkdir /var/root/Library/Keychains
	mkdir /var/root/Library/Containers

	mkdir /var/tmp/RecoveryTemp
	mkdir /var/tmp/InstallerCookies
	mkdir /var/tmp/OSISPredicateUpdateProductTemp
	mkdir -m 1777 /var/db/mds

	RAMDisk /var/root/Library/Containers 4096
	RAMDisk	/Library/Preferences 1024
	RAMDisk /Library/Preferences/Logging 4096
	RAMDisk	/Library/Preferences/SystemConfiguration 1024
	RAMDisk /Library/Keychains 2048
	RAMDisk "/Library/Security/Trust Settings" 1024
	RAMDisk /Library/Logs 1024
	mkdir -p /Library/Logs/DiagnosticReportsForNewHardware
	RAMDisk /Library/Logs/DiagnosticReportsForNewHardware 4096
	RAMDisk /Library/Logs/DiagnosticReports 4096

	# Set the language if we have prev-lang:kbd
	/usr/libexec/setlanguage

	BOOT_RECOVERY_REQUIRED_TOOL="/System/Installation/CDIS/Boot Recovery Assistant.app/Contents/Resources/recovery_required"
	if [ -f "$BOOT_RECOVERY_REQUIRED_TOOL" ] ; then
		PERSONALIZATION_RAMDISK_REQUIRED=`"$BOOT_RECOVERY_REQUIRED_TOOL" personalization`
		if [ $PERSONALIZATION_RAMDISK_REQUIRED = "1" ] ; then
			mkdir /var/tmp/OSPersonalizationTemp
		fi

		BRIDGEOS_RAMDISK_REQUIRED=`"$BOOT_RECOVERY_REQUIRED_TOOL" bridgeos`
		if [ $BRIDGEOS_RAMDISK_REQUIRED = "1" ] ; then
			mkdir /var/tmp/BridgeOSUpdateTemp
		fi
	fi
fi

