@echo off

docker run --rm -d --name jk -p 4000:4000 -e FORCE_POLLING=true -e DRAFTS=true -v %cd%\src:/srv/jekyll jekyll/jekyll:3.8.5 jekyll s

echo INFO: Starting Jekyll server on port http://localhost:4000
