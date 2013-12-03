#!/bin/sh
# CMMI bashdb
VERSION="4.2-0.8"
PKG="bashdb-$VERSION.tar.bz2"
DIR="bashdb-$VERSION"
URL="http://sourceforge.net/projects/bashdb/files/bashdb/$VERSION/$PKG/download"
PREFIX="$HOME/.local"
if [ ! -f "$PKG" ]; then
    wget $URL -O $PKG
fi
if [ ! -d "$DIR" ]; then
    tar xjvf $PKG
fi
cd $DIR
./configure --prefix="$PREFIX"
make
echo "TODO: rm -rfv $DIR*"
