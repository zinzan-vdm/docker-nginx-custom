#!/bin/sh

set -e

DIR_INIT=$(pwd)
DIR_ZLIB="$1"

cd "$DIR_ZLIB"

./configure

cd "$DIR_INIT"
