#!/bin/bash -x

# only proceed script when started not by pull request (PR)
if [ $TRAVIS_PULL_REQUEST == "true" ]; then
  echo "this is a PR, exiting"
  exit 0
fi

# enable error reporting to the console
set -e

#
# clone `master' branch of the repository
# using encrypted GH_TOKEN for authentification
#
clone_repo() {
  echo -e "Cloning master\n"
  rm -rf site || true
  git clone -b master https://${GH_TOKEN}@github.com/rknuus/agile-quality.git site > /dev/null 2>&1
}

build_site() {
  echo -e "Building Jekyll site\n"
  bundle exec jekyll build -d site
}

cleanup_site() {
  touch .nojekyll
  rm build.sh

  echo "branches:
    only:
    - jekyll
  " > .travis.yml
}

setup_git() {
  git config --global user.email "rknuus@gmail.com"
  git config --global user.name "rknuus"
}

commit_website_files() {
  pushd site
  git checkout -b gh-pages
  git add .
  git commit --message "Travis build: $TRAVIS_BUILD_NUMBER"
  popd
}

upload_files() {
  pushd site
  git remote add origin-pages https://${GH_TOKEN}@github.com/rknuus/agile-quality.git > /dev/null 2>&1
  git push --quiet --set-upstream origin-pages gh-pages
  popd
}

clone_repo
build_site
cleanup_site
setup_git
commit_website_files
upload_files