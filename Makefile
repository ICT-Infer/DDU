all: build/_design/status.json

build/_design/status.json: couchdb/homework/_design/status/_list/tbodies.js couchdb/homework/_design/status/_view/pending_delivery.js couchdb/homework/_design/status/_view/pending_review.js couchdb/homework/_design/status/_view/approved.js
	mkdir -p build/_design/
	( \
	  echo \
	    '{' \
	    '  "_id": "_design/status",' \
	    '  "views": {' \
	    '    "approved": {' \
	    '      "map":' "$$( ./scripts/esc.sh couchdb/homework/_design/status/_view/approved.js )" \
	    '    },' \
	    '    "pending_delivery": {' \
	    '      "map":' "$$( ./scripts/esc.sh couchdb/homework/_design/status/_view/pending_delivery.js )" \
	    '    },' \
	    '    "pending_review": {' \
	    '      "map":' "$$( ./scripts/esc.sh couchdb/homework/_design/status/_view/pending_review.js )" \
	    '    }' \
	    '  },' \
	    '  "lists": {' \
	    '    "tbodies":' "$$( ./scripts/esc.sh couchdb/homework/_design/status/_list/tbodies.js )" \
	    '  },' \
	    '  "language": "javascript"' \
	    '}' \
	) | jq '.' > $@
