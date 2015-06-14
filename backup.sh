#!/bin/bash

#############################################################
#
#           script: backup.sh
#       written by: marek novotny
#          version: 3.0
#             date: Sat Jun 13 17:28:00 PST 2015
#          purpose: Create a tar backup of a target
#                 : and store it in a date-stamped file
#                 : in a specific backup location
#
#          licence: GPL v2 (only)
#       repository: http://www.github.com/marek-novotny
#
#############################################################

source="$(echo $1 | sed -e 's/\/$//')"
destRootPath="$HOME/Backups"
destPath="${destRootPath}/$(hostname -s)"
dateStamp=$(date +%Y_%m_%d)
tgtName="backup_${dateStamp}_${source}.tar.gz"

if (($# != 1)) ; then
	echo " Usage: ${0##*/} {target}"
	exit 1
fi

backupTarget()
{
	echo " Backup: ${source} has started..."
	tar -cpzf "${destPath}/${tgtName}" "${source}"

	sleep 5 # give NAS enough time to record the storage size
	size=$(du -hs "${destPath}/${tgtName}" | awk '{print $1}')

	echo " Backup Finished: ${tgtName} --Size: ${size}"
}

checkDestnations()
{
	if [[ -d "${destRootPath}" ]]
	then
		if [[ -r "${destRootPath}" ]] && [[ -w "${destRootPath}" ]]
		then
			if [[ -d "${destPath}" ]]
			then
				if [[ -r "${destPath}" ]] && [[ -w "${destPath}" ]]
				then
					return 0
				else
					echo " Folder: ${destPath} is not readable or writable..."
					exit 1
				fi
			else
				mkdir -p "${destPath}"
			fi
		else
			echo " Folder: ${destRootPath} is not readable or writable..."
			exit 1
		fi
	else
		echo " Folder: ${destRootPath} does not exist..."
		exit 1
	fi
}

checkPerms()
{
	items+=($(find "${source}" -type f))
	items+=($(find "${source}" -type d)) 
	for x in "${items[@]}" ; do
		test -r "$x"
		if (($? != 0)) ; then
			echo "$x is non-readable"
			exit 1
		else
			test -w "$x"
			if (($? != 0)) ; then
				echo "$x is non-writable"
				exit 1
			fi
		fi
	done
}

checkSource()
{
	if [[ ! -d "${source}" ]] || [[ ! -f "${source}" ]] ; then
		echo " Backup source: ${source} does not exist..."
		exit 1
	else
		return 0
	fi
}

checkSource
checkPerms
checkDestnations
backupTarget
