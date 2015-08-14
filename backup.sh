#!/bin/bash

#############################################################
#
#           script: backup.sh
#       adapted by: dan purgert
#      original by: marek novotny
#          version: 0.1
#             date: Tue Aug 11 14:15:00 EDT 2015
#          purpose: Create a backup of a target
#                 : and store it in a date-stamped file
#                 : in a specific backup location
#
#          licence: GPL v2 (only)
#       repository: http://www.github.com/dpurgert
# (Marek's source): http://www.github.com/marek-novotny
#
#############################################################

if [ $# -eq 0 ] || [ $1 = "-h" ]; then
  echo "  
  backup.sh
  ---------
  Create a backup of a target and store it in a
  date-stamped file in a specific backup location
  
  Options:
   -h    Print this help text and exit
  
  Usage:
  backup.sh <config_file>
  
  
  Config File Parameters
    hostname -- your computer's hostname.  Usage 'hostname=<host>'
    dstRoot -- Destination root folder, full path is required.
      Usage 'dstRoot=</path/to/destination>'
    srcPath -- Source directory, full path is required. You can
    use as many 'srcPath' entries as you wish, one per line.
      Usage 'srcPath=</path/to/source>'
  
  Note - dstRoot and srcPath currently require full paths, as
  the script treats them as strings.
  ---------
"

  if [ $# -eq 0 ];then 
    exit 1
  else
    exit 0
  fi
fi

if [ ! -f $1 ]; then
  echo "You must provide a configuration file."
  exit 1
fi

DEBUG=0

#source="$(echo $1 | sed -e 's/\/$//')"
#destRootPath="$HOME/Backups"
#destPath="${destRootPath}/$(hostname -s)"
#dateStamp=$(date +%Y_%m_%d)
#tgtName="backup_${dateStamp}_${source}.tar.gz"

# Cleanup before setting new values from the config file
unset host
unset dstRoot
unset sourceArr

while IFS='' read -r line || [[ -n "$line" ]]; do 
    lineParam=$(echo $line | cut -d= -f1)
    paramVal=$(echo $line | cut -d= -f2)
    if [ $DEBUG -eq 1 ]; then    
      echo "
      read: $line
      ${lineParam}
      ......
      ${paramVal}
      "
    fi
    
    if [ $lineParam = "hostname" ]; then
        host=$paramVal
    elif [ $lineParam = "dstRoot" ]; then
        dstRoot=$paramVal
    elif [ $lineParam = "srcPath" ]; then
        sourceArr=("${sourceArr[@]}" $(echo $paramVal| sed -e\
     's/\/$//'))
    fi
done < $1

dstPath="${dstRoot}/$host"

if [ $DEBUG -eq 1 ]; then
 echo "
 This host is $host
 Backup destination root is $dstRoot
 Backup path is $dstPath
 sources for backup are ${sourceArr[@]}
 "
fi

if [ -z "$host" ]; then
  echo "Missing Host entry from config file."
  exit 1
fi

if [ -z "$dstRoot" ]; then 
  echo "Missing destination root directory in config file."
  exit 1
fi

if [ -z "${sourceArr[0]}" ]; then
  echo "Missing backup source in config file."
  exit 1
fi

backupTarget()
{
source=$1
destpath=$2
tgtName=$3

	echo " Backup: ${source} has started..."
	tar -cpzf "${destPath}/${tgtName}" "${source}" 2> /dev/null
	if (($? == 0))
	then
		sleep 5 # give NAS enough time to record the storage size
		size=$(du -hs "${destPath}/${tgtName}" | awk '{print $1}')
		echo " Backup Finished: ${tgtName} --Size: ${size}"
	else
		echo " Backup could not be written..."
		exit 1
	fi
}

checkStorage()
{
source=$1
destPath=$2
tgtName=$3

	tgtFolder=$(du -csk "${source}" 2> /dev/null | tail -n1 | awk '{print $1}')
	tgtPath=$(df -k "${destPath}" 2> /dev/null | tail -n1 | awk '{print $4}')
	if (((tgtFolder * 3) > tgtPath)) ; then
		echo "storage is low --abort"
		exit 1
	fi

	if [[ -f "${destPath}/${tgtName}" ]] && [[ ! -w "${destPath}/${tgtName}" ]]
	then
		echo " Backup: File exists and cannot be overwritten..."
		exit 1
	fi
}

checkDestnations()
{
destRootPath=$1
destPath=$2

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
source=$1
	IFS=$'\n'
	items+=($(find "${source}" -type f))
	items+=($(find "${source}" -type d)) 
	for x in "${items[@]}" ; do
		test -r "$x"
		if (($? != 0)) ; then
			echo "$x is non-readable"
			exit 1
		fi
	done
}

checkSource()
{
source=$1
	if [[ -f "${source}" ]] ; then
		echo " Backup source: ${source} is a file, not a directory..."
		exit 1
	elif [[ ! -d "${source}" ]] ; then
		echo " Backup source: ${source} does not exist..."
		exit 1
	else
		return 0
	fi
}


if [ $DEBUG -eq 1 ]; then
  for src in ${sourceArr[@]}; do
  {
    dateStamp=$(date +%Y_%m_%d)
    dstTarget="backup_${dateStamp}_${src}.tar.gz"
    echo "
    checkSource $src
    checkPerms $src
    checkDestnations $dstRoot $dstPath
    checkStorage $src $dstPath $dstTarget
    backupTarget $src $dstPath $dstTarget"
  }
  done
  echo "Debug mode only. Exiting without creating backup."
  exit 0
else
  for src in ${sourceArr[@]}; do
  {
    dateStamp=$(date +%Y_%m_%d)
    dstTarget="backup.${dateStamp}.$(echo $src | sed -e 's/\///'\
      | sed -e 's/\//_/g').tar.gz"
    checkSource ${src}
    checkPerms ${src}
    checkDestnations ${dstRoot} ${dstPath}
    checkStorage ${src} ${dstPath} ${dstTarget}
    backupTarget ${src} ${dstPath} ${dstTarget}
  }
  done
fi
