#!/bin/sh

set -e

DIR_INIT=$(pwd)
DIR_PCRE="$1"

apk add perl

cd "$DIR_PCRE"

./configure --disable-dependency-tracking

cd "$DIR_INIT"
