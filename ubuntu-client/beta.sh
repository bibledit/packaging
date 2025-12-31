#!/bin/bash

# Copyright (©) 2003-2026 Teus Benschop.

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


echo Exit script on error
set -e


echo Create a tarball for the Linux Client
rm -f ~/Desktop/bibledit-5*.tar.gz
../../linux/tarball-macos.sh


LAUNCHPADUBUNTU=~/dev/launchpad/ubuntu-client-beta
LAUNCHPADUBUNTU=`realpath $LAUNCHPADUBUNTU`
echo Updating the code for creating Ubuntu beta packages in $LAUNCHPADUBUNTU
rm -rf $LAUNCHPADUBUNTU/*


echo Unpack tarball into the repository
tar --strip-components=1 -C $LAUNCHPADUBUNTU -xzf ~/Desktop/bibledit-5*tar.gz


echo Add the debian folder to the repository
cp -r debian $LAUNCHPADUBUNTU


echo Commit the code in the repository and push
pushd $LAUNCHPADUBUNTU
find . -name .DS_Store -delete
git add .
git commit -a -m "new upstream version"
git push
popd


echo Ready
