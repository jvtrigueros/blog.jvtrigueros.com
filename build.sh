#! /bin/bash
jekyll build
find _site/assets/ -type f -name *.png -exec convert {} -strip {} \;
find _site/assets/ -type f -name *.jpg -exec convert {} -sampling-factor 4:2:0 -strip -quality 85 -interlace JPEG -colorspace RGB {} \;
s3_website push
