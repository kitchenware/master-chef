#!/bin/sh

for dir in $@; do
  for i in `ls $dir`; do
    grep -r 'define :' $dir/$i | grep '/definitions/' | perl -pe 's/^.*define :(.*),.*$/\1/g' | while read j; do
      # echo "Found definition in $i : $j"
      for dir2 in $@; do
        for i2 in `ls $dir2`; do
          grep -r "$j " $dir2/$i2 | grep '\.rb' | awk -F: '{print $1}' | while read k; do
            # echo "Found call to $j in $i2 : $k"
            if ! cat $dir2/$i2/metadata.rb | grep $i 2>&1 > /dev/null; then
              echo "Dependency not found $i2 to $i, definition $j called from $k"
            fi
          done
        done
      done
    done
  done
done