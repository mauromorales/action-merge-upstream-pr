#!/bin/sh

set -e
set -x

if [ $INPUT_DESTINATION_HEAD_BRANCH == "main" ] || [ $INPUT_DESTINATION_HEAD_BRANCH == "master"]
then
  echo "Destination head branch cannot be 'main' nor 'master'"
  return -1
fi

if [ -z "$INPUT_PULL_REQUEST_REVIEWERS" ]
then
  PULL_REQUEST_REVIEWERS=$INPUT_PULL_REQUEST_REVIEWERS
else
  PULL_REQUEST_REVIEWERS='-r '$INPUT_PULL_REQUEST_REVIEWERS
fi

CLONE_DIR=$(mktemp -d)

echo "Setting git variables"
export GITHUB_TOKEN=$API_TOKEN_GITHUB
git config --global user.email "$INPUT_USER_EMAIL"
git config --global user.name "$INPUT_USER_NAME"

echo "Cloning destination git repository"
git clone "https://$API_TOKEN_GITHUB@github.com/$INPUT_DESTINATION_REPO.git" "$CLONE_DIR"

cd "$CLONE_DIR"
git remote add upstream "https://$API_TOKEN_GITHUB@github.com/$GITHUB_REPOSITORY.git"
git checkout -b "$INPUT_DESTINATION_HEAD_BRANCH-$GITHUB_SHA"

echo "Fetching upstream"
git fetch upstream

echo "Merging"
git merge upstream/master --log -m 'Merge upstream/master'

echo "Pushing git commit"
git push -u origin HEAD:$INPUT_DESTINATION_HEAD_BRANCH
echo "Creating a pull request"
gh pr create -f -R $INPUT_DESTINATION_REPO \
                $PULL_REQUEST_REVIEWERS
