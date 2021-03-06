#!/bin/bash -e
go build

if [[ $TRAVIS_BRANCH == 'master' && $TRAVIS_REPO_SLUG == "rahulsom/mailcli" && $TRAVIS_PULL_REQUEST == 'false' ]]; then

  cat .goxc.json.template | sed -e "s/\$BINTRAY_APIKEY/$BINTRAY_APIKEY/g" > .goxc.json
  goxc && goxc bintray

  # SNAPSHOT_DIR=$HOME/gopath/bin/mailcli-xc/snapshot
  asciidoctor \
     -a mailcliVersion=$(ls -1tr $HOME/gopath/bin/mailcli-xc/ | tail -1) \
     index.adoc

  git config --global user.name "$GIT_NAME"
  git config --global user.email "$GIT_EMAIL"
  git config --global credential.helper "store --file=~/.git-credentials"
  echo "https://$GH_TOKEN:@github.com" > ~/.git-credentials

  git clone https://${GH_TOKEN}@github.com/$TRAVIS_REPO_SLUG.git -b gh-pages \
      gh-pages --single-branch > /dev/null
  cd gh-pages
  git rm -rf .
  cp ../index.html .
  git add *
  git commit -a -m "Updating docs for Travis build: https://travis-ci.org/$TRAVIS_REPO_SLUG/builds/$TRAVIS_BUILD_ID"
  git push origin HEAD
  cd ..
  rm -rf gh-pages

  # ./grailsw publish-plugin --no-scm --allow-overwrite --non-interactive
else
  echo "Not on master branch, so not publishing"
  echo "TRAVIS_BRANCH: $TRAVIS_BRANCH"
  echo "TRAVIS_REPO_SLUG: $TRAVIS_REPO_SLUG"
  echo "TRAVIS_PULL_REQUEST: $TRAVIS_PULL_REQUEST"
fi
