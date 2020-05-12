#!/bin/bash -e 
TARGET="$1"
VERSIONDIR="$2"

cd `dirname $0`

cp build.profile.js prepend.js ../../webif/lib

sed -i "s/{{VERSIONDIR}}/$VERSIONDIR/g" ../../webif/lib/prepend.js

if [ "$TARGET" != "prod" ]; then
  cat build.profile.debug.js >> ../../webif/lib/build.profile.js
fi

cd ../../webif
rm -f lib/app
ln -s ../js lib/app

RELEASEDIR=`mktemp -d`
cd lib/util/buildscripts
node ../../../lib/dojo/dojo.js load=build \
  --require ../../../lib/app/run.js \
  --profile ../../../lib/build.profile.js \
  --releaseDir $RELEASEDIR
cd ../../..

export_js() {
  if [ "$TARGET" == "prod" ]; then
    UGLY_OPTS="-m -c"
  else
    UGLY_OPTS="-b --comments all"
  fi

  cat $1 |uglifyjs $UGLY_OPTS > $2
}

# completely remove console in prod build, but also 
# include always-true condition in debug to prevent prod-only errors
if [ "$TARGET" == "prod" ]; then DEBUG_INT=0; else DEBUG_INT=1; fi
sed -i "s/console\\./$DEBUG_INT \\&\\& console./g" $RELEASEDIR/dojo/dojo.js

cat lib/prepend.js $RELEASEDIR/dojo/dojo.js > $RELEASEDIR/app.js

export_js $RELEASEDIR/app.js dist/app/$VERSIONDIR/app.js
export_js $RELEASEDIR/dojo/nls/dojo_de.js dist/app/$VERSIONDIR/nls/dojo_de.js

# replace ~ with soft hyphens in NLS file in NLS files (unicode U+00AD)
sed -i 's/~/\xC2\xAD/g' dist/app/$VERSIONDIR/nls/*.js

rm -rf $RELEASEDIR

