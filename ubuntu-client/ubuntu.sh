#!/bin/bash


# Copyright (©) 2003-2022 Teus Benschop.

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.


SCRIPTFOLDER=`dirname $0`
cd $SCRIPTFOLDER
SCRIPTFOLDER=`pwd`
echo Running builder in $SCRIPTFOLDER


echo Create a tarball for the Linux Client
../../linux/tarball-macos.sh
if [ $? -ne 0 ]; then exit; fi


export LANG="C"
export LC_ALL="C"


cd $SCRIPTFOLDER
if [ $? -ne 0 ]; then exit; fi

LAUNCHPADUBUNTU=$SCRIPTFOLDER/../../launchpad/client
LAUNCHPADUBUNTU=`realpath $LAUNCHPADUBUNTU`
if [ $? -ne 0 ]; then exit; fi
echo Updating the code for creating Ubuntu packages in $LAUNCHPADUBUNTU
rm -rf $LAUNCHPADUBUNTU/*

echo Unpack tarball into the repository.
tar --strip-components=1 -C $LAUNCHPADUBUNTU -xzf ~/Desktop/bibledit*tar.gz
if [ $? -ne 0 ]; then exit; fi

echo Add the debian folder to the repository.
cp -r debian $LAUNCHPADUBUNTU
if [ $? -ne 0 ]; then exit; fi

cd $LAUNCHPADUBUNTU
find . -name .DS_Store -delete
sed -i '' '/maximum_file_size/d' .bzr/branch/branch.conf
echo add.maximum_file_size = 100MB >> .bzr/branch/branch.conf
bzr add .
if [ $? -ne 0 ]; then exit; fi
bzr commit -m "new upstream version"
if [ $? -ne 0 ]; then exit; fi
bzr push
if [ $? -ne 0 ]; then exit; fi


cd $SCRIPTFOLDER
if [ $? -ne 0 ]; then exit; fi

LAUNCHPADUBUNTU=$SCRIPTFOLDER/../../launchpad/client-2017
LAUNCHPADUBUNTU=`realpath $LAUNCHPADUBUNTU`
if [ $? -ne 0 ]; then exit; fi
echo Updating the code for creating Ubuntu packages in $LAUNCHPADUBUNTU
rm -rf $LAUNCHPADUBUNTU/*

echo Unpack tarball into the repository.
tar --strip-components=1 -C $LAUNCHPADUBUNTU -xzf ~/Desktop/bibledit*tar.gz
if [ $? -ne 0 ]; then exit; fi

echo Add the debian folder to the repository.
cp -r debian2017 $LAUNCHPADUBUNTU
if [ $? -ne 0 ]; then exit; fi
rm -rf $LAUNCHPADUBUNTU/debian
if [ $? -ne 0 ]; then exit; fi
mv $LAUNCHPADUBUNTU/debian2017 $LAUNCHPADUBUNTU/debian
if [ $? -ne 0 ]; then exit; fi

cd $LAUNCHPADUBUNTU
find . -name .DS_Store -delete
sed -i '' '/maximum_file_size/d' .bzr/branch/branch.conf
echo add.maximum_file_size = 100MB >> .bzr/branch/branch.conf
bzr add .
if [ $? -ne 0 ]; then exit; fi
bzr commit -m "new upstream version"
if [ $? -ne 0 ]; then exit; fi
bzr push
if [ $? -ne 0 ]; then exit; fi


echo Ready

