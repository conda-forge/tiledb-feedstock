#!/bin/sh
set -exo pipefail

# Use CC/CXX wrappers to disable -Werror
export NN_CXX_ORIG=$CXX
export NN_CC_ORIG=$CC
export CXX=$RECIPE_DIR/cxx_wrap.sh
export CC=$RECIPE_DIR/cc_wrap.sh
export CMAKE_OSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET}

CURL_LIBS_APPEND=`$PREFIX/bin/curl-config --libs`
export LDFLAGS="${LDFLAGS} ${CURL_LIBS_APPEND}"

if [[ $target_platform  == linux-64 ]]; then
  export LDFLAGS="${LDFLAGS} -Wl,--no-as-needed -lrt"
fi

if [[ $target_platform == osx-arm64  ]]; then
  export FILE_COMMAND_OVERRIDE=`which file`
fi

if [[ $gcs == gcs_enabled ]]; then
  export TILEDB_GCS=ON
else
  export TILEDB_GCS=OFF
fi

mkdir build && cd build
cmake ${CMAKE_ARGS} \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_BUILD_TYPE=Release \
  -DTILEDB_WERROR=OFF \
  -DTILEDB_TESTS=OFF \
  -DTILEDB_INSTALL_LIBDIR=lib \
  -DTILEDB_HDFS=ON \
  -DSANITIZER=OFF \
  -DCOMPILER_SUPPORTS_AVX2:BOOL=FALSE \
  -DTILEDB_AZURE=OFF \
  -DTILEDB_GCS=${TILEDB_GCS} \
  -DTILEDB_S3=ON \
  -DTILEDB_SERIALIZATION=ON \
  -DTILEDB_LOG_OUTPUT_ON_FAILURE=ON \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET} \
  ..
make -j ${CPU_COUNT}
make -C tiledb install
