CTKAppLauncher
==============

Overview
--------

CTK Application launcher is a lightweight open-source utility allowing to set environment before starting a real application.

The launcher is available on Linux, Windows and macOS.

Read the [wiki](http://www.commontk.org/index.php/Tools:_Application_launcher) for more details.

Build Status
------------

| Linux                          | macOS                         | Windows                       |
|--------------------------------|-------------------------------|-------------------------------|
| [![][circleci]][circleci-lnk]  | [![][gha]][gha-lnk]           | [![][appveyor]][appveyor-lnk] |


[appveyor]: https://ci.appveyor.com/api/projects/status/s6jen6mde8n72o8u/branch/master?svg=true
[appveyor-lnk]: https://ci.appveyor.com/project/commontk/AppLauncher

[circleci]: https://circleci.com/gh/commontk/AppLauncher.svg?style=svg
[circleci-lnk]: https://circleci.com/gh/commontk/AppLauncher

[gha]: https://github.com/commontk/AppLauncher/actions/workflows/CI.yml/badge.svg?branch=master
[gha-lnk]: https://github.com/commontk/AppLauncher/actions/workflows/CI.yml

contributing
------------

Contributions are welcome, and they are greatly appreciated! Every
little bit helps, and credit will always be given.

See [CONTRIBUTING.md][contributing] for more details.

[contributing]: https://github.com/commontk/AppLauncher/blob/master/CONTRIBUTING.md

maintainers: how to make a release ?
------------------------------------

*Follow step below after checking that all tests pass*


1. List all tags sorted by version

    ```bash
    git fetch --tags && \
    git tag -l | sort -V
    ```

2. Choose the next release version number (without

    ```bash
    tag=vX.Y.Z

    version_major=$(echo $tag | tr -d v | cut -d. -f1)
    version_minor=$(echo $tag | tr -d v | cut -d. -f2)
    version_patch=$(echo $tag | tr -d v | cut -d. -f3)
    echo "version_major [$version_major] version_minor[$version_minor] version_patch[$version_patch]"
    ```

3. Update `CMakeLists.txt` setting `CTKAppLauncher_VERSION_IS_RELEASE` and `CTKAppLauncher_*_VERSION` variables

    ```bash
    sed -E "s/set\(CTKAppLauncher_VERSION_IS_RELEASE 0\)/set\(CTKAppLauncher_VERSION_IS_RELEASE 1\)/g" -i CMakeLists.txt && \
    sed -E "s/set\(CTKAppLauncher_MAJOR_VERSION [0-9]+\)/set\(CTKAppLauncher_MAJOR_VERSION $version_major\)/g" -i CMakeLists.txt && \
    sed -E "s/set\(CTKAppLauncher_MINOR_VERSION [0-9]+\)/set\(CTKAppLauncher_MINOR_VERSION $version_minor\)/g" -i CMakeLists.txt && \
    sed -E "s/set\(CTKAppLauncher_BUILD_VERSION [0-9]+\)/set\(CTKAppLauncher_BUILD_VERSION $version_patch\)/g" -i CMakeLists.txt && \
    git add CMakeLists.txt && \
    git commit -m "CTKAppLauncher $tag" && \
    git diff HEAD^
    ```

4. Tag the release. Requires a GPG key with signatures:

    ```bash
    git tag -s -m "CTKAppLauncher $tag" $tag master
    ```

5. Publish the tag and `master` branch to trigger the release build

    ```bash
    git push origin $tag && \
    git push origin master
    ```

_**Important:** Until issue [scikit-build/scikit-ci-addons/issues/96](https://github.com/scikit-build/scikit-ci-addons/issues/96) is addressed, macOS release package should be manually downloaded from the GitHub Actions artifact and uploaded as a GitHub release asset._

6. Update `CMakeLists.txt` setting `CTKAppLauncher_VERSION_IS_RELEASE` to `0`

    ```bash
    sed -E "s/set\(CTKAppLauncher_VERSION_IS_RELEASE 1\)/set\(CTKAppLauncher_VERSION_IS_RELEASE 0\)/g" -i CMakeLists.txt && \
    git add CMakeLists.txt && \
    git commit -m "Begin post-$tag development [ci skip]" && \
    git diff HEAD^
    ```

7. Publish the changes:

    ```bash
    git push origin master
    ```

License
-------

It is covered by the Apache License, Version 2.0:

http://www.apache.org/licenses/LICENSE-2.0

