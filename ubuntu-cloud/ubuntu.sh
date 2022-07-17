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


echo Updates the repository that creates Ubuntu beta packages.


./tarball.sh


LAUNCHPADUBUNTU=../../launchpad/ubuntu-cloud
rm -rf $LAUNCHPADUBUNTU/*


tar --strip-components=1 -C $LAUNCHPADUBUNTU -xzf ~/Desktop/bibledit-cloud*tar.gz


export LANG="C"
export LC_ALL="C"


pushd $LAUNCHPADUBUNTU
if [ $? -ne 0 ]; then exit; fi
# Remove clutter.
find . -name .DS_Store -delete
if [ $? -ne 0 ]; then exit; fi
# Ensure that large files get added to the repository.
# For example, sample.sqlite is large, and is needed.
sed -i '' '/maximum_file_size/d' .bzr/branch/branch.conf
echo add.maximum_file_size = 100MB >> .bzr/branch/branch.conf
if [ $? -ne 0 ]; then exit; fi
bzr add .
if [ $? -ne 0 ]; then exit; fi
bzr commit -m "new upstream version"
bzr push
if [ $? -ne 0 ]; then exit; fi
popd


LAUNCHPADUBUNTU=../../launchpad/ubuntu-cloud-old
rm -rf $LAUNCHPADUBUNTU/*


tar --strip-components=1 -C $LAUNCHPADUBUNTU -xzf ~/Desktop/bibledit-cloud*tar.gz
if [ $? -ne 0 ]; then exit; fi


export LANG="C"
export LC_ALL="C"


echo Add the debian folder to the repository.
cp -r debian-old $LAUNCHPADUBUNTU
if [ $? -ne 0 ]; then exit; fi
rm -rf $LAUNCHPADUBUNTU/debian
if [ $? -ne 0 ]; then exit; fi
mv $LAUNCHPADUBUNTU/debian-old $LAUNCHPADUBUNTU/debian
if [ $? -ne 0 ]; then exit; fi


pushd $LAUNCHPADUBUNTU
if [ $? -ne 0 ]; then exit; fi
find . -name .DS_Store -delete
sed -i '' '/maximum_file_size/d' .bzr/branch/branch.conf
echo add.maximum_file_size = 100MB >> .bzr/branch/branch.conf
if [ $? -ne 0 ]; then exit; fi
bzr add .
if [ $? -ne 0 ]; then exit; fi
bzr commit -m "new upstream version"
bzr push
if [ $? -ne 0 ]; then exit; fi
popd

