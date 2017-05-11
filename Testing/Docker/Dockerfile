FROM thewtex/opengl:latest
MAINTAINER CommonTK Community <ctk-developers@commontk.org>
# Test the CTK App Launcher
# Graphic rendering support is required, so we use a base image that support
# rendering.

ENV APP "sudo chown -R user.user /usr/src/AppLauncher-build && cd /usr/src/AppLauncher-build && ctest -LE 'CompilerRequired' -V"
