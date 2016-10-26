#!/bin/sh

( echo , ; tail -n+3 build/homework/_design/status.json ) | xclip -selection c
