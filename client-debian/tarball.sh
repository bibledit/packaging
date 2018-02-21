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


DEBIANSOURCE=`dirname $0`
cd $DEBIANSOURCE
DEBIANSOURCE=`pwd`
echo Using Debian packaging source at $DEBIANSOURCE.


echo Create a tarball for the Linux Client
../../linux/tarball.sh
if [ $? -ne 0 ]; then exit; fi


TMPDEBIAN=/tmp/bibledit-debian
echo Working folder $TMPDEBIAN
rm -rf $TMPDEBIAN
mkdir $TMPDEBIAN
cd $TMPDEBIAN
if [ $? -ne 0 ]; then exit; fi


# The script unpacks the Bibledit Linux tarball created above,
# modifies it, and repacks it into a Debian tarball.
# The reason for doing so is that the Debian builder would otherwise notice
# differences between the supplied tarball and the modified source.
# dpkg-source: error: aborting due to unexpected upstream changes
# Another reason is that in this way it does not need to generate patches in the 'debian' folder.


echo Unpack the Linux client tarball created just now
tar xf ~/Desktop/bibledit*gz
if [ $? -ne 0 ]; then exit; fi
cd bibledit*
if [ $? -ne 0 ]; then exit; fi


echo Copy the Debian packaging source to $TMPDEBIAN
cp -r $DEBIANSOURCE/debian .


echo Link with the system-provided mbed TLS library.
# It is important to use the system-provided mbedtls library because it is a security library.
# This way, Debian updates to libmbedtls become available to Bibledit too.
# With the embedded library, this is not the case.
# Fix for lintian error "embedded-library usr/bin/bibledit: mbedtls":
# * Remove mbedtls from the list of sources to compile.
# * Add -lmbedtls and friends to the linker flags.
sed -i.bak '/mbedtls\//d' Makefile.am
if [ $? -ne 0 ]; then exit; fi
sed -i.bak 's/# debian//g' Makefile.am
if [ $? -ne 0 ]; then exit; fi
rm *.bak
# Also remove the embedded *.h files to be sure building does not reference them.
# There had been a case that building used the embedded *.h files, leading to segmentation faults.
# For cleanness, remove the whole mbedtls directory, so all traces of it are gone completely.
rm -rf mbedtls


# If the debian/README* or README.Debian files contain no useful content,
# they should be updated with something useful, or else be removed.


echo Disable mach.h definitions.
# On Debian hurd-i386 it has the header mach/mach.h.
# But it does not have the 64 bits statistics definitions.
# It fails to compile there.
# So disable them.
sed -i.bak '/HAVE_MACH_MACH/d' configure.ac
if [ $? -ne 0 ]; then exit; fi
rm configure.ac.bak
if [ $? -ne 0 ]; then exit; fi


echo Reconfiguring the source.
./reconfigure
if [ $? -ne 0 ]; then exit; fi
rm -rf autom4te.cache
if [ $? -ne 0 ]; then exit; fi


echo Remove extra license files.
# Fix for the lintian warnings "extra-license-file".
find . -name COPYING -delete
if [ $? -ne 0 ]; then exit; fi
find . -name LICENSE -delete
if [ $? -ne 0 ]; then exit; fi


echo Remove extra font files.
# Fix for the lintian warning "duplicate-font-file".
rm fonts/SILEOT.ttf
if [ $? -ne 0 ]; then exit; fi


echo Remove unwanted files.
find . -name .DS_Store -delete
echo Remove macOS extended attributes.
# The attributes would make their way into the tarball,
# get unpacked within Debian,
# and would cause build errors there.
xattr -r -c *


echo Configure and clean the source.
./configure
if [ $? -ne 0 ]; then exit; fi
pkgdata/create.sh
if [ $? -ne 0 ]; then exit; fi
make distclean
if [ $? -ne 0 ]; then exit; fi


echo Create updated tarball for Debian.
cd $TMPDEBIAN
TARDIR=`ls`
tar czf $TARDIR.tar.gz $TARDIR
if [ $? -ne 0 ]; then exit; fi


echo Copy the Debian tarball to the Desktop.
rm -f ~/Desktop/bibledit*gz
scp $TMPDEBIAN/*.gz ~/Desktop
if [ $? -ne 0 ]; then exit; fi
