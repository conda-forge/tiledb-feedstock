#!/bin/sh
set -exo pipefail

# Copy tiledb-patches to the source directory
cp -r "${RECIPE_DIR}/tiledb-patches/." "${SRC_DIR}"

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

if [[ $target_platform == osx-arm64  ]]; then
  export VCPKG_TARGET_TRIPLET="arm64-osx"
fi
if [[ $target_platform == osx-64  ]]; then
  export VCPKG_TARGET_TRIPLET="x64-osx"
fi
if [[ $target_platform == linux-64  ]]; then
  export VCPKG_TARGET_TRIPLET="x64-linux"
fi
if [[ $target_platform == linux-ppc64le  ]]; then
  export VCPKG_TARGET_TRIPLET="ppc64le-linux"
fi
if [[ $target_platform == linux-aarch64  ]]; then
  export VCPKG_TARGET_TRIPLET="arm64-linux"
fi

if [[ $gcs == gcs_enabled ]]; then
  export TILEDB_GCS=ON
else
  export TILEDB_GCS=OFF
fi

print_logs()
{
  for f in $(find $SRC_DIR/{build,external} -name "*.log");
  do
    echo "##[group]$f"
    cat $f
    echo "##[endgroup]"
  done;
}

mkdir build && cd build
if ! cmake ${CMAKE_ARGS} \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_BUILD_TYPE=Release \
  -DTILEDB_WERROR=OFF \
  -DTILEDB_TESTS=OFF \
  -DTILEDB_INSTALL_LIBDIR=lib \
  -DTILEDB_HDFS=ON \
  -DSANITIZER=OFF \
  -DCOMPILER_SUPPORTS_AVX2:BOOL=FALSE \
  -DTILEDB_AZURE=ON \
  -DTILEDB_GCS=${TILEDB_GCS} \
  -DTILEDB_S3=ON \
  -DTILEDB_SERIALIZATION=ON \
  -DTILEDB_LOG_OUTPUT_ON_FAILURE=ON \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET} \
  -DVCPKG_TARGET_TRIPLET=${VCPKG_TARGET_TRIPLET} \
  ..
then
  print_logs
  exit 1
fi
if ! make -j ${CPU_COUNT}
then
  print_logs
  exit 1
fi
if ! make -C tiledb install
then
  print_logs
  exit 1
fi
