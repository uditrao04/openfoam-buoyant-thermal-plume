#!/bin/bash

set -euo pipefail
cd "$(dirname "$0")"

for case_dir in beta_0.1 beta_0.2 beta_0.4 beta_0.6 beta_0.8; do
    if [ -d "$case_dir" ]; then
        echo "Removing $case_dir"
        rm -rf -- "$case_dir"
    fi
done

echo "Retained beta_1.0 and all other repository files."
