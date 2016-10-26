all: build/_design/status.json

build/_design/status.json: couchdb/homework/_design/status/_list/complex.js couchdb/homework/_design/status/_view/pending_delivery/map.js couchdb/homework/_design/status/_view/pending_review/map.js couchdb/homework/_design/status/_view/approved/map.js couchdb/homework/_design/status/_view/all/map.js couchdb/homework/_design/status/_view/overdue/map.js couchdb/homework/_design/status/_view/rejected/map.js scripts/esc.sh
	mkdir -p build/_design/
	( \
	  echo \
	    '{' \
	    '  "_id": "_design/status",' \
	    '  "views": {' \
	    '    "all": {' \
	    '      "map":' "$$( ./scripts/esc.sh couchdb/homework/_design/status/_view/all/map.js )" \
	    '    },' \
	    '    "approved": {' \
	    '      "map":' "$$( ./scripts/esc.sh couchdb/homework/_design/status/_view/approved/map.js )" \
	    '    },' \
	    '    "pending_delivery": {' \
	    '      "map":' "$$( ./scripts/esc.sh couchdb/homework/_design/status/_view/pending_delivery/map.js )" \
	    '    },' \
	    '    "pending_review": {' \
	    '      "map":' "$$( ./scripts/esc.sh couchdb/homework/_design/status/_view/pending_review/map.js )" \
	    '    },' \
	    '    "overdue": {' \
	    '      "map":' "$$( ./scripts/esc.sh couchdb/homework/_design/status/_view/overdue/map.js )" \
	    '    },' \
	    '    "rejected": {' \
	    '      "map":' "$$( ./scripts/esc.sh couchdb/homework/_design/status/_view/rejected/map.js )" \
	    '    }' \
	    '  },' \
	    '  "lists": {' \
	    '    "complex":' "$$( ./scripts/esc.sh couchdb/homework/_design/status/_list/complex.js )" \
	    '  },' \
	    '  "language": "javascript"' \
	    '}' \
	) | jq '.' > $@
