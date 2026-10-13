#!/bin/bash

# Runs Allrun in every case directory.
# Ensure Allrun has executable permission before execution.

set -e

./genAll

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
