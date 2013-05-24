#!/bin/sh

for dir in $@; do
  for i in `ls $dir`; do
    echo "Processing $dir/$i"
    echo "name '$i'" > $dir/$i/metadata.rb
    echo "" >> $dir/$i/metadata.rb
    (grep -r "include_recipe" $dir/$i | perl -pe 's/^.*include_recipe ["'\''](.*)["'\''].*$/\1/g' | perl -pe 's/(.*)::.*/\1/g' | grep -v $i | sort | uniq | while read j; do
        echo "depends \"$j\""
    done) >> $dir/$i/metadata.rb
  done
done