#!/bin/bash

CUR_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
TMP_DIR=/tmp/_strings

rm -r $TMP_DIR/*

mkdir $TMP_DIR 2>/dev/null
mkdir $TMP_DIR/Base.lproj

cp $CUR_DIR/../Sources/*.swift $TMP_DIR/.
cp $CUR_DIR/../Sources/*.m $TMP_DIR/.

#ls -lsa $TMP_DIR

echo "-> using sed to replace value: ..."

for s in $TMP_DIR/*.swift
do
#  echo "parsing $s"
  sed -E 's/NSLocalizedString\("(.*)",[ ]+value: "(.*)",[ ]+comment: "(.*)"\)/NSLocalizedString\("\1", comment: "\3"\)/g' $s > "$TMP_DIR/tmp.swift"
  mv "$TMP_DIR/tmp.swift" $s
done

echo "-> gerenate Localizable.strings file"

#find $TMP_DIR -name \*.swift | xargs genstrings -o $TMP_DIR/Base.lproj
genstrings -o $TMP_DIR/Base.lproj $TMP_DIR/*.{swift,m}
#genstrings -o $TMP_DIR/Base.lproj $TMP_DIR/*.m

#for s in $TMP_DIR/*.swift
#do
#  genstrings -o $TMP_DIR/Base.lproj $s
#done

# run ruby script
#ruby $CUR_DIR/test_swift_get_values.rb

#rm $TMP_DIR/*.swift

echo "-> open output folder"
open $TMP_DIR/Base.lproj

