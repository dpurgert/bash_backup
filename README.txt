backup.sh
=========

The purpose of this simple bash shell script it to allow a simple backup
of one or more directories specified in the configuration file.

This is a fork of Marek Novotny's "bash_backup" script, which can be
found at http://github.com/marek-novotny.

Example:
========

$ backup.sh config_file.txt

The script will read the configuration values in from the file (see
"Setup" section below), and proceed to create individual .tar.gz files
from the individual source paths provided in the configuration file.

The full backup file name will look like this:

backup.2015_01_20.path_to_source.tar.gz

In the example case, the backup will be stored /mnt/NFS_Backups/<host>,
as the assumption is that this can be used for multiple hosts all
backing up to a single location.  

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

Create a configuration file with the following parameters:

  - hostname=<hostname>
  - dstRoot=</path/to/destination>
  - srcPath=</path/to/source

Note that the "hostname" and "dstRoot" can be used at most once in the
configuration file.  Any additional uses of these two keywords will
simply overwrite previous entries once the file is read in by the
script.

-Dan
