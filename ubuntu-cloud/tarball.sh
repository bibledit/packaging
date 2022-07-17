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


DEBIANSOURCE=`dirname $0`
cd $DEBIANSOURCE
DEBIANSOURCE=`pwd`
echo Using Debian packaging source at $DEBIANSOURCE.


# If the debian/README* or README.Debian files contain no useful content,
# they should be updated with something useful, or else be removed.


echo Remove unwanted files from the Debian packaging.
find . -name .DS_Store -delete
echo Remove macOS extended attributes fromm the packaging.
# The attributes would make their way into the tarball,
# get unpacked within Debian,
# and would cause lintian errors.
xattr -r -c *


echo Remove macOS extended attributes fromm the core cloud library.
CLOUDSOURCE="../../cloud"
pushd $CLOUDSOURCE
CLOUDSOURCE=`pwd`
xattr -r -c *
echo Create a tarball of the core cloud library.
rm -f bibledit*gz
make dist
if [ $? -ne 0 ]; then exit; fi
popd


# The script unpacks the Bibledit Linux tarball,
# modifies it, and repacks it into a Debian tarball.
# The reason for doing so is that the Debian builder would otherwise notice
# differences between the supplied tarball and the modified source.
# dpkg-source: error: aborting due to unexpected upstream changes
# Another reason is that in this way it does not need to generate patches in the 'debian' folder.


TMPDEBIAN=/tmp/bibledit-debian
echo Unpack the tarball in working folder $TMPDEBIAN.
rm -rf $TMPDEBIAN
if [ $? -ne 0 ]; then exit; fi
mkdir $TMPDEBIAN
if [ $? -ne 0 ]; then exit; fi
cd $TMPDEBIAN
if [ $? -ne 0 ]; then exit; fi
tar xf $CLOUDSOURCE/bibledit*gz
if [ $? -ne 0 ]; then exit; fi
cd bibledit*
if [ $? -ne 0 ]; then exit; fi


echo Copy the Debian packaging source to $TMPDEBIAN
cp -r $DEBIANSOURCE/debian .


echo Change \"bibledit\" to \"bibledit-cloud\" in configuring code.
sed -i.bak 's/share\/bibledit/share\/bibledit-cloud/g' configure.ac
if [ $? -ne 0 ]; then exit; fi
sed -i.bak 's/\[bibledit\]/\[bibledit-cloud\]/g' configure.ac
if [ $? -ne 0 ]; then exit; fi
rm configure.ac.bak
if [ $? -ne 0 ]; then exit; fi


echo Set the name of the binary to bibledit-cloud.
sed -i.bak 's/.*PROGRAMS.*/bin_PROGRAMS = bibledit-cloud/' Makefile.am
if [ $? -ne 0 ]; then exit; fi
sed -i.bak 's/server_/bibledit_cloud_/g' Makefile.am
if [ $? -ne 0 ]; then exit; fi
sed -i.bak '/unittest_/d' Makefile.am
if [ $? -ne 0 ]; then exit; fi
sed -i.bak '/generate_/d' Makefile.am
if [ $? -ne 0 ]; then exit; fi
rm Makefile.am.bak
if [ $? -ne 0 ]; then exit; fi


echo Remove client man file.
rm man/bibledit.1
if [ $? -ne 0 ]; then exit; fi
sed -i.bak 's/man\/bibledit\.1 //g' Makefile.am
if [ $? -ne 0 ]; then exit; fi
rm Makefile.am.bak
if [ $? -ne 0 ]; then exit; fi


echo Remove some files from the core library
# It does not use the "bibledit" shell script.
# That script writes to the crontab.
# Delete it so it can't be used accidentially.
rm bibledit
if [ $? -ne 0 ]; then exit; fi
rm generate
if [ $? -ne 0 ]; then exit; fi
rm valgrind
if [ $? -ne 0 ]; then exit; fi
rm dev
if [ $? -ne 0 ]; then exit; fi


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


echo Configure and clean the source.
./configure
if [ $? -ne 0 ]; then exit; fi
pkgdata/create.sh
if [ $? -ne 0 ]; then exit; fi
make distclean
if [ $? -ne 0 ]; then exit; fi


echo Create updated renamed tarball for Debian.
cd $TMPDEBIAN
OLDTARDIR=`ls`
NEWTARDIR=${OLDTARDIR/bibledit/bibledit-cloud}
mv $OLDTARDIR $NEWTARDIR
tar czf $NEWTARDIR.tar.gz $NEWTARDIR
if [ $? -ne 0 ]; then exit; fi


echo Copy the Debian tarball to the Desktop.
rm -f ~/Desktop/bibledit-*gz
scp $TMPDEBIAN/*.gz ~/Desktop
if [ $? -ne 0 ]; then exit; fi


echo Ready creating bibledit-cloud tarball for Debian.
