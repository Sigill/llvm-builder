#!/bin/bash
set -e

WORKSPACE=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
source $WORKSPACE/utils.sh

require_arg() {
  if [ -z "$1" ]; then
    >&2 echo "$2 not specified"
    exit 1
  fi
}

BLD=
OUT=
VERSION=

while [[ $# -gt 0 ]]; do
  case $1 in
    --build)
      BLD="$2"
      shift 2
      ;;
    --output)
      OUT="$2"
      shift 2
      ;;
    -v|--version)
      VERSION="$2"
      shift 2
      ;;
    *)
      >&2 echo "Unknown argument $1"
      exit 1
      ;;
  esac
done

require_arg "$BLD" "Build directory"
require_arg "$OUT" "Output directory"
require_arg "$VERSION" "Version"

VERSION_MAJOR=${VERSION%%.*}
PREFIX=/opt/clang-$VERSION_MAJOR
PACKAGE_NAME=clang$VERSION_MAJOR

# We should be able to replace _sourcedir by buildroot and not do anything during %install, but on centos7, rpmbuild starts by removing buildroot.
run rpmbuild -bb "$WORKSPACE/clang.spec" \
  --define "_binary_payload w4.gzdio" \
  --define "_rpmfilename %%{NAME}-%%{VERSION}-%%{RELEASE}.%%{ARCH}.rpm" \
  --define "_rpmdir /tmp/RPMS" \
  --define "_sourcedir $BLD/root" \
  --define "_name $PACKAGE_NAME" \
  --define "_prefix $PREFIX" \
  --define "_version $VERSION" \
  --define "_release 1" \
  --verbose

rpm -ivh /tmp/RPMS/*.rpm
"$PREFIX/bin/clang++" -std=c++2b -fopenmp "$WORKSPACE/test.cpp" -o /tmp/a.out
/tmp/a.out
mv /tmp/RPMS/*.rpm "$OUT"