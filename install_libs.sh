#!/usr/bin/env bash
PROJECT_DIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
TF_DIR=${PROJECT_DIR}/../tensorflow
BLOBS_DIR=$HOME/Library/Containers/ai.solipsis.Solipsis/Data/blobs
TFLITE_IOS_DIR=$PROJECT_DIR/ios/.symlinks/plugins/tflite_flutter/ios

BAZEL_VERSION=5.0.0
TF_VERSION=2.9

BAZEL_URL=https://github.com/bazelbuild/bazel/releases/download/$BAZEL_VERSION/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh
BASE_LIB_FILENAME="libtensorflowlite_c"

setup_python () {
  cd $PROJECT_DIR
  python -m venv venv
  source venv/bin/activate
  echo $(which python)
  pip install numpy
}

setup_bazel () {
  if ! command -v bazel &> /dev/null
  then
    echo "bazel-$BAZEL_VERSION not installed"
    curl -L -o /tmp/bazel-installer.sh $BAZEL_URL
    chmod +x /tmp/bazel-installer.sh
    /tmp/bazel-installer.sh --user
  fi
}

build_binaries () {
  cd $PROJECT_DIR/..

  if [ ! -d "$TF_DIR" ]; then
      git clone https://github.com/tensorflow/tensorflow.git
  fi

  cd $TF_DIR

  git checkout r$TF_VERSION

  unamestr=$(uname)
  if [[ "$unamestr" == 'Linux' ]]; then
    bazel build -c opt //tensorflow/lite/c:tensorflowlite_c --define tflite_with_xnnpack=true
  elif [[ "$unamestr" == 'Darwin' ]]; then
    # Must be built on x86_64 on M1
    arch -x86_64 bazel build -c opt //tensorflow/lite/c:tensorflowlite_c --define tflite_with_xnnpack=true
  fi
}

build_ios_binaries () {
    setup_python

    cd $PROJECT_DIR/..

    if [ ! -d "$TF_DIR" ]; then
        git clone https://github.com/tensorflow/tensorflow.git
    fi

    cd $TF_DIR

    bazel clean
    TF_CONFIGURE_IOS=True ./configure
    bazel build --config=ios_fat -c opt \
        //tensorflow/lite/ios:TensorFlowLiteC_framework

    unzip $TF_DIR/bazel-bin/tensorflow/lite/ios/TensorFlowLiteC_framework.zip \
        -d $TFLITE_IOS_DIR
    
    # This is absolutely necessary
    cd $PROJECT_DIR
    flutter clean
    flutter pub get
    cd $PROJECT_DIR/ios 
    pod install
    cd $PROJECT_DIR
}

copy_to_project () {
    mkdir -p $BLOBS_DIR
    cp $TF_DIR/bazel-bin/tensorflow/lite/c/$src_filename $BLOBS_DIR/$dest_filename
}

unamestr=$(uname)
if [[ "$unamestr" == 'Linux' ]]; then
    echo "Setting up on Linux"
    src_filename="${BASE_LIB_FILENAME}.so"
    dest_filename="${BASE_LIB_FILENAME}-linux.so"
    BLOBS_DIR=${PROJECT_DIR}/blobs
    mkdir -p $BLOBS_DIR
    #setup_linux
elif [[ "$unamestr" == 'Darwin' ]]; then
    echo "macos"
    src_filename="${BASE_LIB_FILENAME}.dylib"
    dest_filename="${BASE_LIB_FILENAME}-mac.so" # the tflite_flutter plugin looks for a *.so file
else
    echo "Unsupported"
    exit 1
fi

if [[ "$INCLUDE_IOS" == 'True' || "$INCLUDE_IOS" == 'true' ]]; then
    if [ ! -d "$PROJECT_DIR/ios/.symlinks/plugins/tflite_flutter/ios/TensorFlowLiteC.framework"]; then
        echo "[INFO] Building iOS dependencies"
        build_ios_binaries
    else
        echo "[SKIP] TensorFlowLiteC.framework already built; skipping"
    fi
fi

if [ ! -d  "$BLOBS_DIR/$dest_filename" ]; then
    echo "[INFO] Installing dependencies"
    setup_bazel
    setup_python
    build_binaries
    copy_to_project
    echo "[SUCCESS] $dest_filename copied to $BLOBS_DIR"
fi
