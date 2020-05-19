#!/bin/bash
if [ `/usr/lib/update-notifier/apt-check 2>&1` != '0;0' ]
then
	echo " | " Update: `/usr/lib/update-notifier/apt-check 2>&1` " | "
fi
