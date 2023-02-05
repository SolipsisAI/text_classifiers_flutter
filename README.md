# text_classifiers

Text classifiers for Flutter

- [text\_classifiers](#text_classifiers)
  - [Pre-requisites](#pre-requisites)
  - [Install dependencies](#install-dependencies)
  - [Python manual setup](#python-manual-setup)

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

## Python manual setup

```shell
# SETUP PYTHON
pyenv install miniforge3
# Activate miniforge3
pyenv shell miniforge3
# Setup conda environment
conda create --name tensorflow # this can be any name
# Activate environment
conda activate tensorflow
# Install numpy
conda install numpy
```