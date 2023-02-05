<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

## Pre-requisites

- `bazel-5.0.0` to be installed by `install_libs.sh`
- `python3` which can be set up by the `install_libs.sh` script.
- `numpy` same as above

## Install dependencies

```shell
# INSTALL LIBRARIES FOR DESKTOP
bash ./install_libs.sh

# INSTALL LIBRARIES FOR IOS
INCLUDE_IOS=true bash ./install_libs.sh

# Download model file and vocab text
bash ./download_assets.sh
```