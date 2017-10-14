@echo off

echo "INFO: Creating draft %1"

docker exec jk bundle exec jekyll draft %1

