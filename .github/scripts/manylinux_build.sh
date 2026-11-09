#!/usr/bin/env bash
#
# Build, package and test CTKAppLauncher in a manylinux_2_28 (AlmaLinux 8) container
# against a static Qt from https://github.com/lassoan/qt-static-build, which is built
# in the same container image.
#
# Usage: manylinux_build.sh <qt-dir> <source-dir> <build-dir>
#

set -euo pipefail

err() { echo -e >&2 "ERROR: $*\n"; }
die() { err "$@"; exit 1; }

if [[ $# -ne 3 ]]; then
  die "Usage: $0 <qt-dir> <source-dir> <build-dir>"
fi

qt_dir="$1"
source_dir="$2"
build_dir="$3"

if [[ ! -d "${qt_dir}/lib/cmake/Qt6" ]]; then
  die "Qt directory does not contain lib/cmake/Qt6: '${qt_dir}'"
fi

# Packages needed to link the static Qt xcb platform plugin and to run the
# tests using Xvfb. See scripts/install-linux-deps.sh in qt-static-build.
#
# EPEL (needed for xcb-util-cursor-devel) mirrors are often unreachable or
# mid-sync, so replace the EPEL repo configuration (preinstalled in the
# manylinux image) with one using the primary server, and retry.
if [[ ! -f /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-8 ]]; then
  dnf install -y --disablerepo='epel*' epel-release
fi
rm -f /etc/yum.repos.d/epel*.repo
cat > /etc/yum.repos.d/epel.repo << 'EOF'
[epel]
name=Extra Packages for Enterprise Linux 8 - $basearch
baseurl=https://dl.fedoraproject.org/pub/epel/8/Everything/$basearch/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-8
EOF

for attempt in 1 2 3; do
  if dnf install -y --setopt=retries=10 \
    fontconfig-devel \
    freetype-devel \
    libX11-devel \
    libXext-devel \
    libXrender-devel \
    libxcb-devel \
    libxkbcommon-devel \
    libxkbcommon-x11-devel \
    xcb-util-cursor-devel \
    xcb-util-devel \
    xcb-util-image-devel \
    xcb-util-keysyms-devel \
    xcb-util-renderutil-devel \
    xcb-util-wm-devel \
    xorg-x11-server-Xvfb \
    xorg-x11-xauth; then
    break
  fi
  if [[ $attempt -eq 3 ]]; then
    die "dnf install failed"
  fi
  echo "dnf install failed (attempt $attempt), retrying"
  dnf clean metadata
  sleep 30
done

command -v ninja > /dev/null || pipx install ninja

cmake \
  -G Ninja \
  -DQt6_DIR:PATH="${qt_dir}/lib/cmake/Qt6" \
  -DCMAKE_BUILD_TYPE:STRING=Release \
  -DBUILD_TESTING:BOOL=ON \
  -S "${source_dir}" \
  -B "${build_dir}"

cmake --build "${build_dir}" --target package

xvfb-run --auto-servernum \
  ctest \
    --test-dir "${build_dir}" \
    --output-on-failure \
    --timeout 60 \
    --parallel "$(nproc)"
