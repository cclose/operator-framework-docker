#!/bin/bash

OPERATOR_SDK_VERSION=${1:-"v1.34.1"}
ARCH=$(case $(uname -m) in x86_64) echo -n amd64 ;; aarch64) echo -n arm64 ;; *) echo -n $(uname -m) ;; esac)
OS=$(uname | awk '{print tolower($0)}') 
OPERATOR_SDK_DL_URL=https://github.com/operator-framework/operator-sdk/releases/download/$OPERATOR_SDK_VERSION 

echo "Pulling $OPERATOR_SDK_DL_URL"
OPERATOR_SDK_FILE_URL="${OPERATOR_SDK_DL_URL}/operator-sdk_${OS}_${ARCH}"
echo " - Downloading $OPERATOR_SDK_FILE_URL"

curl -LO $OPERATOR_SDK_FILE_URL
chmod +x operator-sdk_${OS}_${ARCH} 
mv operator-sdk_${OS}_${ARCH} /usr/local/bin/operator-sdk
