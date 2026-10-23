#!/bin/bash

# Runs "genAll.sh" followed by "Allrun" in every case directory.
# Ensure all scripts have executable permission before execution.
# You can give permission to all scripts in the current directory and subdirectories using:
# chmod +x <file name>

set -e

chmod +x *      # * means "all files in the current directory"
./genAll.sh

for i in ./beta_*/
do
    [ -d "$i" ] || continue
    [ -f "$i/Allrun" ] || { echo "ERROR: $i/Allrun not found"; exit 1; }
    chmod +x "$i/Allrun"
done

for i in ./beta_*/
do
    [ -d "$i" ] || continue
    echo "Current Directory: $i"
    (cd "$i" && ./Allrun)
done

echo "DONE"
