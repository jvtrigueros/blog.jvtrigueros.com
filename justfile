# Start a Jekyll development server with livereload
serve:
    cd ./src && bundle exec jekyll serve --drafts --force_polling --livereload

# Creates a draft under `./src/_drafts/{{draft}}.md`
@create-draft draft:
    echo Creating draft "{{draft}}"
    cd ./src && bundle exec jekyll draft {{draft}}

# Publishes a draft from `./src/_drafts/{{draft}}.md` -> `./src/_posts/<date>-{{draft}}.md`
@publish-draft draft:
    echo Publishing draft "{{draft}}"
    cd ./src && bundle exec jekyll publish "_drafts/{{draft}}.md"
