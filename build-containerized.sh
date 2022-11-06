#!/bin/bash

WORKSPACE=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
source $WORKSPACE/utils.sh

ENV=
SRC=
VERSION=
J=
K=
L=

while [[ $# -gt 0 ]]; do
  case $1 in
    --env)
      ENV="$2"
      shift 2
      ;;
    --source)
      SRC="$2"
      shift 2
      ;;
    -v|--version)
      VERSION="$2"
      shift 2
      ;;
    -j)
      J="$2"
      shift 2
      ;;
    -k)
      K="$2"
      shift 2
      ;;
    -l)
      L="$2"
      shift 2
      ;;
    *)
      >&2 echo "Unknown argument $1"
      exit 1
      ;;
  esac
done

require_arg "$ENV" "Env"
require_arg "$SRC" "Source directory"
require_arg "$VERSION" "Version"

if [[ "$ENV" =~ ^sles ]]; then
  CC=gcc-11
  CXX=g++-11
fi

docker build -t $ENV-clang-builder docker -f docker/$ENV.dockerfile

mkdir -p {cache,output}/$ENV

./start-build-container.sh --source "$SRC" --env $ENV -- \
  -i --rm --workdir /data $ENV-clang-builder \
  bash << EOF
if [ "$ENV" = centos7 ]; then
  source /opt/rh/devtoolset-11/enable
fi

set -e

./build-local.sh \
  --source /src \
  --build /build \
  --cache /cache \
  --version $VERSION \
  ${CC:+--cc} $CC \
  ${CXX:+--cxx} $CXX \
  ${J:+-j} $J \
  ${K:+-k} $K \
  ${L:+-l} $L

./build-rpm.sh --build /build --output /output --version $VERSION
EOF
