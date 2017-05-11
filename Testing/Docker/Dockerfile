FROM thewtex/opengl:latest
MAINTAINER CommonTK Community <ctk-developers@commontk.org>
# Test the CTK App Launcher
# Graphic rendering support is required, so we use a base image that support
# rendering.

ENV APP "sudo chown -R user.user /usr/src/AppLauncher-build && cd /usr/src/AppLauncher-build && ctest -E 'AppWithLibLauncher|App4Test|InstallTree_AppLauncher-Install|App4ConfigureLauncherTest|ConfiguredAppLauncher' -V"
