#!/bin/bash

VERSION=$(curl -v -L --silent  https://www.minecraft.net/en-us/download/server/bedrock/ 2>&1 | grep 'https://minecraft.azureedge.net/bin-linux/bedrock-server-.*\.zip' | awk -F'bedrock-server-' '{print $2}' | awk -F'.zip' '{print $1}')

BRANCH=$(git branch -a | grep "${VERSION}")
if [ $? -ne 0 ]
then
	echo ${VERSION}
	git checkout master;git checkout -b $VERSION > /dev/null 2>&1

	sed -i "s#VERSION=\"latest\"#VERSION=\"${VERSION}\"#" Dockerfile > /dev/null 2>&1

	git commit -a -m "$VERSION" > /dev/null 2>&1
fi
