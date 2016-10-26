#!/bin/sh

( echo , ; tail -n+3 build/homework/_design/status.json | head -n-1 ) \
	| xclip -selection c
