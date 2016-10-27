#!/usr/bin/env python3

#
# Copyright (c) 2016 Erik Nordstrøm <erikn@ict-infer.no>
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

import os

#
# Target and dependency identification
#

makefile_target_deps = {}
common_deps = 'scripts/design_doc.py'

os.chdir('couchdb')
couchdb_top = os.path.abspath('.')
db_dirs = next(os.walk(couchdb_top))[1]

for db_name in db_dirs:

    db_dir = os.path.abspath(os.path.join(couchdb_top, db_name))
    os.chdir(db_dir)

    os.chdir('_design')
    design_doc_top = os.path.abspath(os.getcwd())
    design_doc_dirs = next(os.walk(design_doc_top))[1]

    for design_doc_name in design_doc_dirs:

        design_doc_dir = os.path.abspath(os.path.join(design_doc_top,
            design_doc_name))
        os.chdir(design_doc_dir)

        tgt = os.path.join('build', db_name,
            '_design', design_doc_name + '.json')

        tgt_deps = []

        for root, dirs, files in os.walk('.'):
            for file in files:
                if file.endswith('.js'):
                    tgt_deps.append(os.path.join('couchdb', db_name,
                        '_design', design_doc_name, root[2:], file))

        makefile_target_deps[tgt] = tgt_deps

#
# Makefile
#

os.chdir(os.path.abspath(os.path.join(couchdb_top, '..')))

with open('Makefile', 'w') as makefile:

    # 'all' target

    makefile.write('all:')

    for tgt in makefile_target_deps:

        makefile.write(' ' + tgt)

    makefile.write('\n\n')

    # deps of each target

    for tgt in makefile_target_deps:

        makefile.write(tgt + ':')

        for dep in makefile_target_deps[tgt]:

            makefile.write(' ' + dep)

        makefile.write(' ' + common_deps)

        makefile.write('\n')

    #
    # Common rule to make target
    #
    # XXX: In BSD make, $(.ALLSRC) is used to list all sources for a
    #      target. GNU make uses $^ instead in order to do this. Since
    #      each of BSD make and GNU make will have the other local variable
    #      undefined, we provide both and as a result we have a portable
    #      Makefile. Pretty, pretty, pretty good, don't you think? :)
    #

    makefile.write('\t./scripts/design_doc.py $(.ALLSRC) $^ $@')
    makefile.write('\n')
