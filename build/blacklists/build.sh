#!/bin/bash -e

SHALLALIST="http://www.shallalist.de/Downloads/shallalist.tar.gz"
TOULOUSELIST="ftp://ftp.ut-capitole.fr/pub/reseau/cache/squidguard_contrib/blacklists.tar.gz"

cd "$(dirname 0)"

rm -rf dist tmp
mkdir tmp dist

# download blacklists
cd tmp

wget "$SHALLALIST" -O shalla.tgz
tar -xzf shalla.tgz
mv BL ../dist/shalla

wget "$TOULOUSELIST" -O toulouse.tgz
tar -xzf toulouse.tgz
mv blacklists ../dist/uni-toulouse

cd ..

# copy category description file
cp categories.yaml dist

# cleanup
rm -rf tmp

