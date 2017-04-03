#!/bin/bash
set -o errexit

SOURCE_BRANCH="master"
TARGET_BRANCH="gh-pages"

REPO=`git config remote.origin.url`
SSH_REPO=${REPO/https:\/\/github.com\//git@github.com:}
SHA=`git rev-parse --verify HEAD`

git config --global user.email "travis@travis-ci.org"
git config --global user.name "Travis CI"

cp README.md build/web
cp LICENSE build/web/license.txt

cd build/web
git init
git add --a
git commit -m "Deploy to Github Pages: ${SHA}"

ENCRYPTED_KEY_VAR="encrypted_${ENCRYPTION_LABEL}_key"
ENCRYPTED_IV_VAR="encrypted_${ENCRYPTION_LABEL}_iv"
ENCRYPTED_KEY=${!ENCRYPTED_KEY_VAR}
ENCRYPTED_IV=${!ENCRYPTED_IV_VAR}
openssl aes-256-cbc -K $ENCRYPTED_KEY -iv $ENCRYPTED_IV -in deploy_key.enc -out deploy_key -d
chmod 600 deploy_key
eval `ssh-agent -s`
ssh-add deploy_key

git push --force --quiet $SSH_REPO $TARGET_BRANCH