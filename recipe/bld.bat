setlocal EnableDelayedExpansion

mkdir build
if errorlevel 1 exit 1

pushd build
if errorlevel 1 exit 1

cmake -G "%CMAKE_GENERATOR%" ^
      -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_BUILD_TYPE:STRING="Release" ^
      ..
if errorlevel 1 exit 1

cmake --build . --target INSTALL
if errorlevel 1 exit 1

popd
