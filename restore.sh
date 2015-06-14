#!/bin/bash

#############################################################
#
#           script: restore.sh
#       written by: marek novotny 
#          version: 1.1
#             date: Sun Jun 13 12:31:00 PDT 2015
#          purpose: restore backup tarballs
#
#          licence: GPL v2 (only)
#       repository: http://www.github.com/marek-novotny
#
#############################################################

sWord="$(echo $1 | sed -e 's/\/$//')"

if (($# != 1)) ; then
	echo " Usage: ${0##*/} {search word}"
	exit 1
fi

restore()
{
	if [[ -d "${originalPath}" ]] && [[ -w "${originalPath}" ]]
	then
		echo "  Target: ${originalPath} exists..."
		echo " Stage 1: Renaming existing directory..."
		mv "${originalPath}" "${originalPath}.bak"
		if (($? == 0))
		then
			echo " Stage 2: Extracting Tarball..."
			tar -xzf "${absTarball}" -C "${HOME}"
			if (($? == 0))
			then
				echo " Stage 3: Removing backup..."
				rm -rf "${originalPath}.bak"
				if (($? == 0))
				then
					echo " Stage 4: ${originalPath} restored..."
					exit 0
				fi
			fi
		fi
	else
		echo " Restoring ${originalPath}..."
		tar -xf "${absTarball}" -C "$HOME"
		exit 0
	fi
}

confirmRestore()
{
	while true; 
	do
		read -p " Write: ${absTarball##*/} -> $HOME (y/n): " mSelect
		case ${mSelect} in
			[Yy]* )
				restore
				;;
			[Nn]* )
				echo " Exiting..."
				exit 0
				;;
			* )
				echo " Input Error: Just (y/n): "
				;;
		esac
	done
}

checkStorage()
{
	srcSize=$(du -csk "${absTarball}" | tail -n1 | awk '{print $1}')
	tgtSize=$(df -k "$HOME" 2> /dev/null | tail -n1 | awk '{print $4}')
	if (((srcSize * 3) > tgtSize)) ; then
		echo "storage is low --abort"
		exit 1
	fi
}

checkItemPerm()
{
	if [[ ! -r "${absTarball}" ]] ; then
		echo " Backup: ${absTarball} cannot be read..."
		exit 1
	fi
}

chooseItem()
{
	PS3=$'\n Please choose an item source: '
	select choice in "${items[@]}" ; do
		absTarball="${sources}/${sFolder}/${choice}"
		dirName="$(echo ${choice} | awk -F'_' '{print $5}' | sed -e 's/\.tar\.gz$//')"
		originalPath="${HOME}/${dirName}"
		echo " Original path: ${originalPath}"
		return 0
	done
}

getItems()
{
	IFS=$'\n'
	cd "${sources}/${sFolder}"
	dirListing=($(ls))
	items=($(printf "%s\n" "${dirListing[@]}" | grep -i ${sWord} | sort))
	if (("${#items[@]}" == 0))
	then
		echo " Search word: ${sWord} found no hits in ${sFolder}"
		exit 1
	fi
}

checkPerms()
{
	if [[ -d "${sFolder}" ]] && [[ -r "${sFolder}" ]] ; then
		return 0
	else
		echo " Choice: ${sFolder} is not a folder or is unreadable..."
		return 1
 fi
} 

chooseSource()
{
	PS3=$'\n Please choose a backup source: '
	select choice in "${folders[@]}" ; do
		sFolder="${choice}"
		return 0
	done
}

getSources()
{
	sources="$HOME/Backups"
	if [[ -d "${sources}" ]] && [[ -r "${sources}" ]] ; then
		IFS=$'\n'
		cd "${sources}"
		folders=($(ls))
		if ((${#folders[@]} == 0)) ; then
			echo " Folder: ${sources} does not contain any targets..."
			return 1
		else
			return 0
		fi
	else
		echo " Folder: ${sources} does not exist or is unreadable..."
		return 1
	fi
}

getSources
chooseSource
checkPerms
getItems
chooseItem
checkItemPerm
checkStorage
confirmRestore
