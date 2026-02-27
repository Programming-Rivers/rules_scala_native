#! /bin/env bash

set -Eeuxo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

readarray -t examples < <(find examples -name MODULE.bazel -exec dirname {} + | sort)
echo -e "${BOLD}${BLUE}Found examples:${NC}"
printf "  ${CYAN}* %s${NC}\n" "${examples[@]}"
echo -e "${BLUE}-----------------------------------------------------------------------${NC}"

platforms=(
    "@llvm//platforms:linux_aarch64_gnu.2.42"
    "@llvm//platforms:linux_aarch64_musl"
    "@llvm//platforms:linux_aarch64"
    "@llvm//platforms:linux_x86_64_gnu.2.42"
    "@llvm//platforms:linux_x86_64_musl"
    "@llvm//platforms:linux_x86_64"
    "@llvm//platforms:macos_aarch64"
    "@llvm//platforms:macos_x86_64"
    "@llvm//platforms:none_wasm32"
    "@llvm//platforms:none_wasm64"
    "@llvm//platforms:windows_aarch64"
    "@llvm//platforms:windows_x86_64"
)

for example in "${examples[@]}"; do
  for platform in "${platforms[@]}"; do
    echo -e "${BOLD}${YELLOW}Processing $example on $platform...${NC}"
    cd "$example"
    
    # 1. Build
    echo -e "  ${BOLD}[1/3] Build:${NC} //..."
    bazel --quiet build \
      //... \
      --platform="$platform" \
    && rc=0 || rc=$?
    if [ $rc -ne 0 ]; then
        echo -e "  ${RED}✗ Build failed for $example with exit code $rc${NC}"
        exit $rc
    fi
    echo -e "  ${GREEN}✓ Successfully built${NC}"

    # # 2. Test
    # echo -e "  ${BOLD}[2/3] Test:${NC} //..."
    # if [[ -n $(bazel --quiet cquery 'kind(test, //...)' 2>/dev/null) ]]; then
    #     bazel --quiet test \
    #       --ui_event_filters=-INFO,-PROGRESS --noshow_progress \
    #       //... \
    #      --platform="$platform" \
    #     && rc=0 || rc=$?
    #     if [ $rc -ne 0 ]; then
    #         echo -e "  ${RED}✗ Test failed for $example with exit code $rc${NC}"
    #         exit $rc
    #     fi
    #     echo -e "  ${GREEN}✓ Successfully tested${NC}"
    # else
    #     echo -e "  ${CYAN}i Skipping tests (no test targets found)${NC}"
    # fi

    # # 3. Run
    # echo -e "  ${BOLD}[3/3] Run:${NC} //:main"
    # if [[ -n $(bazel --quiet cquery 'attr(executable, 1, //:main)' 2>/dev/null) ]]; then
    #     bazel --quiet run \
    #       --ui_event_filters=-INFO,-PROGRESS --noshow_progress \
    #       //:main \
    #       --platform="$platform" \
    #     && rc=0 || rc=$?
    #     if [ $rc -ne 0 ]; then
    #         echo -e "  ${RED}✗ Run failed for $example with exit code $rc${NC}"
    #         exit $rc
    #     fi
    #     echo -e "  ${GREEN}✓ Successfully ran${NC}"
    # else
    #     echo -e "  ${CYAN}i Skipping run (no executable //:main target)${NC}"
    # fi

    cd - > /dev/null
    echo -e "${BLUE}-----------------------------------------------------------------------${NC}"
  done
done
