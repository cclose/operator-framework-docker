ARG GO_VERSION=1.21.9
ARG GO_OS=bookworm

FROM golang:$GO_VERSION-$GO_OS

ARG OPERATOR_SDK_VERSION=v1.34.1

COPY install-operator-sdk.sh .
RUN apt-get update && apt-get -y install build-essential ca-certificates curl gnupg lsb-release apt-transport-https  \
     # install operator SDK (i fix syntax highlighting in gVim ->) \
     && bash install-operator-sdk.sh $OPERATOR_SDK_VERSION \
     && curl -L -o kubebuilder https://go.kubebuilder.io/dl/latest/linux/amd64 \
     && chmod +x kubebuilder && mv kubebuilder /usr/local/bin/

