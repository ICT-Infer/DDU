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

import os, sys, subprocess, json

if len(sys.argv) < 3:
    print("Usage: " + sys.argv[0] + " source... target", file=sys.stderr)
    sys.exit(0)

tgt = sys.argv[-1]
deps = sys.argv[1:-1]

design_doc = { '_id': '_design/' + tgt.split('/')[-1].split('.')[0] }

with open('version') as verf:
    design_doc['grev'] = verf.read().splitlines()[0]

for dep in deps:

    untangle = dep.split('/')

    # Skip dependencies not under the couchdb directory. Currently,
    # the only such dependency is the design_doc.py script itself.
    if (untangle[0] != 'couchdb'):
        continue

    # Strip initial path components to get approximately the json hierarchy
    untangle = untangle[4:]

    # Translate key which CouchDB does not match between JSON and URL
    if (untangle[0] == '_view'):
        untangle[0] = 'views'
    elif (untangle[0] == '_list'):
        untangle[0] = 'lists'
    else:
        # TODO: Implement remainder
        raise NotImplementedError

    # XXX: Assuming that filenames have only one dot.
    untangle[-1] = untangle[-1].split('.')[0]

    #
    # Create hierarchy
    #

    curr_loc = design_doc

    for k in untangle[:-1]:

        if not(k in curr_loc):
            curr_loc[k] = {}

        curr_loc = curr_loc[k]

    #
    # Insert value from file
    #

    with open(dep, 'r') as dep_f:
        curr_loc[untangle[-1]] = dep_f.read()

design_doc['language'] = 'javascript'

tgt_parent = os.path.split(tgt)[0]
if not os.path.exists(tgt_parent):
    os.makedirs(tgt_parent)

with open(tgt, 'w') as tgt_f:
    json.dump(design_doc, tgt_f)
