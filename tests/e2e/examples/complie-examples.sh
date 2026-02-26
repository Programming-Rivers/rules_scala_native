#! /bin/env bash

set -Eeuo pipefail

readarray -t examples < <(find examples -name MODULE.bazel -exec dirname {} + | sort)
echo "Found examples: "
printf "* %s\n" "${examples[@]}"
for example in "${examples[@]}"; do
    echo "Building $example..."
    cd "$example"
    echo "Current dir in: $PWD"
    bazel build \
      --ui_event_filters=-INFO,-PROGRESS --noshow_progress \
      //... \
    && rc=0 || rc=$?
    if [ $rc -ne 0 ]; then
        echo "Build failed for $example with exit code $rc"
        exit $rc
    fi
    echo "successfully built $example"
    # Run bazel test //... if there are any test targets
    if [[ -n $(bazel --quiet cquery 'kind(test, //...)' 2>/dev/null) ]]; then
        bazel test \
          --ui_event_filters=-INFO,-PROGRESS --noshow_progress \
          //... \
        && rc=0 || rc=$?
        if [ $rc -ne 0 ]; then
            echo "Test failed for $example with exit code $rc"
            exit $rc
        fi
        echo "successfully tested $example"
    else
        echo "Skipping tests for $example (no test targets found)"
    fi
    # Run bazel run //:main if it exists and it is executable
    if [[ -n $(bazel --quiet cquery 'attr(executable, 1, //:main)' 2>/dev/null) ]]; then
        bazel run \
          --ui_event_filters=-INFO,-PROGRESS --noshow_progress \
          //:main \
        && rc=0 || rc=$?
        if [ $rc -ne 0 ]; then
            echo "Run failed for $example with exit code $rc"
            exit $rc
        fi
        echo "successfully ran $example"
    else
        echo "Skipping run for $example (no executable //:main target)"
    fi
    cd -
    echo "Current dir out: $PWD"
    echo "-----------------------------------------------------------------------"
    # exit 1
done
