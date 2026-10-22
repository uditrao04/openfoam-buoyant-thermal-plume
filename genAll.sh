#!/bin/bash

set -e

# Generate the beta cases from beta_1.0.
#
# beta values:
#   0.1  0.2  0.4  0.6  0.8  1.0
#
# Only halfWidth in system/blockMeshDict is changed.
#
# Usage:
#   ./genAll
#   ./genAll --force

TEMPLATE="beta_1.0"
FORCE=0

# Check for --force
if [ "$1" == "--force" ]; then
    FORCE=1
fi

# Make sure the template exists
if [ ! -d "$TEMPLATE" ]; then
    echo "Error: template case '$TEMPLATE' not found."
    exit 1
fi

if [ ! -f "$TEMPLATE/system/blockMeshDict" ]; then
    echo "Error: blockMeshDict not found in $TEMPLATE."
    exit 1
fi

# Beta values from the reference paper
BETAS=(0.1 0.2 0.4 0.6 0.8 1.0)

echo "Generating beta cases..."
echo

for beta in "${BETAS[@]}"; do

    case_dir="beta_${beta}"

    # halfWidth = 0.05 * beta
    half_width=$(awk -v beta="$beta" 'BEGIN {printf "%.3f", 0.05 * beta}')

    # beta_1.0 is our original template, so don't copy it
    if [ "$case_dir" == "$TEMPLATE" ]; then
        echo "[KEEP]   $case_dir"
        continue
    fi

    # Don't overwrite existing cases unless --force is used
    if [ -d "$case_dir" ]; then
        if [ "$FORCE" -eq 1 ]; then
            echo "[REMOVE] $case_dir"
            rm -rf "$case_dir"
        else
            echo "[SKIP]   $case_dir already exists"
            continue
        fi
    fi

    echo "[CREATE] $case_dir  (halfWidth = ${half_width} m)"

    # Copy the template case
    cp -r "$TEMPLATE" "$case_dir"

    # Change halfWidth in blockMeshDict
    sed -E -i \
        "s/^([[:space:]]*halfWidth[[:space:]]+)[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?([[:space:]]*;)/\1${half_width}\3/" \
        "$case_dir/system/blockMeshDict"

done

echo
echo "Checking cases..."
echo

# Check that the correct halfWidth was written
for beta in "${BETAS[@]}"; do

    case_dir="beta_${beta}"
    file="$case_dir/system/blockMeshDict"

    expected=$(awk -v beta="$beta" 'BEGIN {printf "%.3f", 0.05 * beta}')

    if [ ! -f "$file" ]; then
        echo "[FAIL] $case_dir - blockMeshDict missing"
        continue
    fi

    actual=$(grep -E '^[[:space:]]*halfWidth[[:space:]]+' "$file" |
        head -n 1 |
        sed -E 's/^[[:space:]]*halfWidth[[:space:]]+([^;]+);.*/\1/' |
        tr -d '[:space:]')

    if [ "$actual" == "$expected" ]; then
        echo "[ OK ] $case_dir  -> halfWidth = ${actual} m"
    else
        echo "[FAIL] $case_dir  -> expected ${expected} m, got ${actual}"
    fi

done

echo
echo "Done."