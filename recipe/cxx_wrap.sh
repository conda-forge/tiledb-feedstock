#!/bin/sh

args="${@##-Werror*}"
$NN_CXX_ORIG $args
