#!/bin/sh
set -exo pipefail

if [[ $target_platform =~ osx.* ]]; then
  CURL_LIBS_APPEND=`curl-config --libs`
  export LDFLAGS="${LDFLAGS} ${CURL_LIBS_APPEND}"
fi

mkdir build && cd build
cmake \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_BUILD_TYPE=Release \
  -DTILEDB_WERROR=OFF \
  -DTILEDB_TESTS=OFF \
  -DTILEDB_INSTALL_LIBDIR=lib \
  -DTILEDB_HDFS=ON \
  -DSANITIZER="OFF;-DCOMPILER_SUPPORTS_AVX2:BOOL=FALSE" \
  -DTILEDB_S3=ON \
  -DTILEDB_AZURE=ON \
  -DTILEDB_SERIALIZATION=ON \
  -DTILEDB_LOG_OUTPUT_ON_FAILURE=ON \
  ..
make -j ${CPU_COUNT}
make -C tiledb install
