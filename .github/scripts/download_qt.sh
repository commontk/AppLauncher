#!/usr/bin/env bash
#
# Download a static Qt archive published at https://github.com/lassoan/qt-static-build,
# check its SHA256 checksum and extract it into the current directory.
#
# Usage: download_qt.sh <release-tag> <archive-basename> <archive-sha256>
#

set -euo pipefail

err() { echo -e >&2 "ERROR: $*\n"; }
die() { err "$@"; exit 1; }

if [[ $# -ne 3 ]]; then
  die "Usage: $0 <release-tag> <archive-basename> <archive-sha256>"
fi

release_tag="$1"
archive_basename="$2"
archive_sha256="$3"
archive="${archive_basename}.tar.xz"
release_url="https://github.com/lassoan/qt-static-build/releases/download/${release_tag}"

curl -fsSL --retry 5 -o "${archive}" "${release_url}/${archive}"

echo "${archive_sha256}  ${archive}" > "${archive}.sha256"
if command -v sha256sum > /dev/null; then
  sha256sum -c "${archive}.sha256"
else
  shasum -a 256 -c "${archive}.sha256"
fi

# Extract with CMake, as the tar.exe shipped with Windows lacks xz support
cmake -E tar xf "${archive}"

if [[ ! -d "${archive_basename}" ]]; then
  die "Extracting ${archive} did not create the expected ${archive_basename} directory"
fi
