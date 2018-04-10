#!/usr/bin/env bash
# Update the Dockerfile to use the latest release and associated checksum

set -e

# Update Helm
echo "> Helm"
latest_url="https://api.github.com/repos/kubernetes/helm/releases/latest"
json="$(curl -sSf "${latest_url}")"
latest="$(echo "${json}" | jq -r .tag_name)"
echo ">> Version: ${latest#v}"
checksum="$(curl -sSfL https://storage.googleapis.com/kubernetes-helm/helm-v${latest#v}-linux-amd64.tar.gz.sha256)"
echo ">> Checksum: ${checksum}"
sed -i -E -e "s/HELM_VERSION=[0-9\\.]*/HELM_VERSION=${latest#v}/" -e "s/HELM_CHECKSUM=[0-9a-f]*/HELM_CHECKSUM=${checksum}/" Dockerfile

# Update Helm S3
echo "> Helm S3"
latest_url="https://api.github.com/repos/hypnoglow/helm-s3/releases/latest"
json="$(curl -sSf "${latest_url}")"
latest="$(echo "${json}" | jq -r .tag_name)"
echo ">> Version: ${latest#v}"
checksums_url="$(echo "${json}"  | jq -r '.assets[] | select(.browser_download_url | contains("checksums.txt")) | .browser_download_url')"
checksum="$(curl -sSfL "${checksums_url}" | sed -E -e '/linux_amd64.tar.gz/!d' -e 's/([0-9a-f]+) .*/\1/')"
echo ">> Version: ${latest#v}"
echo ">> Checksum: ${checksum}"
sed -i -E -e "s/HELM_S3_VERSION=[0-9\\.]*/HELM_S3_VERSION=${latest#v}/" -e "s/HELM_S3_CHECKSUM=[0-9a-f]*/HELM_S3_CHECKSUM=${checksum}/" Dockerfile

# Update Helm GCS
echo "> Helm GCS"
latest_url="https://api.github.com/repos/nouney/helm-gcs/releases/latest"
json="$(curl -sSf "${latest_url}")"
latest="$(echo "${json}" | jq -r .tag_name)"
echo ">> Version: ${latest#v}"
checksums_url="$(echo "${json}"  | jq -r '.assets[] | select(.browser_download_url | contains("checksums.txt")) | .browser_download_url')"
checksum="$(curl -sSfL "${checksums_url}" | sed -E -e '/Linux_x86_64.tar.gz/!d' -e 's/([0-9a-f]+) .*/\1/')"
echo ">> Checksum: ${checksum}"
sed -i -E -e "s/HELM_GCS_VERSION=[0-9\\.]*/HELM_GCS_VERSION=${latest#v}/" -e "s/HELM_GCS_CHECKSUM=[0-9a-f]*/HELM_GCS_CHECKSUM=${checksum}/" Dockerfile
