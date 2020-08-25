#!/bin/bash

if [[ -z $0 ]]
then
  echo "[INFO] Usage: $0"
  exit 1
fi

if [[ -z "${IMAGE_VERSION_LOCATOR}" ]]; then
  echo "[ERROR] IMAGE_VERSION_LOCATOR environment variable not set. Exiting."
  exit 1
fi

if [[ -z "${NEW_IMAGE_TAG}" ]]; then
  echo "[ERROR] NEW_IMAGE_TAG environment variable not set. Exiting."
  exit 1
fi

if [[ -z "${VERSION_FILE}" ]]; then
  echo "[ERROR] VERSION_FILE environment variable not set. Exiting."
  exit 1
fi

