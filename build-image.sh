#!/bin/bash

# Load dependencies
if [ ! -d "build/bash-utils" ] ; then
    mkdir -p "build/bash-utils"
fi
if [ ! -f "build/bash-utils/docker.sh" ] ; then
    curl -sSL https://raw.githubusercontent.com/cclose/bash-utils/main/docker.sh > build/bash-utils/docker.sh
fi
source "build/bash-utils/docker.sh"
if [ ! -f "build/bash-utils/github.sh" ] ; then
    curl -sSL https://raw.githubusercontent.com/cclose/bash-utils/main/github.sh > build/bash-utils/github.sh
fi
source "build/bash-utils/github.sh"

GO_OS="bookworm"

# This Image's settings
IMAGE_NAMESPACE="cclose"
IMAGE_NAME="operator-framework"
IMAGE_TAG="dev"

# Operator SDK Source
OPERATOR_SDK_OWNER="operator-framework"
OPERATOR_SDK_REPO_NAME="operator-sdk"
OPERATOR_SDK_REPO="${OPERATOR_SDK_OWNER}/${OPERATOR_SDK_REPO_NAME}"

# Detect our Docker executable
docker_executable=$(docker_get_executable)
echo "Docker executable: $docker_executable"

if [ ! -z "$1" ] ; then
    tag="$1"

    # Check if the string starts with "v"
    if [[ "$tag" != v* ]]; then
        # Prepend "v" to the string
        tag="v${tag}"
    fi

    if github_check_release "$OPERATOR_SDK_OWNER" "$OPERATOR_SDK_REPO_NAME" "$tag" ; then
        echo "Using release tag: $tag"
        OPERATOR_SDK_VERSION="$tag"
    else 
        echo "Operator-SDK version $tag does not exist"
        exit 1
    fi
fi

if [ -z "$OPERATOR_SDK_VERSION" ] ; then 
    # Get the latest release tag
    latest_release=$(github_get_latest_release "$OPERATOR_SDK_OWNER" "$OPERATOR_SDK_REPO_NAME")
    echo "Latest release tag: $latest_release"
    OPERATOR_SDK_VERSION="$latest_release"
fi

IMAGE_TAG="$OPERATOR_SDK_VERSION"

# Get the Go version for the latest release
GO_VERSION=$(github_get_repo_go_version "$OPERATOR_SDK_REPO" "$OPERATOR_SDK_VERSION")
echo "Go version for $OPERATOR_SDK_VERSION: $GO_VERSION"

$docker_executable build . -f Dockerfile \
  --build-arg "GO_OS=$GO_OS" \
  --build-arg "GO_VERSION=$GO_VERSION" \
  --build-arg "OPERATOR_SDK_VERSION=$OPERATOR_SDK_VERSION" \
  -t "$IMAGE_NAMESPACE/$IMAGE_NAME:$IMAGE_TAG"

# Extract major, minor, and patch versions from OPERATOR_SDK_VERSION
major=$(echo "$OPERATOR_SDK_VERSION" | cut -d '.' -f 1)
minor=$(echo "$OPERATOR_SDK_VERSION" | cut -d '.' -f 1-2)
# patch might overlap with full tag, but won't if there's a build
# e.g. v1.2.3 == v1.2.3, but v1.2.3-2g123fe == v1.2.3
patch=$(echo "$OPERATOR_SDK_VERSION" | cut -d '.' -f 1-3)

## Add tags
$docker_executable tag "$IMAGE_NAMESPACE/$IMAGE_NAME:$IMAGE_TAG" "$IMAGE_NAMESPACE/$IMAGE_NAME:$major"
$docker_executable tag "$IMAGE_NAMESPACE/$IMAGE_NAME:$IMAGE_TAG" "$IMAGE_NAMESPACE/$IMAGE_NAME:$minor"
$docker_executable tag "$IMAGE_NAMESPACE/$IMAGE_NAME:$IMAGE_TAG" "$IMAGE_NAMESPACE/$IMAGE_NAME:$patch"
$docker_executable tag "$IMAGE_NAMESPACE/$IMAGE_NAME:$IMAGE_TAG" "$IMAGE_NAMESPACE/$IMAGE_NAME:${patch}-${GO_OS}"

# Push tags
$docker_executable push "$IMAGE_NAMESPACE/$IMAGE_NAME:$major"
$docker_executable push "$IMAGE_NAMESPACE/$IMAGE_NAME:$minor"
$docker_executable push "$IMAGE_NAMESPACE/$IMAGE_NAME:$patch"
$docker_executable push "$IMAGE_NAMESPACE/$IMAGE_NAME:${patch}-${GO_OS}"

# Generate Release Notes
printf "Version %s:\n\nBundles version %s of operator-sdk, it's dependencies, and Go v%s" "$IMAGE_TAG" "$OPERATOR_SDK_VERSION" "$GO_VERSION" > build/.release_notes

#check for latest
if docker_is_latest_version "$IMAGE_NAMESPACE" "$IMAGE_NAME" "$patch"; then
    echo "Is latest release, so building and pushing Latest"
    $docker_executable tag "$IMAGE_NAMESPACE/$IMAGE_NAME:$IMAGE_TAG" "$IMAGE_NAMESPACE/$IMAGE_NAME:latest"
    $docker_executable push "$IMAGE_NAMESPACE/$IMAGE_NAME:latest"
fi

