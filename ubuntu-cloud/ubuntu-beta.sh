#!/bin/bash


# Copyright (©) 2003-2020 Teus Benschop.

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


LAUNCHPADUBUNTU=../../launchpad/ubuntu-cloud-beta
rm -rf $LAUNCHPADUBUNTU/*


tar --strip-components=1 -C $LAUNCHPADUBUNTU -xzf ~/Desktop/bibledit-cloud*tar.gz


export LANG="C"
export LC_ALL="C"


cd $LAUNCHPADUBUNTU
find . -name .DS_Store -delete
sed -i '' '/maximum_file_size/d' .bzr/branch/branch.conf
echo add.maximum_file_size = 100MB >> .bzr/branch/branch.conf
bzr add .
bzr commit -m "new upstream version"
bzr push


