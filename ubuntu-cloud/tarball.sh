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


set -e


DEBIAN_SOURCE=$(dirname "$0")
cd "$DEBIAN_SOURCE"
DEBIAN_SOURCE=$(pwd)
echo Using Debian packaging source at "$DEBIAN_SOURCE".


rm -f ~/Desktop/bibledit-cloud*tar.gz


echo Remove unwanted files from the Debian packaging.
find . -name .DS_Store -delete
echo Remove macOS extended attributes fromm the packaging.
# The attributes would make their way into the tarball,
# get unpacked within Debian,
# and would cause lintian errors.
xattr -r -c ./*


echo Remove macOS extended attributes fromm the core cloud library.
CLOUD_SOURCE="../../cloud"
pushd $CLOUD_SOURCE
CLOUD_SOURCE=$(pwd)
xattr -r -c ./*
echo Create a tarball of the core cloud library.
rm -f build/bibledit*gz
cmake --build build --target dist
popd


# The script unpacks the Bibledit Linux tarball,
# modifies it, and repacks it into a Debian tarball.
# The reason for doing so is that the Debian builder would otherwise notice
# differences between the supplied tarball and the modified source.
# dpkg-source: error: aborting due to unexpected upstream changes
# Another reason is that in this way it does not need to generate patches in the 'debian' folder.


TMP_DEBIAN=/tmp/bibledit-debian
echo Unpack the tarball in working folder $TMP_DEBIAN.
rm -rf $TMP_DEBIAN
mkdir $TMP_DEBIAN
cd $TMP_DEBIAN
tar xf "$CLOUD_SOURCE"/build/bibledit*gz
cd bibledit*


echo Copy the Debian packaging source to $TMP_DEBIAN
cp -r "$DEBIAN_SOURCE"/debian .


echo Change the executable name from "server" to "bibledit-cloud".
sed -i.bak 's/"server"/"bibledit-cloud"/g' CMakeLists.txt
rm CMakeLists.txt.bak


echo Change shared data from bibledit to bibledit-cloud.
sed -i.bak 's/share\/bibledit/share\/bibledit-cloud/g' CMakeLists.txt
rm CMakeLists.txt.bak


echo Remove client man file.
rm man/bibledit.1
sed -i.bak '/bibledit.1/d' CMakeLists.txt
rm CMakeLists.txt.bak


echo Remove some files from the core library
# It does not use the "bibledit" shell script.
# That script writes to the crontab.
# Delete it so it can't be used accidentially.
rm bibledit
rm -f generate
rm valgrind
rm dev


echo Disable mach.h definitions.
# On Debian hurd-i386 it has the header mach/mach.h.
# But it does not have the 64 bits statistics definitions.
# It fails to compile there.
# So disable them.
sed -i.bak '/HAVE_MACH_MACH/d' CMakeLists.txt
rm CMakeLists.txt.bak


echo Remove extra license files.
# Fix for the lintian warnings "extra-license-file".
find . -name COPYING -delete
find . -name LICENSE -delete


echo Remove extra font files.
# Fix for the lintian warning "duplicate-font-file".
rm fonts/SILEOT.ttf


echo Clean the source.
pkgdata/create.sh


echo Create updated renamed tarball for Debian.
cd $TMP_DEBIAN
OLD_TAR_DIR=$(ls)
NEW_TAR_DIR=${OLD_TAR_DIR/bibledit/bibledit-cloud}
mv "$OLD_TAR_DIR" "$NEW_TAR_DIR"
tar czf "$NEW_TAR_DIR".tar.gz "$NEW_TAR_DIR"


echo Copy the Debian tarball to the Desktop.
scp $TMP_DEBIAN/*.gz ~/Desktop


echo Ready creating bibledit-cloud tarball for Debian.
