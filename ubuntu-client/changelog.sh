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
pushd ../../cloud
cmake -B build
popd
VERSION=$(grep -w VERSION ../../cloud/config.h | sed 's/#define VERSION //' | sed 's/"//g')
echo Updating the debian/changelog to "$VERSION"
{
  echo "bibledit ($VERSION-1) unstable; urgency=medium";
  echo;
  echo "  * new upstream version";
  echo;
  echo -n " -- Teus Benschop <teusjannette@gmail.com>  ";
  date -R;
  echo;
} > changelog
cat debian/changelog >> changelog
cp changelog debian/changelog
#cp changelog debian2017/changelog
rm changelog
