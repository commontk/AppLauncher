# CTKAppLauncher

[![Actions Status][actions-badge]][actions-link]

CTK AppLauncher is a flexible launcher tool designed to simplify the deployment of Qt-based applications. It enables dynamic configuration of environment variables and runtime paths through an `.ini` settings file, eliminating the need for hardcoded environment setup scripts.

This launcher is especially useful in relocatable deployments where the runtime environment must adapt to the install location of the application.

## Overview

The launcher wraps an actual executable (typically suffixed with `-real`) and uses a flexible settings system to:

- set or extend environment variables
- prepend library paths (e.g., `LD_LIBRARY_PATH`, `DYLD_LIBRARY_PATH`, or `PATH`)
- automatically expand values using platform-aware and context-specific placeholders
- support layered configuration via multiple `.ini` files (regular, user, and additional settings)

> [!NOTE]
> Designed to be integrated in C++ CMake-based projects used to build and package Qt-based applications, the launcher settings use a simple `.ini` format and can be adapted to other scenarios.

## Getting Started

Start using **CTKAppLauncher** by integrating the [pre-built binaries](https://github.com/commontk/AppLauncher/releases) into your CMake-based project.
See [How It Works](#how-it-works) for configuration details and [Why use the pre-built binaries?](#why-use-the-pre-built-binaries) for rationale.

## How It Works

### Setting File Location

At startup, the launcher looks for a settings file named:

```
<LauncherName>LauncherSettings.ini
```

It searches the following directories, in order:

1. the directory containing the launcher executable
2. a `bin/` subdirectory
3. a `lib/` subdirectory

**Example:**

```
/path/to/AwesomeApp/
           ├── bin/
           │   ├── AwesomeApp-real
           │   └── AwesomeAppLauncherSettings.ini
           └── lib/
               └── libFoo.so
```

### Setting File Description

The settings file is a Qt-compatible `.ini` file with structured sections. Example:

```ini
[General]
launcherSplashImagePath=bin/Splash.png
launcherSplashScreenHideDelayMs=1000

[Application]
path=bin/AwesomeApp-real
arguments=--multithreading-enabled

[Paths]
1\path=./bin
size=1

[LibraryPaths]
1\path=./lib
size=1

[EnvironmentVariables]
FOO_DIRS=<APPLAUNCHER_DIR>/lib<PATHSEP>/usr/local/lib
```

#### Recognized Sections

- `Paths`: prepend to `PATH`
- `LibraryPaths`: prepend to library search paths
- `EnvironmentVariables`: set key-value pairs
- `General`: supports `additionalPathVariables`
- `Application`: used to derive user additional settings

Format follows [Qt QSettings](https://doc.qt.io/qt-5/qsettings.html#Format-enum).

### Value Expansion

At runtime, values in the settings file can include placeholders that are expanded contextually by the launcher:

| placeholder                             | description                                                    |
| --------------------------------------- | -------------------------------------------------------------- |
| `<APPLAUNCHER_DIR>`                     | Directory containing the launcher executable                   |
| `<APPLAUNCHER_NAME>`                    | Base name of the launcher executable                           |
| `<APPLAUNCHER_SETTINGS_DIR>`            | Directory of the current settings file being parsed            |
| `<PATHSEP>`                             | Platform-specific path separator (`:` on Unix, `;` on Windows) |
| `<env:VARNAME>`                         | Expands to the value of the environment variable `VARNAME`     |
| `<APPLAUNCHER_REGULAR_SETTINGS_DIR>`    | Directory of the regular (primary) settings file               |
| `<APPLAUNCHER_USER_SETTINGS_DIR>`       | Directory of the user additional settings file (if found)      |
| `<APPLAUNCHER_ADDITIONAL_SETTINGS_DIR>` | Directory of the additional settings file (if specified)       |

Expansion is **case-insensitive**, and these placeholders allow dynamic referencing of paths across different environments and installation layouts.

### Layered Settings

The launcher can load and merge up to three `.ini` settings files. These layers are processed in the following order and can each contribute values to the runtime environment:

1. **Regular settings**

   * The primary configuration file, located using the naming pattern:

     ```
     <LauncherName>LauncherSettings.ini
     ```
   * Searched in the launcher directory, `bin/`, and `lib/` subdirectories.
   * Placeholder: `<APPLAUNCHER_REGULAR_SETTINGS_DIR>`

2. **User additional settings** *(optional)*

   * Auto-discovered based on metadata in the `[Application]` group:

     * `name`, `organizationName`, `organizationDomain`, and optionally `revision`
   * Common search paths include:

     ```
     <APPLAUNCHER_DIR>/<org>/<name>(-<revision>).ini
     ~/.config/<org>/<name>(-<revision>).ini
     ```
   * Placeholder: `<APPLAUNCHER_USER_SETTINGS_DIR>`

3. **Additional settings** *(optional)*

   * Explicitly specified using the `additionalSettingsFilePath` key in the regular settings file.
   * Can selectively override or supplement specific groups.
   * Prevent group overrides with:

     ```ini
     additionalSettingsExcludeGroups = Paths,LibraryPaths,Environment
     ```
   * Placeholder: `<APPLAUNCHER_ADDITIONAL_SETTINGS_DIR>`

> [!TIP]
> All three settings files contribute to environment setup. Path variables and environment variables are accumulated and expanded using their respective placeholders, allowing highly flexible and relocatable application configurations.

### Environment Variable Construction

The launcher builds the runtime environment in **two distinct phases**:

1. **explicit variable assignment**

   * Environment variables defined under the `[EnvironmentVariables]` group are expanded using the placeholder mechanism (e.g., `<env:VAR>`, `<APPLAUNCHER_DIR>`, etc.).
   * Each key-value pair is directly added to the environment.

2. **path-based variable composition**

   * Paths listed in `[Paths]`, `[LibraryPaths]`, and groups referenced by `additionalPathVariables` are expanded and **prepended** to the corresponding environment variables.

   * The launcher ensures platform-specific behavior by mapping each section to the appropriate environment variable:

     | section        | linux             | macos               | windows |
     | -------------- | ----------------- | ------------------- | ------- |
     | `LibraryPaths` | `LD_LIBRARY_PATH` | `DYLD_LIBRARY_PATH` | `PATH`  |
     | `Paths`        | `PATH`            | `PATH`              | `PATH`  |

   * Each variable is updated in a deterministic order (entries are sorted by numeric keys like `1\path`, `2\path`, etc.).

> [!NOTE]
> You can extend this behavior using custom groups listed in the `additionalPathVariables` section. This allows for flexible mapping of user-defined path lists to specific environment variables.

## Command-line Arguments

The launcher accepts various command-line options:

```bash
./CTKAppLauncher --launcher-help

Usage
  CTKAppLauncher [options]

Options
  --launcher-help                                 Display help
  --launcher-version                              Show launcher version information
  --launcher-verbose                              Verbose mode
  --launch                                        Specify the application to launch
  --launcher-detach                               Launcher will NOT wait for the application to finish
  --launcher-no-splash                            Hide launcher splash
  --launcher-timeout                              Specify the time in second before the launcher kills the application. -1 means no timeout (default: -1)
  --launcher-load-environment                     Specify the saved environment to load.
  --launcher-dump-environment                     Launcher will print environment variables to be set, then exit
  --launcher-show-set-environment-commands        Launcher will print commands suitable for setting the parent environment (i.e. using 'eval' in a POSIX shell), then exit
  --launcher-additional-settings                  Additional settings file to consider
  --launcher-additional-settings-exclude-groups   Comma separated list of settings groups that should NOT be overwritten by values in User and Additional settings. For example: General,Application,ExtraApplicationToLaunch
  --launcher-ignore-user-additional-settings      Ignore additional user settings
  --launcher-generate-exec-wrapper-script         Generate executable wrapper script allowing to set the environment
  --launcher-generate-template                    Generate an example of setting file
```

## Environment Levels

The launcher internally tracks **environment levels** to support saving and restoring modified environments across invocations.

This mechanism enables advanced workflows like exporting a clean environment setup or temporarily modifying it for a subprocess.

### What is an environment level?

Each time the launcher runs, it adds an internal marker:

```text
APPLAUNCHER_LEVEL=N
```

This value increases with each nested launcher invocation. For example:

- First launcher run → `APPLAUNCHER_LEVEL=1`
- If the launched application runs another launcher → `APPLAUNCHER_LEVEL=2`, and so on.

The environment variables from the previous level are saved with special names:

```text
APPLAUNCHER_0_PATH=/usr/bin
APPLAUNCHER_1_PATH=/opt/AwesomeApp/bin
```

This mechanism allows restoring a prior environment level, which is particularly helpful for layered workflows or diagnostic tasks.

### Dump Environment

Print the environment as it would be set by the launcher:

```bash
./CTKAppLauncher --launcher-dump-environment
```

This includes all environment variables, with expanded values, including paths and placeholders.

### Show set environment commands

Print shell-compatible commands that set the environment in the **parent shell**:

```bash
./CTKAppLauncher --launcher-show-set-environment-commands
```

You can use this with `eval` to persist the environment without running the actual application:

```bash
eval $(./CTKAppLauncher --launcher-show-set-environment-commands)
```

### Load a previous environment level

You can explicitly request to restore a previously saved environment level using:

```bash
./CTKAppLauncher --launcher-load-environment 0
```

This will rebuild the environment based on variables prefixed by `APPLAUNCHER_0_`.

If the level specified does not exist or is out of range, the launcher will fall back to the current environment.

> [!TIP]
> Level `0` corresponds to the original environment, before any launcher-modified changes.

### How environment saving works?

When the launcher modifies an environment variable (e.g., `PATH`, `LD_LIBRARY_PATH`, etc.), it stores the previous value under a variable name prefixed with the level, such as:

```text
APPLAUNCHER_0_PATH
```

When reloading a level, it strips the prefix and applies the stored values.

Variables not part of the saved environment are unset to avoid contamination from higher levels.

This system makes the launcher robust and self-contained — no manual backup or restore of the environment is needed.

## How to integrate the launcher in your cmake project?

1. add CTKAppLauncher using [FetchContent][cmake-FetchContent] or [`ExternalProject`][cmake-ExternalProject]
   see [example][example-external-project-slicer]

2. Use the provided helper functions `ctkAppLauncherConfigureForTarget()` or `ctkAppLauncherConfigureForExecutable()`
   available in [`ctkAppLauncher.cmake`][cmake-ctkAppLauncher]

[cmake-FetchContent]: https://cmake.org/cmake/help/latest/module/FetchContent.html
[cmake-ExternalProject]: https://cmake.org/cmake/help/latest/module/ExternalProject.html
[cmake-ctkAppLauncher]: https://github.com/commontk/AppLauncher/blob/main/CMake/ctkAppLauncher.cmake
[example-external-project-slicer]: https://github.com/Slicer/Slicer/blob/v5.8.1/SuperBuild/External_CTKAPPLAUNCHER.cmake

## Building From Source

To build CTKAppLauncher, you’ll need a C++ compiler, Qt 4.x or 5.x, and CMake 3.16+.

Clone the repository:

```bash
git clone git@github.com:commontk/AppLauncher.git CTKAppLauncher
```

Configure the build:

**On Windows:**

```cmd
cmake ^
  -B CTKAppLauncher-build ^
  -S CTKAppLauncher
```

**On macOS/Linux:**

```bash
cmake \
  -DCMAKE_BUILD_TYPE:STRING=Release \
  -B CTKAppLauncher-build \
  -S CTKAppLauncher
```

Build the project:

```bash
cmake --build CTKAppLauncher-build --config Release --parallel
```

Run tests:

```bash
ctest --test-dir CTKAppLauncher-build --build-config Release --output-on-failure --parallel
```

> [!TIP]
>
> To generate a standalone package, you need to **either** build Qt statically
> or reuse the archives available at [jcfr/qt-static-build](https://github.com/jcfr/qt-static-build).
>
> See the [CI workflow](.github/workflows/CI.yml) for build configuration details.

## Archives and Releases

Each GitHub release includes:

- platform-specific archives
- exact build instructions used
- whether the archive is relocatable or has fixed path expectations

See the GitHub release description for full details.

## Frequently Asked Questions

### Why use the pre-built binaries?

The pre-built binaries are statically linked and do not require Qt to be present on the host system.
If your application bundles Qt libraries, using these binaries ensures the launcher works out of the box across platforms.

## Known Issues

- on Windows, the `--launcher-timeout` option may not work as expected

## Contributing

Contributions are welcome, and they are greatly appreciated! Every
little bit helps, and credit will always be given.

See [CONTRIBUTING.md][contributing] for more details.

[contributing]: https://github.com/commontk/AppLauncher/blob/main/CONTRIBUTING.md

## maintainers: How to make a release ?

*Follow the steps below after verifying that all tests pass.*

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

5. Publish the tag to trigger the release build

    ```bash
    git push origin $tag
    ```

6. Publish the GitHub Release

   Once the [CI workflow][ci-workflow] completes for the pushed tag, create a GitHub release.

   This will automatically trigger the [CD workflow][cd-workflow] to upload the release assets.

[ci-workflow]: https://github.com/commontk/AppLauncher/actions/workflows/CI.yml
[cd-workflow]: https://github.com/commontk/AppLauncher/actions/workflows/CD.yml

7. Update `CMakeLists.txt` setting `CTKAppLauncher_VERSION_IS_RELEASE` to `0`

    ```bash
    sed -E "s/set\(CTKAppLauncher_VERSION_IS_RELEASE 1\)/set\(CTKAppLauncher_VERSION_IS_RELEASE 0\)/g" -i CMakeLists.txt && \
    git add CMakeLists.txt && \
    git commit -m "Begin post-$tag development [ci skip]" && \
    git diff HEAD^
    ```

8. Publish the changes:

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
