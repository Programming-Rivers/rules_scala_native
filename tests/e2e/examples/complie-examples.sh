#! /bin/env bash

set -Eeuo pipefail

readarray -t examples < <(find examples -name MODULE.bazel -exec dirname {} + | sort)
echo "Found examples: "
printf "* %s\n" "${examples[@]}"
for example in "${examples[@]}"; do
    echo "Bulding $example..."
    cd "$example"
    echo "Cunnernt dir in: $PWD"
    bazel build \
      //...
      --output_filter=warnings \
      --noshow_progress
    rc=$?
    cd -
    echo "Cunnernt dir out: $PWD"
    if [ $rc -ne 0 ]; then
        echo "Build failed for $example with exit code $rc"
        exit $rc
    fi
    echo "successfully built $example"
    echo "-----------------------------------------------------------------------"
    # exit 1
done
