#!/bin/bash

#############################################################
#
#           script: backup.sh
#       written by: marek novotny
#          version: 2.0
#             date: Tue Jan 20 11:50:19 PST 2015
#          purpose: Create a tar backup of a directory
#                 : and store it in a date-stamped file
#                 : in a specific backup location
#
#          licence: GPL v2 (only)
#       repository: http://www.github.com/marek-novotny
#
#############################################################

# record the argument as the desired backup source directory name

source=$(echo $1 | sed -e 's/\/$//')

usageError()
{
	cat << EOF

	Usage Error!!

	Type: ${0##*/} {directory name}

	Execute the script with the directory name you wish to backup
	as the sole argument. 

EOF
}

# Make sure a single argument is used with the command or present usage

if (($# != 1))
then
	usageError
	exit
fi

pathNotFound()
{
	cat << EOF

	Path not Found!!

	Search for ${source} found no match... 
	Please try again...

EOF
}

# find the source directory at maxdepth -1 from working directory and set that as
# the backup target path

findPath()
{
	targetSource=$(find "${PWD}" -maxdepth 1 -type d -name "${source}" | sed -e 's/\/$//')
	if [ ! -d "${targetSource}" ]
	then
		pathNotFound
		exit
	fi
}

# setup the target tar file name with date stamp and backup target to backup facility

backupTarget()
{
	dateStamp=$(date +%Y_%m_%d)
	targetName="backup.${dateStamp}.${source##*/}.tar.gz"

	# setup your storage path here. 

	storagePath="$HOME/Backups/$(hostname --short)"
	if [ ! -d "${storagePath}" ]
	then
		mkdir -p "${storagePath}"
	fi

	printf "\nBackup started: %s...\n\n" "${targetSource}"
	tar cpzf "${storagePath}/${targetName}" "${targetSource}"

	sleep 5 # give NAS enough time to record the storage size
	size=$(du -hs "${storagePath}/${targetName}" | awk '{print $1}')

	printf "\n  Backup Finished: %s --Size: %s\n\n" "${targetName}" "${size}"
}

findPath
backupTarget
