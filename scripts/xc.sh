#!/bin/sh

( echo , ; jq -S '.' build/homework/_design/status.json | tail -n+3 ) \
	| xclip -selection c
