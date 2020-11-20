#!/bin/sh

args="${@##-Werror*}"
$NN_CC_ORIG $args
