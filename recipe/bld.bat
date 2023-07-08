setlocal EnableDelayedExpansion

mkdir "%SRC_DIR%"\build
pushd "%SRC_DIR%"\build

if "%gcs%"=="gcs_enabled" (
    set TILEDB_GCS=ON
) else (
    set TILEDB_GCS=OFF
)

cmake -G "NMake Makefiles" ^
      -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DTILEDB_WERROR=OFF ^
      -DTILEDB_AZURE=ON ^
      -DTILEDB_GCS=%TILEDB_GCS% ^
      -DTILEDB_S3=ON ^
      -DTILEDB_HDFS=OFF ^
      -DCOMPILER_SUPPORTS_AVX2=OFF ^
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
