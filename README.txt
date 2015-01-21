backup.sh
=========

The purpose of this simple bash shell script it to allow a simple
backup of any one specified directory in your current working
directory. 

Example:
========

$ backup.sh scripts

If I have a directory called scripts in my immediate working directory
it will be found, its full path recorded, and a tar.gz will be created
and stored in a specified backup repository. 

The full backup file name will look like this:

backup.2015_01_20.scripts.tar.gz

In my case it will be stored in $HOME/Backups/{machine name} because
my Backups directory is an NFS share and my other machines also 
backup to this same location. Each machine gets it's own directory
under the common NFS Backups storage facility. 

tar examples
============

To view the contents of your tar backup use:

$ tar tvf {tarball name}

Your tarball will have full paths stored. Like so:

home/marek/Documents/fluke/LRAT2000.PDF

If you wish to just restore up to the path which starts with fluke
you would use the following example:

tar xf {tarball name} --strip-components=3

That will remove the first 3 path levels from the restored tarball.
So it excludes home/marek/Documents and leaves fluke/LRAT2000.PDF

SETUP
=====

Search for the variable 'storagePath' and setup your own storage
location. 

-Marek
