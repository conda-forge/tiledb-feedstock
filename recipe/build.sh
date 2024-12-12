#!/bin/sh
set -exo pipefail

# Copy tiledb-patches to the source directory
cp -r "${RECIPE_DIR}/tiledb-patches/." "${SRC_DIR}"

# Disable -Werror
export CFLAGS="${CFLAGS//-Werror/}"
export CXXFLAGS="${CXXFLAGS//-Werror/}"

export CMAKE_OSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET}

# https://conda-forge.org/docs/maintainer/knowledge_base/#newer-c-features-with-old-sdk
if [[ $target_platform == osx-64  ]]; then
  CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

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

print_logs()
{
  for f in $(find $SRC_DIR/{build,external} -name "*.log");
  do
    echo "##[group]$f"
    cat $f
    echo "##[endgroup]"
  done;
}

# Regenerate the capnp serialization files with the version installed in Conda.
# This allows updating capnproto independently of upstream tiledb.
if ! $BUILD_PREFIX/bin/capnp compile -I $BUILD_PREFIX/include -oc++:$SRC_DIR/tiledb/sm/serialization $SRC_DIR/tiledb/sm/serialization/tiledb-rest.capnp --src-prefix=$SRC_DIR/tiledb/sm/serialization
then
  exit 1
fi

# We use -DTILEDB_CMAKE_IDE=ON to disable the superbuild, because
# -DTILEDB_SUPERBUILD=OFF also disables auto-downloading vcpkg.

mkdir build && cd build
if ! cmake ${CMAKE_ARGS} \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_BUILD_TYPE=Release \
  -DTILEDB_CMAKE_IDE=ON \
  -DTILEDB_WERROR=OFF \
  -DTILEDB_TESTS=OFF \
  -DTILEDB_INSTALL_LIBDIR=lib \
  -DTILEDB_HDFS=ON \
  -DSANITIZER=OFF \
  -DCOMPILER_SUPPORTS_AVX2:BOOL=FALSE \
  -DTILEDB_AZURE=ON \
  -DTILEDB_GCS=ON \
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
if ! make -j ${CPU_COUNT} install
then
  print_logs
  exit 1
fi
