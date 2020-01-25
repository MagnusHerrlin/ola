#!/bin/sh

# A simple script to build a C++ header file containing the plugin description
# from the plugin's README.md
# The output file then contains one variable 'plugin_description'.

if [ $# != 2 ]; then
  echo "Usage: convert_README_to_header.sh <plugin path> <outfile path>";
  echo "<plugin path>: path to plugin dir, e.g. plugins/artnet";
  echo "<outfile path>: e.g. plugins/artnet/ArtnetPluginDescription.h";
  exit 1;
fi

path="$1";
outfile="$2";

if [ ! -d $path ]; then
  echo "directory '$path' does not exist";
  exit 1;
fi

if [ ! -e "$path/README.md" ]; then
  echo "README.md file in '$path' does not exist";
  exit 1;
fi

plugin=`basename "$path"`;
outfilename=`basename $outfile`;

#s/\"/\\\"/g - replace " with \" throughout
#1!s/^/\"/g - Apart from the first line, add a " to the start of each line
#$!s/$/\\\\n"/g - Apart from the last line, add a \\n (i.e. an escaped newline)
#and a " to the end of each line
desc=`sed -e 's/\"/\\\"/g' -e '1!s/^/\"/' -e '$!s/$/\\\\n"/' "$path/README.md"`;

identifier=`echo "PLUGINS_${plugin}_${outfilename%.h}_H_" | tr '[:lower:]' '[:upper:]'`

cat <<EOM > $outfile
/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Library General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 *
 * $outfilename
 * Contains the description for the $plugin plugin.
 * Copyright (C) 2016 Florian Edelmann
 *
 * This file has been autogenerated by convert_README_to_header.sh, DO NOT EDIT.
 */
#ifndef $identifier
#define $identifier

namespace ola {
namespace plugin {
namespace $plugin {

const char plugin_description[] = "$desc";

}  // namespace $plugin
}  // namespace plugin
}  // namespace ola

#endif  // $identifier
EOM
