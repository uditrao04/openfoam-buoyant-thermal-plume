#!/bin/bash

# MAKE SURE YOU HAVE THE ALLRUN SCRIPT IN YOUR DIRECTORIES BEFORE RUNNING
# Once you start the script, make sure you either complete the currently ongoing case before stopping the script or remove the case from the directory completely to avoid double runnning of the cases.

for i in ./*
do
	[ -d "$i" ] || continue
	echo "Current Directory: $i"
	(cd "$i" && ./Allrun)
done
echo "DONE"
