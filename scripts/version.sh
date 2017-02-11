#!/usr/bin/env sh

#
# Copyright (c) 2017 Erik Nordstrøm <erikn@ict-infer.no>
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#

cd `dirname "$0"`
trydir=`basename "$0"`

# Iterate down a (possible) chain of symlinks
while [ -L "$trydir" ]
do
    trydir=`readlink "$trydir"`
    cd `dirname "$trydir"`
    trydir=`basename "$trydir"`
done

cd `pwd -P`

git describe --dirty=+ 2>/dev/null > ../version.curr

if [ -f ../version ] ; then
	cmp ../version ../version.curr >/dev/null
	if [ $? -eq 0 ] ; then
		rm ../version.curr
	elif [ $? -eq 1 ] ; then
		mv ../version.curr ../version
	else
		rm ../version.curr
		exit 1
	fi
else
	mv ../version.curr ../version
fi
