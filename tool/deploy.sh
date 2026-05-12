#!/bin/bash

VERSION=$1
FLAG=$2

if [ -z "$VERSION" ]; then
  echo "ErrorYou must provide a version."
  echo "Usage: ./deploy v0.0.2 [--replace]"
  exit 1
fi

TAG_EXISTS=$(git tag -l "$VERSION")

if [ -n "$TAG_EXISTS" ]; then
  if [ "$FLAG" != "--replace" ]; then
    echo "Error: The tag '$VERSION' already exists!"
    echo "If you want to overwrite it, run: ./tool/deploy $VERSION --replace"
    exit 1
  else
    echo "Replace flag detected. Nuking old '$VERSION' tag..."
    git tag -d "$VERSION"
    
    git push origin --delete "$VERSION" 2>/dev/null
    echo "Old tag cleared."
  fi
fi

echo "🏷️  Stamping new tag: $VERSION"
git tag "$VERSION"

echo "🚀 Pushing code to main..."
git push origin main

echo "🚀 Pushing tag to remote..."
git push origin "$VERSION"

echo "✨ Deployment of $VERSION complete!"