#!/bin/bash

# MAKE SURE YOU HAVE THE ALLCLEAN SCRIPT IN YOUR DIRECTORIES BEFORE RUNNING
# Stop all the cases before running this script.

for i in ./beta_*/
do
    [ -d "$i" ] || continue
    [ -f "$i/Allclean" ] || { echo "Skipping $i: Allclean not found"; continue; }
    chmod +x "$i/Allclean"
    echo "Current Directory: $i"
    (cd "$i" && ./Allclean)
done

echo "DONE"
