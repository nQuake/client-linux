#!/bin/bash

# nQuake Bash Installer Script v2.0 (for Linux)
# by Empezar

# Check if unzip is installed
unzip=`which unzip`
if [ "$unzip"  = "" ]
then
	echo "Unzip is not installed. Please install it and run the nQuake installation again."
	exit
fi

echo
echo Welcome to the nQuake v2.0 installation
echo =======================================
echo
echo Press ENTER to use [default] option.
echo

# Create the nQuake folder
defaultdir="~/nquake"
read -p "Where do you want to install nQuake? [$defaultdir]: " directory
if [ "$directory" = "" ]
then
        directory=$defaultdir
fi
eval directory=$directory
if [ -d "$directory" ]
then
	if [ -w "$directory" ]
	then
		created=0
	else
		echo;echo "Error: You do not have write access to $directory. Exiting."
		exit
	fi
else
	if [ -e "$directory" ]
	then
		echo;echo "Error: $directory already exists and is a file, not a directory. Exiting."
		exit
	else
		mkdir -p $directory 2> /dev/null
		created=1
	fi
fi
if [ -d "$directory" ] && [ -w "$directory" ]
then
	cd $directory
	directory=$(pwd)
else
	echo;echo "Error: You do not have write access to $directory. Exiting."
	exit
fi

# Search for pak1.pak
defaultsearchdir="~/"
pak=""
read -p "Do you want setup to search for pak1.pak? (y/n) [n]: " search
if [ "$search" = "y" ]
then
	read -p "Enter path to search for pak1.pak [$defaultsearchdir]: " path
	if [ "$path" = "" ]
	then
		path=$defaultsearchdir
	fi
	eval path=$path
	pak=$(echo $(find $path -type f -iname "pak1.pak" -size 33M -exec echo {} \; 2> /dev/null) | cut -d " " -f1)
	if [ "$pak" != "" ]
	then
		echo;echo "* Found at location $pak"
	else
		echo;echo "* Could not find pak1.pak"
	fi
fi
echo

# Download nquake.ini
wget --inet4-only -q -O nquake.ini http://nquake.sourceforge.net/nquake.ini
if [ -s "nquake.ini" ]
then
	echo foo >> /dev/null
else
	echo "Error: Could not download nquake.ini. Better luck next time. Exiting."
        if [ "$created" = "1" ]
        then
                cd
		read -p "The directory $directory is about to be removed, press Enter to confirm or CTRL+C to exit." remove
                rm -rf $directory
        fi
	exit
fi

# List all the available mirrors
echo "From what mirror would you like to download nQuake?"
grep "[0-9]\{1,2\}=\".*" nquake.ini | cut -d "\"" -f2 | nl
read -p "Enter mirror number [random]: " mirror
mirror=$(grep "^$mirror=[fhtp]\{3,4\}://[^ ]*$" nquake.ini | cut -d "=" -f2)
if [ "$mirror" = "" ]
then
        echo;echo -n "* Using mirror: "
        RANGE=$(expr$(grep "[0-9]\{1,2\}=\".*" nquake.ini | cut -d "\"" -f2 | nl | tail -n1 | cut -f1) + 1)
        while [ "$mirror" = "" ]
        do
                number=$RANDOM
                let "number %= $RANGE"
                mirror=$(grep "^$number=[fhtp]\{3,4\}://[^ ]*$" nquake.ini | cut -d "=" -f2)
		mirrorname=$(grep "^$number=\".*" nquake.ini | cut -d "\"" -f2)
        done
        echo "$mirrorname"
fi
mkdir -p id1
echo;echo

# Download all the packages
echo "=== Downloading ==="
wget --inet4-only -O qsw106.zip $mirror/qsw106.zip
if [ -s "qsw106.zip" ]
then
	if [ "$(du qsw106.zip | cut -f1)" \> "0" ]
	then
	        wget --inet4-only -O gpl.zip $mirror/gpl.zip
	fi
fi
if [ -s "gpl.zip" ]
then
	if [ "$(du gpl.zip | cut -f1)" \> "0" ]
	then
		wget --inet4-only -O non-gpl.zip $mirror/non-gpl.zip
	fi
fi
if [ -s "non-gpl.zip" ]
then
        if [ "$(du non-gpl.zip | cut -f1)" \> "0" ]
        then
                wget --inet4-only -O linux.zip $mirror/linux.zip
        fi
fi

# Terminate installation if not all packages were downloaded
if [ -s "linux.zip" ]
then
	if [ "$(du linux.zip | cut -f1)" \> "0" ]
	then
		echo foo >> /dev/null
	else
		echo "Error: Some distribution files failed to download. Better luck next time. Exiting."
		rm -rf $directory/qsw106.zip $directory/gpl.zip $directory/non-gpl.zip $directory/linux.zip $directory/nquake.ini
		if [ "$created" = "1" ]
		then
			cd
			read -p "The directory $directory is about to be removed, press Enter to confirm or CTRL+C to exit." remove
			rm -rf $directory
		fi
		exit
	fi
else
	echo "Error: Some distribution files failed to download. Better luck next time. Exiting."
	rm -rf $directory/qsw106.zip $directory/gpl.zip $directory/non-gpl.zip $directory/linux.zip $directory/nquake.ini
	if [ "$created" = "1" ]
	then
		cd
		read -p "The directory $directory is about to be removed, press Enter to confirm or CTRL+C to exit." remove
		rm -rf $directory
	fi
	exit
fi

# Extract all the packages
echo "=== Installing ==="
echo -n "* Extracting Quake Shareware..."
unzip -qqo qsw106.zip ID1/PAK0.PAK 2> /dev/null;echo "done"
echo -n "* Extracting nQuake setup files (1 of 2)..."
unzip -qqo gpl.zip 2> /dev/null;echo "done"
echo -n "* Extracting nQuake setup files (2 of 2)..."
unzip -qqo non-gpl.zip 2> /dev/null;echo "done"
echo -n "* Extracting nQuake Linux files..."
unzip -qqo linux.zip 2> /dev/null;echo "done"
if [ "$pak" != "" ]
then
	echo -n "* Copying pak1.pak..."
	cp $pak $directory/id1/pak1.pak 2> /dev/null;echo "done"
	rm -rf $directory/id1/gpl-maps.pk3 $directory/id1/readme.txt
fi
echo

# Rename files
echo "=== Cleaning up ==="
echo -n "* Renaming files..."
mv $directory/ID1/PAK0.PAK $directory/id1/pak0.pak 2> /dev/null
mv $directory/ezquake/sb/update_sources.bat $directory/ezquake/sb/update_sources
rm -rf $directory/ID1
echo "done"

# Remove the Windows specific files
echo -n "* Removing Windows specific binaries..."
rm -rf $directory/ezquake-gl.exe $directory/ezquake/sb/wget.exe
echo "done"

# Set architecture
echo -n "* Setting architecture..."
binary=`uname -i`
if [ "$binary" == "x86_64" ]
then
	unzip -qqo $directory/x64.zip 2> /dev/null
else
        unzip -qqo $directory/x86.zip 2> /dev/null
fi
echo "done"

# Remove distribution files
echo -n "* Removing distribution files..."
rm -rf $directory/qsw106.zip $directory/gpl.zip $directory/non-gpl.zip $directory/linux.zip $directory/nquake.ini $directory/x86.zip $directory/x64.zip
echo "done"

# Make Linux related updates
echo -n "* Making Linux related updates..."
# Add some more suitable variables to config.cfg
echo >> $directory/ezquake/configs/config.cfg
cat $directory/ezquake/configs/config-linux.cfg >> $directory/ezquake/configs/config.cfg
rm -rf $directory/ezquake/configs/config-linux.cfg
echo "done"

# Convert DOS files to UNIX
echo -n "* Converting DOS files to UNIX..."
for file in $directory/readme.txt $directory/id1/readme.txt $directory/ezquake/cfg/* $directory/ezquake/configs/* $directory/ezquake/sb/* $directory/ezquake/gnu.txt
do
	if [ -f "$file" ]
	then
	        awk '{ sub("\r$", ""); print }' $file > /tmp/.nquake.tmp
        	mv /tmp/.nquake.tmp $file
	fi
done
echo "done"

# Set the correct permissions
echo -n "* Setting permissions..."
find $directory -type f -exec chmod -f 644 {} \;
find $directory -type d -exec chmod -f 755 {} \;
chmod -f +x $directory/ezquake-gl.glx 2> /dev/null
chmod -f +x $directory/ezquake.svga 2> /dev/null
chmod -f +x $directory/ezquake.x11 2> /dev/null
chmod -f +x $directory/ezquake/sb/update_sources 2> /dev/null
echo "done"

# Create an install_dir in ~/.nquake detailing where nQuake is installed
mkdir -p ~/.nquake
rm -rf ~/.nquake/install_dir
echo $directory >> ~/.nquake/install_dir

echo;echo "Note:"
echo "For optimal mouse support, run /evdevlist and set your /in_evdevice to the right device number (ingame). Ensure that /in_mouse is 3 and then do /in_restart (also ingame). Note that you need to \"sudo chmod 644 /dev/input/event??\" for this to work."
echo;echo "The default resolution is set for a widescreen display. If you have a non-widescreen display, a black bar will appear at the top of your screen. To fix this, go to Options -> System and change your resolution accordingly."
echo;echo "Installation complete. Happy gibbing!"
