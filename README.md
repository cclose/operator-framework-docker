# operator-framework-docker
Docker image that includes the operator-sdk and all dependencies to run in a docker container

Pushed to https://hub.docker.com/repository/docker/cclose/operator-framework

# Usage

Simply pull from Docker Hub:

`docker pull cclose/operator-framework:latest`

It is suggested to use this as a development environment to isolate your
local system from the dependencies for running operator-sdk. Assuming you're 
in the root of a repo for an operator you wish to write, a good invocation 
is:

`docker run -ti --rm -v "$(pwd):/go/src" -w /go/src cclose/operator-framework:latest -- bash`

This will mount your current directory to /go/src and boot you into bash. From there, you
can use the operator-sdk as normal:

`bash /go/src: operator-sdk init --domain example.com --repo github.com/example/my-operator`

# Tags

The Tags of this Docker image are tied to the versions of Operator-SDK. If you want version
1.32 of operator-sdk, then pull `cclose/operator-framework:v1.32`

Latest will be... the latest. I don't really recommend using latest though.
