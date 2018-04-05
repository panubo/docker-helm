#!/usr/bin/env bash

mkdir -p "${HOME}/.aws"
echo -e "[default]\nregion=us-east-2\n" > ${HOME}/.aws/config

helm init -c

helm plugin install /opt/helm-s3

exec "${@}"
