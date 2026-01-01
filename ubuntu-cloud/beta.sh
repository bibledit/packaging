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


echo Create a tarball for Bibledit Cloud
./tarball.sh


echo Updating the git repository that contains sources for Ubuntu beta packages


LAUNCHPADUBUNTU=$HOME/dev/launchpad/ubuntu-cloud-beta
echo Local repository at $LAUNCHPADUBUNTU
rm -rf $LAUNCHPADUBUNTU/*


echo Unpack the tarball from the Desktop
tar --strip-components=1 -C $LAUNCHPADUBUNTU -xzf ~/Desktop/bibledit-cloud*tar.gz


pushd $LAUNCHPADUBUNTU
find . -name .DS_Store -delete
find . -name HasenundFrîsche.txt -delete
echo Push data to Launchpad
git add .
git commit -a -m "new upstream version"
git push
popd


echo Ready
