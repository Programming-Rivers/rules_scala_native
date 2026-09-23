#!/usr/bin/env bash
# publish_to_bcr.sh - Creates BCR entry files for a new rules_scala_native release.
#
# Usage:
#   utils/publish_to_bcr.sh <TAG> [BCR_DIR]
#
# Arguments:
#   TAG      - Git tag to publish (e.g. v0.1.1-rc4, v0.1.2)
#   BCR_DIR  - Path to local clone of the BCR fork.
#
# Example:
#   utils/publish_to_bcr.sh v0.1.2
#   utils/publish_to_bcr.sh v0.1.2 /path/to/my/bazel-central-registry
#
# Prerequisites:
#   - curl, sha256sum, xxd, base64, tar, patch, python3

set -euo pipefail

# ── Configuration ─────────────────────────────────────────────────────────────

REPO_NAME="rules_scala_native"
GITHUB_ORG="Programming-Rivers"
GITHUB_REPO="${GITHUB_ORG}/${REPO_NAME}"

# The version string kept in the source repo's MODULE.bazel (never changed there)
SOURCE_VERSION="0.0.0"

# BCR fork remote name and branch (used in the push hint printed at the end)
BCR_FORK_REMOTE="programming-rivers-github"
BCR_FORK_BRANCH="rules_scala_native"

# ── Arguments ─────────────────────────────────────────────────────────────────

TAG="${1:?ERROR: TAG argument is required. Usage: $0 <tag> <bcr_dir>}"
BCR_DIR="${2:?ERROR: BCR_DIR argument is required and should point to a clone of the Bazel Central Registry repo.}"

# Strip leading 'v' prefix to get the module version string
VERSION="${TAG#v}"

# ── Derived Paths ─────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
MODULE_DIR="${BCR_DIR}/modules/${REPO_NAME}"
VERSION_DIR="${MODULE_DIR}/${VERSION}"
PATCHES_DIR="${VERSION_DIR}/patches"
METADATA_FILE="${MODULE_DIR}/metadata.json"

# ── Validation ────────────────────────────────────────────────────────────────

echo "┌─────────────────────────────────────────────────────────────┐"
echo "│  Publishing ${REPO_NAME}@${VERSION}"
echo "└─────────────────────────────────────────────────────────────┘"
echo

if [ ! -d "${BCR_DIR}" ]; then
  echo "ERROR: BCR directory not found: ${BCR_DIR}" >&2
  echo "       Clone the fork first:" >&2
  echo "       git clone git@github.com:${GITHUB_ORG}/bazel-central-registry.git ${BCR_DIR}" >&2
  exit 1
fi

if [ ! -f "${METADATA_FILE}" ]; then
  echo "ERROR: metadata.json not found at: ${METADATA_FILE}" >&2
  echo "       Is ${BCR_DIR} a valid Bazel Central Registry clone?" >&2
  exit 1
fi

if [ -d "${VERSION_DIR}" ]; then
  echo "ERROR: Version directory already exists: ${VERSION_DIR}" >&2
  echo "       Remove it first if you want to regenerate:" >&2
  echo "       rm -rf ${VERSION_DIR}" >&2
  exit 1
fi

# ── Download Source Archive ───────────────────────────────────────────────────

ARCHIVE_URL="https://github.com/${GITHUB_REPO}/archive/refs/tags/${TAG}.tar.gz"
TMP_ARCHIVE=$(mktemp "/tmp/${REPO_NAME}-${VERSION}-XXXXXX.tar.gz")
TMP_VERIFY_DIR=$(mktemp -d "/tmp/${REPO_NAME}-verify-XXXXXX")
trap 'rm -f "${TMP_ARCHIVE}"; rm -rf "${TMP_VERIFY_DIR}"' EXIT

echo "──  Downloading source archive"
echo "    URL: ${ARCHIVE_URL}"
if ! curl -fsSL --progress-bar "${ARCHIVE_URL}" -o "${TMP_ARCHIVE}"; then
  echo "ERROR: Failed to download archive." >&2
  echo "       Does tag '${TAG}' exist on GitHub at https://github.com/${GITHUB_REPO}/tags?" >&2
  exit 1
fi

# ── Compute Archive Integrity (SRI format: sha256-<base64>) ──────────────────

ARCHIVE_SHA256=$(sha256sum "${TMP_ARCHIVE}" | awk '{print $1}')
ARCHIVE_INTEGRITY="sha256-$(printf '%s' "${ARCHIVE_SHA256}" | xxd -r -p | base64 | tr -d '\n')"

STRIP_PREFIX=$(tar -tzf "${TMP_ARCHIVE}" | head -1 | tr -d '/')
echo "    Strip prefix:  ${STRIP_PREFIX}"
echo "    Integrity:     ${ARCHIVE_INTEGRITY}"
echo

# ── Create Directory Structure ────────────────────────────────────────────────

mkdir -p "${PATCHES_DIR}"

# ── Create MODULE.bazel.patch ─────────────────────────────────────────────────

echo "──  Creating MODULE.bazel.patch"
PATCH_FILE="${PATCHES_DIR}/MODULE.bazel.patch"

# NOTE: The hunk context lines must match exactly what is in the source MODULE.bazel.
# If the file changes significantly, update the context lines below.
cat > "${PATCH_FILE}" << PATCHEOF
diff --git b/MODULE.bazel a/MODULE.bazel
index 8f0e202..0000001 100644
--- b/MODULE.bazel
+++ a/MODULE.bazel
@@ -7,7 +7,7 @@
 
 module(
     name = "${REPO_NAME}",
-    version = "${SOURCE_VERSION}",
+    version = "${VERSION}",
     bazel_compatibility = [">=9.0.0"],
     compatibility_level = 0,
 )
PATCHEOF

PATCH_SHA256=$(sha256sum "${PATCH_FILE}" | awk '{print $1}')
PATCH_INTEGRITY="sha256-$(printf '%s' "${PATCH_SHA256}" | xxd -r -p | base64 | tr -d '\n')"
echo "    Patch integrity: ${PATCH_INTEGRITY}"

# ── Verify Patch Applies Cleanly ──────────────────────────────────────────────

echo
echo "──  Verifying patch applies cleanly to source archive"
tar -xzf "${TMP_ARCHIVE}" -C "${TMP_VERIFY_DIR}" --strip-components=1

if ! patch -p1 -d "${TMP_VERIFY_DIR}" < "${PATCH_FILE}" --silent; then
  echo "ERROR: Patch failed to apply cleanly." >&2
  echo "       The source MODULE.bazel may have changed structure." >&2
  echo "       Update the patch hunk context in this script." >&2
  exit 1
fi

PATCHED_VERSION=$(grep -E '^\s+version\s*=' "${TMP_VERIFY_DIR}/MODULE.bazel" \
  | head -1 | grep -o '"[^"]*"' | tr -d '"')

if [ "${PATCHED_VERSION}" != "${VERSION}" ]; then
  echo "ERROR: Patch verification failed." >&2
  echo "       Got version '${PATCHED_VERSION}', expected '${VERSION}'" >&2
  exit 1
fi
echo "    ✓ Patch verified — MODULE.bazel version = ${PATCHED_VERSION}"

# ── Create MODULE.bazel (patched version for BCR) ────────────────────────────

cp "${TMP_VERIFY_DIR}/MODULE.bazel" "${VERSION_DIR}/MODULE.bazel"
echo
echo "──  Created MODULE.bazel (version = ${VERSION})"

# ── Create source.json ────────────────────────────────────────────────────────

cat > "${VERSION_DIR}/source.json" << EOF
{
    "url": "${ARCHIVE_URL}",
    "integrity": "${ARCHIVE_INTEGRITY}",
    "strip_prefix": "${STRIP_PREFIX}",
    "patches": {
        "MODULE.bazel.patch": "${PATCH_INTEGRITY}"
    },
    "patch_strip": 1
}
EOF
echo "──  Created source.json"

# ── Create presubmit.yml ──────────────────────────────────────────────────────
# Prefer the most recent BCR entry's presubmit.yml (maintained separately from
# the source repo's .bcr/presubmit.yml template), fall back to the source template.

LAST_VERSION=$(python3 - "${METADATA_FILE}" << 'PYEOF'
import json, sys
with open(sys.argv[1]) as f:
    d = json.load(f)
versions = [v for v in d.get("versions", []) if v]
print(versions[-1] if versions else "")
PYEOF
)

PRESUBMIT_SOURCE=""
if [ -n "${LAST_VERSION}" ] && [ -f "${MODULE_DIR}/${LAST_VERSION}/presubmit.yml" ]; then
  PRESUBMIT_SOURCE="${MODULE_DIR}/${LAST_VERSION}/presubmit.yml"
elif [ -f "${SOURCE_REPO_ROOT}/.bcr/presubmit.yml" ]; then
  PRESUBMIT_SOURCE="${SOURCE_REPO_ROOT}/.bcr/presubmit.yml"
fi

if [ -n "${PRESUBMIT_SOURCE}" ]; then
  cp "${PRESUBMIT_SOURCE}" "${VERSION_DIR}/presubmit.yml"
  echo "──  Created presubmit.yml (from ${PRESUBMIT_SOURCE})"
else
  echo "WARNING: No presubmit.yml source found. Creating minimal fallback." >&2
  cat > "${VERSION_DIR}/presubmit.yml" << 'EOF'
bcr_test_module:
  module_path: "examples/01-basics/03-testing"
  matrix:
    platform:
      - ubuntu2404
    bazel:
      - 9.x
  tasks:
    run_tests:
      name: "Build and test example 01-basics/03-testing"
      platform: ${{ platform }}
      bazel: ${{ bazel }}
      build_targets:
        - "//..."
      test_targets:
        - "//..."
EOF
fi

# ── Update metadata.json ──────────────────────────────────────────────────────

python3 - "${METADATA_FILE}" "${VERSION}" << 'PYEOF'
import json, sys

metadata_path, new_version = sys.argv[1], sys.argv[2]
with open(metadata_path) as f:
    metadata = json.load(f)

if new_version in metadata["versions"]:
    print(f"    Version {new_version} already present in metadata.json — skipping")
else:
    metadata["versions"].append(new_version)
    with open(metadata_path, "w") as f:
        json.dump(metadata, f, indent=4)
        f.write("\n")
    print(f"    Added {new_version} to versions list: {metadata['versions']}")
PYEOF
echo "──  Updated metadata.json"

# ── Summary ───────────────────────────────────────────────────────────────────

echo
echo "┌─────────────────────────────────────────────────────────────┐"
echo "│  ✓  All files generated successfully                        │"
echo "└─────────────────────────────────────────────────────────────┘"
echo
echo "Files created:"
find "${VERSION_DIR}" -type f | sort | sed 's|^|    |'
echo
echo "Next steps:"
echo
echo "  1. Review the generated files:"
echo "       cat ${VERSION_DIR}/source.json"
echo "       cat ${VERSION_DIR}/MODULE.bazel"
echo "       cat ${VERSION_DIR}/presubmit.yml"
echo
echo "  2. Commit and push to the BCR fork:"
echo "       cd ${BCR_DIR}"
echo "       git add modules/${REPO_NAME}/${VERSION}/ modules/${REPO_NAME}/metadata.json"
echo "       git commit -m '${REPO_NAME}@${VERSION}'"
echo "       git push ${BCR_FORK_REMOTE} ${BCR_FORK_BRANCH} --force-with-lease"
echo
echo "  3. Open the Pull Request:"
echo "       https://github.com/bazelbuild/bazel-central-registry/compare/main...${GITHUB_ORG}:bazel-central-registry:${BCR_FORK_BRANCH}"
echo
