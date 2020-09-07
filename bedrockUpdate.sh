#!/bin/bash

VERSION=$(curl -v -L --silent  https://www.minecraft.net/en-us/download/server/bedrock/ 2>&1 | grep 'https://minecraft.azureedge.net/bin-linux/bedrock-server-.*\.zip' | awk -F'bedrock-server-' '{print $2}' | awk -F'.zip' '{print $1}')

BRANCH=$(git branch -a | grep "${VERSION}")
if [ $? -ne 0 ]
then
	echo Version=${VERSION}
	git checkout -b $VERSION
	git config --local user.email "action@github.com"
	git config --local user.name "GitHub Action"

	sed -i "s#VERSION=\"latest\"#VERSION=\"${VERSION}\"#" Dockerfile

	git commit -a -m "$VERSION"

	git push --set-upstream origin $VERSION
fi
