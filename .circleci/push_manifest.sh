#!/bin/bash
set -euf -o pipefail

echo "Downloading manifest-tool."
MT_VERSION=$(curl https://api.github.com/repos/estesp/manifest-tool/releases/latest | jq '.tag_name' -r)
curl -O -sL https://github.com/estesp/manifest-tool/releases/download/${MT_VERSION}/manifest-tool-linux-amd64
mv manifest-tool-linux-amd64 /usr/bin/manifest-tool
chmod +x /usr/bin/manifest-tool
manifest-tool --version

echo $DOCKERHUB_PASS | docker login -u $DOCKERHUB_USER --password-stdin
manifest-tool push from-args \
  --platforms linux/amd64,linux/arm64,linux/arm \
  --template "$REGISTRY/$IMAGE:$VERSION-ARCH" \
  --target "$REGISTRY/$IMAGE:$VERSION"
if [ "${CIRCLE_BRANCH}" == 'master' ]; then
  manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64,linux/arm \
    --template "$REGISTRY/$IMAGE:$VERSION-ARCH" \
    --target "$REGISTRY/$IMAGE:latest"
fi

manifest-tool inspect "$REGISTRY/$IMAGE:$VERSION"
