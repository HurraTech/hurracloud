#!/bin/bash
gsutil -o GSUtil:parallel_composite_upload_threshold=150M cp gs://hurrabuild-build/core-image-* ./

