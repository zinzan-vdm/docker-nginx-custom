#!/bin/sh

set -e

DIR_INIT=$(pwd)
DIR_OPENSSL="$1"

cd "$DIR_OPENSSL"

./config --prefix=/usr

cd "$DIR_INIT"
