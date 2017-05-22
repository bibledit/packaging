#!/bin/bash


# Copyright (©) 2003-2017 Teus Benschop.

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


echo Updates the repositories that create Ubuntu packages.


# Bibledit support status:
# Precise 12.04: No support: package libwebkit2gtk-3.0-dev and libwebkit2gtk-4.0-dev not available.


./tarball.sh
TMPLINUX=/tmp/bibledit-linux
echo Works with the tarball supposed to be there in $TMPLINUX.


LAUNCHPADUBUNTU=../launchpad/ubuntu
echo Clean repository at $LAUNCHPADUBUNTU.
rm -rf $LAUNCHPADUBUNTU/*


echo Unpack tarball into the repository.
tar --strip-components=1 -C $LAUNCHPADUBUNTU -xzf $TMPLINUX/bibledit*tar.gz


export LANG="C"
export LC_ALL="C"


echo Change directory to repository.
pushd $LAUNCHPADUBUNTU
echo Update dependencies: Use embedded mbedtls.
sed -i.bak 's/libmbedtls-dev//g' debian/control
rm debian/control.bak
echo Remove clutter.
find . -name .DS_Store -delete
echo Commit to Launchpad.
bzr add .
bzr commit -m "new upstream version"
bzr push
echo Change directory back to origin.
popd


LAUNCHPADTRUSTY=../launchpad/trusty
echo Clean repository at $LAUNCHPADTRUSTY.
rm -rf $LAUNCHPADTRUSTY/*


echo Copy general Ubuntu data to Trusty.
cp -r $LAUNCHPADUBUNTU/* $LAUNCHPADTRUSTY


echo Change directory to repository.
pushd $LAUNCHPADTRUSTY
echo Update dependencies: Trusty has libwebkit2gtk-3.0-dev.
sed -i.bak 's/libwebkit2gtk-4.0-dev/libwebkit2gtk-3.0-dev/g' debian/control
rm debian/control.bak
echo Commit to Launchpad.
bzr add .
bzr commit -m "new upstream version"
bzr push
echo Change directory back to origin.
popd
