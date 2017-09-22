CTKAppLauncher
==============

Overview
--------

CTK Application launcher is a lightweight open-source utility allowing to set environment before starting a real application.

The launcher is available on Linux, Windows and MacOSX.

Read the [wiki](http://www.commontk.org/index.php/Tools:_Application_launcher) for more details.

Build Status
------------

| Linux                          | MacOSX                        | Windows                       |
|--------------------------------|-------------------------------|-------------------------------|
| [![][circleci]][circleci-lnk]  | [![][travisci]][travisci-lnk] | [![][appveyor]][appveyor-lnk] |


[appveyor]: https://ci.appveyor.com/api/projects/status/s6jen6mde8n72o8u/branch/master?svg=true
[appveyor-lnk]: https://ci.appveyor.com/project/commontk/AppLauncher

[circleci]: https://circleci.com/gh/commontk/AppLauncher.svg?style=svg
[circleci-lnk]: https://circleci.com/gh/commontk/AppLauncher

[travisci]: https://travis-ci.org/commontk/AppLauncher.svg?branch=master
[travisci-lnk]: https://travis-ci.org/commontk/AppLauncher

contributing
------------

Contributions are welcome, and they are greatly appreciated! Every
little bit helps, and credit will always be given.

See [CONTRIBUTING.md][contributing] for more details.

[contributing]: https://github.com/commontk/AppLauncher/blob/master/CONTRIBUTING.md

maintainers: how to make a release ?
------------------------------------

*Follow step below after checking that all tests pass*

1. Update [CMakeLists.txt][cmakelists]

  * set `CTKAppLauncher_VERSION_IS_RELEASE` to `1`
  * update `CTKAppLauncher_*_VERSION` variables

2. Commit changes with message:

    ```
    CTKAppLauncher X.Y.Z
    ```

3. Tag the release. Requires a GPG key with signatures. For version *X.Y.Z*:

    ```bash
    git tag -s -m "CTKAppLauncher X.Y.Z" vX.Y.Z master
    ```

4. Publish the tag

    ```bash
    git push origin vX.Y.Z
    ```

5. Then publish the `master` branch to trigger the release build

    ```bash
    git push origin master
    ```

6. Update [CMakeLists.txt][cmakelists] setting `CTKAppLauncher_VERSION_IS_RELEASE` to `0`

7. Commit changes with message:

    ```
    Begin post-X.Y.Z development

    [ci skip]
    ```

8. Publish the `master` branch


[cmakelists]: https://github.com/commontk/AppLauncher/blob/29fb4b4db29356ea33b9be8f2a392f5683184bb8/CMakeLists.txt#L51-L54

License
-------

It is covered by the Apache License, Version 2.0:

http://www.apache.org/licenses/LICENSE-2.0

