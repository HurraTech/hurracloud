#!/bin/bash
gsutil -o GSUtil:parallel_composite_upload_threshold=150M cp tmp/deploy/images/raspberrypi4-64/core-image-base-raspberrypi4-64.rpi-sdimg  gs://hurrabuild-build/
gsutil -o GSUtil:parallel_composite_upload_threshold=150M cp tmp/deploy/images/raspberrypi4-64/core-image-base-raspberrypi4-64.sdimg  gs://hurrabuild-build/
gsutil -o GSUtil:parallel_composite_upload_threshold=150M cp tmp/deploy/images/raspberrypi4-64/core-image-base-raspberrypi4-64.mender  gs://hurrabuild-build/
gsutil -o GSUtil:parallel_composite_upload_threshold=150M cp tmp/deploy/images/raspberrypi4-64/core-image-base-raspberrypi4-64.sdimg.bmap  gs://hurrabuild-build/

gsutil -m acl set -R -a public-read gs://hurrabuild-build/core-image-base-raspberrypi4-64.mender
echo
echo
echo "-------"

echo "https://storage.googleapis.com/hurrabuild-build/core-image-base-raspberrypi4-64.mender"
