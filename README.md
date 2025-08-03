# CTKAppLauncher

[![Actions Status][actions-badge]][actions-link]

CTK AppLauncher is a flexible launcher tool designed to simplify the deployment of Qt-based applications. It enables dynamic configuration of environment variables and runtime paths through an `.ini` settings file, eliminating the need for hardcoded environment setup scripts.

This launcher is especially useful in relocatable deployments where the runtime environment must adapt to the install location of the application.

## overview

The launcher wraps an actual executable (typically suffixed with `-real`) and uses a flexible settings system to:

- set or extend environment variables
- prepend library paths (e.g., `LD_LIBRARY_PATH`, `DYLD_LIBRARY_PATH`, or `PATH`)
- automatically expand values using platform-aware and context-specific placeholders
- support layered configuration via multiple `.ini` files (regular, user, and additional settings)

> [!NOTE]
> Designed to be integrated in C++ CMake-based projects used to build and package Qt-based applications, the launcher settings use a simple `.ini` format and can be adapted to other scenarios.

## contributing

Contributions are welcome, and they are greatly appreciated! Every
little bit helps, and credit will always be given.

See [CONTRIBUTING.md][contributing] for more details.

[contributing]: https://github.com/commontk/AppLauncher/blob/main/CONTRIBUTING.md

## maintainers: how to make a release ?

*Follow step below after checking that all tests pass*

<details>
<summary>click to expand</summary>

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
    git tag -s -m "CTKAppLauncher $tag" $tag main
    ```

5. Publish the tag and `main` branch to trigger the release build

    ```bash
    git push origin $tag && \
    git push origin main
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
    git push origin main
    ```

</details>

## License

It is covered by the Apache License, Version 2.0:

http://www.apache.org/licenses/LICENSE-2.0

<!-- prettier-ignore-start -->
[actions-badge]:            https://github.com/commontk/AppLauncher/actions/workflows/CI.yml/badge.svg?branch=main
[actions-link]:             https://github.com/commontk/AppLauncher/actions/workflows/CI.yml
<!-- prettier-ignore-end -->
