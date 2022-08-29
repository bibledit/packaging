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


export LANG="C"
export LC_ALL="C"

LAUNCHPADUBUNTU=~/launchpad/client
LAUNCHPADUBUNTU=`realpath $LAUNCHPADUBUNTU`
if [ $? -ne 0 ]; then exit; fi
echo Updating the code for creating Ubuntu packages in $LAUNCHPADUBUNTU
rm -rf $LAUNCHPADUBUNTU/*


echo Unpack tarball into the repository.
tar --strip-components=1 -C $LAUNCHPADUBUNTU -xzf ~/bibledit-5*tar.gz
if [ $? -ne 0 ]; then exit; fi


echo Add the debian folder to the repository.
cp -r /tmp/debian $LAUNCHPADUBUNTU
if [ $? -ne 0 ]; then exit; fi


echo Commit the code in the repository and push
cd $LAUNCHPADUBUNTU
find . -name .DS_Store -delete
sed -i '/maximum_file_size/d' .bzr/branch/branch.conf
echo add.maximum_file_size = 100MB >> .bzr/branch/branch.conf
bzr add .
if [ $? -ne 0 ]; then exit; fi
bzr commit -m "new upstream version"
if [ $? -ne 0 ]; then exit; fi
bzr push bzr+ssh://teusbenschop@bazaar.launchpad.net/~bibledit/bibledit/client/
if [ $? -ne 0 ]; then exit; fi


echo The script removes itself
cd
if [ $? -ne 0 ]; then exit; fi
rm ubuntu-beta-sid.sh
if [ $? -ne 0 ]; then exit; fi


echo Ready
