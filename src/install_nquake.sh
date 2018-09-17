#!/bin/bash

# nQuake Bash Installer Script v2.4 (for Linux)
# by Empezar

# Check if unzip is installed
unzip=`which unzip`
if [ "$unzip"  = "" ]
then
	echo "Unzip is not installed. Please install it and run the nQuake installation again."
	exit
fi

# Download function
error=false
function distdl {
	wget --inet4-only -O $2 $1/$2
	if [ -s $2 ]
	then
		if [ "$(du $2 | cut -f1)" \> "0" ]
		then
			error=false
		else
			error=true
		fi
	else
		error=true
	fi
}

echo
echo "Welcome to the nQuake v2.4 installation"
echo "======================================="
echo
echo "Press ENTER to use [default] option."
echo

# Create the nQuake folder
echo "=== Installation Directory ==="
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
		created=true
	else
		echo
		echo "Error: You do not have write access to $directory. Exiting."
		exit
	fi
else
	if [ -e "$directory" ]
	then
		echo
		echo "Error: $directory already exists and is a file, not a directory. Exiting."
		exit
	else
		mkdir -p $directory 2> /dev/null
		created=true
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
echo

# Ask for addons
echo "=== Addons ==="
read -p "Do you want to install the Clan Arena addon? (y/n) [n]: " clanarena
read -p "Do you want to install the Team Fortress addon? (y/n) [n]: " fortress
read -p "Do you want to install the High Resolution Textures addon? (y/n) [n]: " textures
echo

# Search for pak1.pak
echo "=== Full Game ==="
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
		echo
		echo "* Found at location $pak"
	else
		echo
		echo "* Could not find pak1.pak"
	fi
fi
echo

# Download nquake.ini
wget --inet4-only -q -O nquake.ini https://raw.githubusercontent.com/nQuake/client-win32/master/etc/nquake.ini
if [ -s "nquake.ini" ]
then
	echo foo >> /dev/null
else
	echo "=== Installation Failed ==="
	echo "Error: Could not download nquake.ini. Better luck next time. Exiting."
	if [ "$created" = true ]
	then
		cd
		echo
		read -p "The directory $directory is about to be removed, press Enter to confirm or CTRL+C to exit." remove
		rm -rf $directory
	fi
	exit
fi

# List all the available mirrors
echo "=== Download Location ==="
echo "From what mirror would you like to download nQuake?"
grep "[0-9]\{1,2\}=\".*" nquake.ini | cut -d "\"" -f2 | nl
read -p "Enter mirror number [random]: " mirror
mirror=$(grep "^$mirror=[fhtp]\{3,4\}://[^ ]*$" nquake.ini | cut -d "=" -f2)
if [ "$mirror" = "" ]
then
	echo
	echo -n "* Using mirror: "
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
echo

# Download all the packages
echo "=== Downloading ==="
distdl $mirror qsw106.zip
if [ "$error" = false ]
then
	distdl $mirror gpl.zip
fi
if [ "$error" = false ]
then
	distdl $mirror non-gpl.zip
fi
if [ "$error" = false ]
then
	distdl $mirror linux.zip
fi
if [ "$error" = false ]
then
	if [ "$clanarena" = "y" ]
	then
		distdl $mirror addon-clanarena.zip
	fi
fi
if [ "$error" = false ]
then
	if [ "$fortress" = "y" ]
	then
		distdl $mirror addon-fortress.zip
	fi
fi
if [ "$error" = false ]
then
	if [ "$textures" = "y" ]
	then
		distdl $mirror addon-textures.zip
	fi
fi

# Terminate installation if not all packages were downloaded
if [ "$error" = true ]
then
	echo "=== Installation Failed ==="
	echo "Some distribution files failed to download. Better luck next time. Exiting."
	rm -rf $directory/qsw106.zip $directory/gpl.zip $directory/non-gpl.zip $directory/linux.zip $directory/addon-clanarena.zip $directory/addon-fortress.zip $directory/addon-textures.zip $directory/nquake.ini
	if [ "$created" = true ]
	then
		cd
		echo
		read -p "The directory $directory is about to be removed, press Enter to confirm or CTRL+C to exit." remove
		rm -rf $directory
	fi
	exit
fi

# Extract all the packages
echo "=== Installing ==="
echo -n "* Extracting Quake v1.06 Shareware..."
unzip -qqo qsw106.zip ID1/PAK0.PAK 2> /dev/null
echo "done"
echo -n "* Extracting nQuake setup files (1 of 2)..."
unzip -qqo gpl.zip 2> /dev/null
echo "done"
echo -n "* Extracting nQuake setup files (2 of 2)..."
unzip -qqo non-gpl.zip 2> /dev/null
echo "done"
echo -n "* Extracting nQuake Linux files..."
unzip -qqo linux.zip 2> /dev/null
echo "done"
if [ "$clanarena" = "y" ]
then
	echo -n "* Extracting Clan Arena addon..."
	unzip -qqo addon-clanarena.zip 2> /dev/null
	echo "done"
fi
if [ "$fortress" = "y" ]
then
	echo -n "* Extracting Team Fortress addon..."
	unzip -qqo addon-fortress.zip 2> /dev/null
	echo "done"
fi
if [ "$textures" = "y" ]
then
	echo -n "* Extracting High Resolution Textures addon..."
	unzip -qqo addon-textures.zip 2> /dev/null
	echo "done"
fi
if [ "$pak" != "" ]
then
	echo -n "* Copying pak1.pak..."
	cp $pak $directory/id1/pak1.pak 2> /dev/null
	rm -rf $directory/id1/gpl-maps.pk3 $directory/id1/readme.txt
	echo "done"
fi
echo

# Cleanup
echo "=== Cleaning up ==="
# Rename files
echo -n "* Renaming files..."
mv $directory/ID1/PAK0.PAK $directory/id1/pak0.pak 2> /dev/null
rm -rf $directory/ID1
echo "done"
# Remove the Windows specific files
echo -n "* Removing Windows specific binaries..."
rm -rf $directory/ezquake.exe $directory/ezquake/sb/wget.exe
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
rm -rf $directory/qsw106.zip $directory/gpl.zip $directory/non-gpl.zip $directory/linux.zip $directory/addon-clanarena.zip $directory/addon-fortress.zip $directory/addon-textures.zip $directory/nquake.ini $directory/x86.zip $directory/x64.zip
echo "done"
# Convert DOS files to UNIX
echo -n "* Converting DOS files to UNIX..."
for file in $directory/*.txt $directory/id1/*.txt $directory/qw/*.txt $directory/ezquake/cfg/* $directory/ezquake/configs/* $directory/ezquake/sb/* $directory/ezquake/*.txt $directory/fortress/*.cfg $directory/prox/configs/*.cfg
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
echo "done"

# Create an install_dir in ~/.nquake detailing where nQuake is installed
mkdir -p ~/.nquake
rm -rf ~/.nquake/install_dir
echo $directory >> ~/.nquake/install_dir

echo
echo "=== Installation Complete ==="
echo "nQuake was successfully installed. To start playing, please untar the correct binary for your distribution."
echo
echo "Happy gibbing!"
echo