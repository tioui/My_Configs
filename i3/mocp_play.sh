#!/usr/bin/env bash
if [ "a$1" = "astop" ]
then
	if [ `mocp --info | grep -c 'State: STOP'`a == 1a ]; then mocp --play; else mocp --stop; fi
else
	if [ `mocp --info | grep -c 'State: STOP'`a == 1a ]; then mocp --play; else mocp --toggle-pause; fi
fi
