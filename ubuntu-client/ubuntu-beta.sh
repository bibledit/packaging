#!/bin/bash


# Copyright (©) 2003-2018 Teus Benschop.

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


cd /tmp
git clone https://github.com/bibledit/debianclient.git
cd debianclient
if [ $? -ne 0 ]; then exit; fi
git pull
if [ $? -ne 0 ]; then exit; fi
DEBIANCLIENT=`pwd`
echo Using Bibledit Debian source at $DEBIANCLIENT


export LANG="C"
export LC_ALL="C"


LAUNCHPADUBUNTU=$SCRIPTFOLDER/../../launchpad/client-beta
LAUNCHPADUBUNTU=`realpath $LAUNCHPADUBUNTU`
echo Updating the code for creating Ubuntu beta packages in $LAUNCHPADUBUNTU
rm -rf $LAUNCHPADUBUNTU/*
cp -r $DEBIANCLIENT/* $LAUNCHPADUBUNTU


cd $LAUNCHPADUBUNTU
find . -name .DS_Store -delete
sed -i '' '/maximum_file_size/d' .bzr/branch/branch.conf
echo add.maximum_file_size = 100MB >> .bzr/branch/branch.conf
bzr add .
bzr commit -m "new upstream version"
bzr push
