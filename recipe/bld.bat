setlocal EnableDelayedExpansion

mkdir "%SRC_DIR%"\build
pushd "%SRC_DIR%"\build

cmake -G "NMake Makefiles" ^
      -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
      -DTILEDB_VCPKG=OFF ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DTILEDB_WERROR=OFF ^
      -DTILEDB_AZURE=ON ^
      -DTILEDB_GCS=ON ^
      -DTILEDB_S3=ON ^
      -DTILEDB_HDFS=OFF ^
      -DCOMPILER_SUPPORTS_AVX2=OFF ^
      -DTILEDB_SKIP_S3AWSSDK_DIR_LENGTH_CHECK=ON ^
      -DTILEDB_SERIALIZATION=ON ^
      -Dlibxml2_DIR="%LIBRARY_PREFIX%" ^
      -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
      ..
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

pushd "tiledb"
nmake install
if errorlevel 1 exit 1
popd

popd
