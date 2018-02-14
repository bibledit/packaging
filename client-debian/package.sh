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


# Redirect stdout ( > ) into a named pipe ( >() ) running "tee"
exec > >(tee ~/Desktop/debian.txt)
# Same for stderr.
exec 2>&1


source ~/scr/sid-ip
echo The IP address of the Debian machine is $DEBIANSID.


echo Check that the Debian machine is alive.
ping -c 1 $DEBIANSID
if [ $? -ne 0 ]; then exit; fi


DEBIANSOURCE=`dirname $0`
cd $DEBIANSOURCE
DEBIANSOURCE=`pwd`
echo Using Debian packaging source at $DEBIANSOURCE.


echo Create a tarball for the Linux Client.
../../linux/tarball.sh
if [ $? -ne 0 ]; then exit; fi
echo Create a tarball for Debian
./tarball.sh
if [ $? -ne 0 ]; then exit; fi


echo Clean the Debian builder and copy the tarball to it.
ssh $DEBIANSID "rm -rf bibledit*"
if [ $? -ne 0 ]; then exit; fi
scp ~/Desktop/*.gz $DEBIANSID:.
if [ $? -ne 0 ]; then exit; fi


echo Rename the source tarball to the non-native scheme.
ssh $DEBIANSID "rename 's/-/_/g' bibledit*gz"
if [ $? -ne 0 ]; then exit; fi
ssh $DEBIANSID "rename 's/tar/orig.tar/g' bibledit*gz"
if [ $? -ne 0 ]; then exit; fi


echo Sign the source tarball.
rm -f ~/Desktop/bibledit*gz
if [ $? -ne 0 ]; then exit; fi
scp $DEBIANSID:bibledit*gz* ~/Desktop
if [ $? -ne 0 ]; then exit; fi
gpg2 --armor --detach-sign --batch --yes ~/Desktop/bibledit*.gz
if [ $? -ne 0 ]; then exit; fi
scp ~/Desktop/bibledit*.gz.asc $DEBIANSID:.
if [ $? -ne 0 ]; then exit; fi


echo Upload the source tarball
scp $DEBIANSID:bibledit*gz* ~/dev/website/bibledit.org/linux/debian
if [ $? -ne 0 ]; then exit; fi
~/scr/upload
if [ $? -ne 0 ]; then exit; fi


echo Unpack the tarball in Debian.
ssh $DEBIANSID "tar xf bibledit*gz"
if [ $? -ne 0 ]; then exit; fi


echo Do a license check.
ssh -tt $DEBIANSID "cd bibledit*[0-9]; licensecheck --recursive --ignore debian --deb-machine *"
if [ $? -ne 0 ]; then exit; fi


echo Do a source scan.
ssh -tt $DEBIANSID "cd bibledit*[0-9]; uscan"
if [ $? -ne 0 ]; then exit; fi


echo Build the Debian packages.
ssh -tt $DEBIANSID "cd bibledit*[0-9]; debuild -us -uc"
if [ $? -ne 0 ]; then exit; fi


echo Do a pedantic lintian check.
ssh -tt $DEBIANSID "lintian --display-info --pedantic --no-tag-display-limit --info bibledit*changes bibledit*deb bibledit*dsc"
# No checking of exit code because when lintian finds an error,
# even if the error is overriddden, it exits with 1.


echo Build the Debian package in a chroot.
# Builds for upload to unstable.
# ssh -tt $DEBIANSID "cd bibledit*[0-9]; sbuild"
# Builds for upload to experimental.
ssh -tt $DEBIANSID "cd bibledit*[0-9]; sbuild -d experimental -c unstable-amd64-sbuild"
if [ $? -ne 0 ]; then exit; fi


echo Change directory back to $DEBIANSOURCE
cd $DEBIANSOURCE


echo Copying Bibledit repository at alioth from macOS to sid.
rsync --archive -v --delete ../../alioth/bibledit-gtk $DEBIANSID:.
if [ $? -ne 0 ]; then exit; fi


echo Remove untracked files from the working tree.
ssh -tt $DEBIANSID "cd bibledit-gtk; git clean -f"
if [ $? -ne 0 ]; then exit; fi


echo Import upstream tarball and use pristine-tar.
ssh -tt $DEBIANSID "cd bibledit-gtk; gbp import-dsc --create-missing-branches --pristine-tar ../bibledit_*.dsc"
if [ $? -ne 0 ]; then exit; fi


echo Run ./alioth.sh to push the changes to the debian repository at Alioth.
