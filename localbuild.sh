#!/usr/bin/env bash
#
# Keep this in sync with cloudbuild.yaml, and .github/workflows/build.yml
#
_IMAGE_NAME="ekgf/gcloud-gradle"
_IMAGE_VERSION="latest"

_MANUALLY_INCREMENTED_IMAGE_VERSION="0.0.4"

docker build . \
  --iidfile=image.id \
  "--tag=${_IMAGE_NAME}:${_IMAGE_VERSION}" \
  "--tag=${_IMAGE_NAME}:${_MANUALLY_INCREMENTED_IMAGE_VERSION}"
exit $?
