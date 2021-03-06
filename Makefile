JEKYLL_VERSION=3.8
JEKYLL_CMD=docker exec jk bundle exec jekyll

# https://github.com/jekyll/jekyll-compose
draft:
	@echo Creating draft "$(name)"
	$(JEKYLL_CMD) draft "$(name)"

publish:
	@echo Publishing draft "$(name)"
	$(JEKYLL_CMD) publish "_drafts/$(name)"

start:
	docker run \
	--rm -d \
	--name jk \
	-p 4000:4000 \
	-e FORCE_POLLING=true \
	-e DRAFTS=true \
	-v bundle:/usr/local/bundle \
	-v $(PWD)/src:/srv/jekyll \
	jekyll/jekyll:$(JEKYLL_VERSION) \
	jekyll server
	@echo Starting Jekyll server on port 4000

stop:
	docker stop jk
	@echo Stopping Jekyll server

update:
	docker run --rm \
	-v bundle:/usr/local/bundle \
	-v $(PWD)/src:/srv/jekyll \
	-it jekyll/jekyll:$(JEKYLL_VERSION) \
	bundle update

watch:
	@echo Watching Jekyll development website on http://localhost:3000
	npx browser-sync start \
	-s $(PWD)/src/_site \
	-f $(PWD)/src/_site \
	--reload-debounce 500 --no-open
