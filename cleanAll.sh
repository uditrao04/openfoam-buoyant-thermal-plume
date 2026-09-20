#!/bin/bash

# MAKE SURE YOU HAVE THE ALLCLEAN SCRIPT IN YOUR DIRECTORIES BEFORE RUNNING
# Stop all the cases before running this script.

for i in ./*
do
	[ -d "$i" ] || continue
	echo "Current Directory: $i"
	(cd "$i" && ./Allclean)
done
echo "DONE"
