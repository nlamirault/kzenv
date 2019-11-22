#!/usr/bin/env bash

check_version() {
  v="${1}"
  [ -n "$(kustomize version | grep -E ${v})" ]
}

cleanup() {
  rm -rf ./versions
  rm -rf ./.kustomize-version
  rm -rf ./min_required.tf
}