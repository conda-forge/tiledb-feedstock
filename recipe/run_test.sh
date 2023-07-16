#!/bin/sh

# This test builds the contents of link_test_src, a simple test executable
# linked against tiledb. Then runs the executable.
cmake -B link_test_bld -S $RECIPE_DIR/link_test_src
cmake --build link_test_bld
cmake --build link_test_bld --target link_test -v
