#!/bin/bash
gsutil -o GSUtil:parallel_composite_upload_threshold=150M cp tmp/deploy/images/raspberrypi4-64/core-image-base-raspberrypi4-64.sdimg  gs://hurrabuild-build/
gsutil -o GSUtil:parallel_composite_upload_threshold=150M cp tmp/deploy/images/raspberrypi4-64/core-image-base-raspberrypi4-64.mender  gs://hurrabuild-build/
gsutil -o GSUtil:parallel_composite_upload_threshold=150M cp tmp/deploy/images/raspberrypi4-64/core-image-base-raspberrypi4-64*.bmap  gs://hurrabuild-build/
