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


source ~/scr/sid-ip
echo The IP address of the Debian machine is $DEBIANSID.


echo Check that the Debian machine is alive.
ping -c 1 $DEBIANSID
if [ $? -ne 0 ]; then exit; fi


echo Copying Bibledit repository at alioth from macOS to sid.
rsync --archive -v --delete ../../alioth/bibledit-gtk $DEBIANSID:.
if [ $? -ne 0 ]; then exit; fi


echo Remove untracked files from the working tree.
ssh -tt $DEBIANSID "cd bibledit-gtk; git clean -f"
if [ $? -ne 0 ]; then exit; fi


echo Import upstream tarball and use pristine-tar.
# The team now signs the tags.
# ssh -tt $DEBIANSID "cd bibledit-gtk; gbp import-dsc --create-missing-branches --pristine-tar --sign-tags --keyid=85EAFEE5CF2CD500736BD8DE93022BAD0563A51D ../bibledit_*.dsc"
ssh -tt $DEBIANSID "cd bibledit-gtk; gbp import-dsc --create-missing-branches --pristine-tar ../bibledit_*.dsc"
if [ $? -ne 0 ]; then exit; fi


echo Run ./alioth.sh to push the changes to the debian repository at Alioth.
