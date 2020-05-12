#!/bin/bash -e

TARGET="$1"

VERSIONDIR="$(date +%s%N |sha256sum |head -c 32)"

cd `dirname $0`
JS_BUILD=`pwd`/js_build.sh

cd ../../webif
rm -rf dist || true
mkdir -p dist/app/$VERSIONDIR/{font,nls}

process_textfile() {
  if [ "$TARGET" == "prod" ]; then
    cat "$1" \
      |tr '\n' ' ' \
      |sed -e 's/\s\+/ /g' \
      > "$2"
  else
    cat "$1" > "$2"
  fi

  sed -i "s/{{VERSIONDIR}}/$VERSIONDIR/g" "$2"
}

# HTML
cd html
for FILE in $(find -type f); do
  DIR="../dist/$(dirname "$FILE")"
  mkdir -p "$DIR"

  process_textfile "$FILE" "$DIR/$(basename "$FILE")"
done
cd ..

# CSS / LESS
if [ "$TARGET" == "prod" ]; then
  OPTS="-x --yui-compress"
else
  OPTS=""
fi
lessc $OPTS less/main.less > dist/app/$VERSIONDIR/styles.css

# Images / Fonts
cp font/*.woff dist/app/$VERSIONDIR/font
cp lib/Font-Awesome/font/fontawesome-webfont.* dist/app/$VERSIONDIR/font

# NLS
cd nls
for MODULE in $(find -name '*.js'); do
  DIR="../js/$(dirname "$MODULE")/nls"
  mkdir -p $DIR

  cp $MODULE $DIR
done
cd ..

# Templates
cd templates
for MODULE in $(find -name '*.html'); do
  DIR="../js/$(dirname "$MODULE")/templates"
  mkdir -p "$DIR"

  process_textfile "$MODULE" "$DIR/$(basename "$MODULE")"
done
cd ..

# Javascript
$JS_BUILD $1 $VERSIONDIR

# Static GZIP
for FILE in $(find dist/app/$VERSIONDIR -type f); do
  gzip -9 < $FILE > $FILE.gz
done


