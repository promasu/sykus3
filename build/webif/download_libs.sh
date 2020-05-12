#!/bin/bash -e

cd `dirname $0`/../../webif

source Versionfile

mkdir -p ../cache
pushd ../cache
CACHEDIR=`pwd`
popd

install_package() {
  rm -rf $2*
  if [ ! -e $CACHEDIR/$2-$3.tgz ]; then
    wget "https://github.com/$1/$2/archive/$3.tar.gz" -O $CACHEDIR/$2-$3.tgz
  fi
  tar -xzf $CACHEDIR/$2-$3.tgz
  rm -f $2.tgz

  # use wildcard since some projects have a "v" prefix that is not
  # in the repo version string and vice versa
  mv $2* "$2"

  # remove tests (blocks build process)
  rm -rf $2/test $2/tests
}

mkdir -p lib
cd lib

install_package dojo dojo $DOJO_VERSION
install_package dojo util $DOJO_UTIL_VERSION
install_package twbs bootstrap $BOOTSTRAP_VERSION
install_package janl mustache.js $MUSTACHE_VERSION
install_package FortAwesome Font-Awesome $FONT_AWESOME_VERSION


