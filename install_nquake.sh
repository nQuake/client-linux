#!/bin/bash

# nQuake Bash Installer Script v1.3b (for Linux)
# by Empezar

echo
echo Welcome to the nQuake installation
echo ==================================
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
wget -q -O nquake.ini http://nquake.sourceforge.net/nquake.ini
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
wget -O demos.zip $mirror/demos.zip
if [ -s "demos.zip" ]
then
	if [ "$(du demos.zip | cut -f1)" \> "0" ]
	then
	        wget -O textures.zip $mirror/textures.zip
	fi
fi
if [ -s "textures.zip" ]
then
	if [ "$(du textures.zip | cut -f1)" \> "0" ]
	then
		wget -O models.zip $mirror/models.zip
	fi
fi
if [ -s "models.zip" ]
then
        if [ "$(du models.zip | cut -f1)" \> "0" ]
        then
                wget -O skins.zip $mirror/skins.zip
        fi
fi
if [ -s "skins.zip" ]
then
        if [ "$(du skins.zip | cut -f1)" \> "0" ]
        then
                wget -O lits.zip $mirror/lits.zip
        fi
fi
if [ -s "lits.zip" ]
then
        if [ "$(du lits.zip | cut -f1)" \> "0" ]
        then
                wget -O ezquake.zip $mirror/ezquake.zip
        fi
fi
if [ -s "ezquake.zip" ]
then
	if [ "$(du ezquake.zip | cut -f1)" \> "0" ]
	then
		wget -O ezquake-linux.zip $mirror/ezquake-linux.zip
	fi
fi
if [ -s "ezquake-linux.zip" ]
then
	if [ "$(du ezquake-linux.zip | cut -f1)" \> "0" ]
	then
		wget -O frogbot.zip $mirror/frogbot.zip
	fi
fi
if [ -s "frogbot.zip" ]
then
	if [ "$(du frogbot.zip | cut -f1)" \> "0" ]
	then
		wget -O maps.zip $mirror/maps.zip
	fi
fi
if [ -s "maps.zip" ]
then
	if [ "$(du maps.zip | cut -f1)" \> "0" ]
	then
		wget -O misc.zip $mirror/misc.zip
	fi
fi
if [ -s "misc.zip" ]
then
	if [ "$(du misc.zip | cut -f1)" \> "0" ]
	then
		wget -O misc-linux.zip $mirror/misc-linux.zip
	fi
fi
if [ -s "misc-linux.zip" ]
then
        if [ "$(du misc-linux.zip | cut -f1)" \> "0" ]
        then
                wget -O misc_gpl.zip $mirror/misc_gpl.zip
        fi
fi
if [ -s "misc_gpl.zip" ]
then
        if [ "$(du misc_gpl.zip | cut -f1)" \> "0" ]
        then
                wget -O misc_gpl-linux.zip $mirror/misc_gpl-linux.zip
        fi
fi
if [ -s "misc_gpl-linux.zip" ]
then
	if [ "$(du misc_gpl-linux.zip | cut -f1)" \> "0" ]
	then
		wget -O qsw106.zip $mirror/qsw106.zip
	fi
fi

# Terminate installation if not all packages were downloaded
if [ -s "qsw106.zip" ]
then
	if [ "$(du qsw106.zip | cut -f1)" \> "0" ]
	then
		echo foo >> /dev/null
	else
		echo "Error: Some distribution files failed to download. Better luck next time. Exiting."
		rm -rf $directory/demos.zip $directory/textures.zip $directory/models.zip $directory/skins.zip $directory/lits.zip $directory/ezquake.zip $directory/ezquake-linux.zip $directory/frogbot.zip $directory/maps.zip $directory/misc.zip $directory/misc-linux.zip $directory/misc_gpl.zip $directory/misc_gpl-linux.zip $directory/qsw106.zip $directory/nquake.ini
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
	rm -rf $directory/demos.zip $directory/textures.zip $directory/models.zip $directory/skins.zip $directory/lits.zip $directory/ezquake.zip $directory/ezquake-linux.zip $directory/frogbot.zip $directory/maps.zip $directory/misc.zip $directory/misc-linux.zip $directory/misc_gpl.zip $directory/misc_gpl.zip $directory/qsw106.zip $directory/nquake.ini
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
echo -n "* Extracting demos.zip..."
unzip -qqo demos.zip 2> /dev/null;echo "done"
echo -n "* Extracting textures.zip..."
unzip -qqo textures.zip 2> /dev/null;echo "done"
echo -n "* Extracting models.zip..."
unzip -qqo models.zip 2> /dev/null;echo "done"
echo -n "* Extracting skins.zip..."
unzip -qqo skins.zip 2> /dev/null;echo "done"
echo -n "* Extracting lits.zip..."
unzip -qqo lits.zip 2> /dev/null;echo "done"
echo -n "* Extracting ezquake.zip..."
unzip -qqo ezquake.zip 2> /dev/null;echo "done"
echo -n "* Extracting ezquake-linux.zip..."
unzip -qqo ezquake-linux.zip 2> /dev/null;echo "done"
echo -n "* Extracting frogbot.zip..."
unzip -qqo frogbot.zip 2> /dev/null;echo "done"
echo -n "* Extracting maps.zip..."
unzip -qqo maps.zip 2> /dev/null;echo "done"
echo -n "* Extracting misc.zip..."
unzip -qqo misc.zip 2> /dev/null;echo "done"
echo -n "* Extracting misc-linux.zip..."
unzip -qqo misc-linux.zip 2> /dev/null;echo "done"
echo -n "* Extracting misc_gpl.zip..."
unzip -qqo misc_gpl.zip 2> /dev/null;echo "done"
echo -n "* Extracting misc_gpl-linux.zip..."
unzip -qqo misc_gpl-linux.zip 2> /dev/null;echo "done"
echo -n "* Extracting qsw106.zip..."
unzip -qqo qsw106.zip ID1/PAK0.PAK 2> /dev/null;echo "done"
if [ "$pak" != "" ]
then
	echo -n "* Copying pak1.pak..."
	cp $pak $directory/id1/pak1.pak 2> /dev/null;echo "done"
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
rm -rf $directory/ezquake-gl.exe $directory/ezquake/sb/wget.exe $directory/qw/qizmo $directory/qw/qwdtools/qwdtools.exe
echo "done"

# Remove distribution files
echo -n "* Removing distribution files..."
rm -rf $directory/demos.zip $directory/textures.zip $directory/models.zip $directory/skins.zip $directory/lits.zip $directory/ezquake.zip $directory/ezquake-linux.zip $directory/frogbot.zip $directory/maps.zip $directory/misc.zip $directory/misc-linux.zip $directory/misc_gpl.zip $directory/misc_gpl-linux.zip $directory/qsw106.zip $directory/nquake.ini
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
for file in $directory/readme.txt $directory/ezquake/cfg/* $directory/ezquake/configs/* $directory/ezquake/keymaps/* $directory/ezquake/sb/* $directory/ezquake/gnu.txt $directory/qw/autoexec.cfg $directory/qw/pak.lst $directory/qw/qwdtools/qwdtools.ini
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
chmod -f +x $directory/ezquake/sb/update_sources 2> /dev/null
chmod -f +x $directory/qw/qwdtools/qwdtools 2> /dev/null
echo "done"

echo;echo "Installation complete. Happy gibbing!"
