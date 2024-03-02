setlocal EnableDelayedExpansion

REM Copy tiledb-patches to the source directory
xcopy /Y /S /I "%RECIPE_DIR%\tiledb-patches" "%SRC_DIR%"

mkdir "%SRC_DIR%"\build
pushd "%SRC_DIR%"\build

cmake -G Ninja ^
      -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DTILEDB_WERROR=OFF ^
      -DTILEDB_TESTS=OFF ^
      -DTILEDB_AZURE=ON ^
      -DTILEDB_GCS=ON ^
      -DTILEDB_S3=ON ^
      -DTILEDB_HDFS=OFF ^
      -DCOMPILER_SUPPORTS_AVX2=OFF ^
      -DTILEDB_SKIP_S3AWSSDK_DIR_LENGTH_CHECK=ON ^
      -DTILEDB_SERIALIZATION=ON ^
      -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
      -DVCPKG_TARGET_TRIPLET=x64-windows ^
      ..
if errorlevel 1 exit 1

cmake --build . -j
if errorlevel 1 exit 1

pushd "tiledb"
cmake --build . --target install
if errorlevel 1 exit 1
popd

popd
