#!/usr/bin/env bash

set -euo pipefail

gosu root dnf install -y \
  xorg-x11-server-Xvfb \
  xorg-x11-server-Xorg \
  mesa-dri-drivers \
  glx-utils

function cleanup() {
  echo "Cleaning up..."
  local xvfb_pids=`ps aux | grep tmp/xvfb-run | grep -v grep | awk '{print $2}'`
  if [ "$xvfb_pids" != "" ]; then
      echo "Killing the following xvfb processes: $xvfb_pids"
      sudo kill $xvfb_pids
  else
      echo "No xvfb processes to kill"
  fi
}
trap cleanup EXIT

xvfb-run --auto-servernum $@
