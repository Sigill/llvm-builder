#!/bin/bash
set -e

WORKSPACE=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
source $WORKSPACE/utils.sh

BLD=
OUT=
VERSION=
TESTINSTALL=

function usage() {
  echo "$0 --build <build dir> -v|--version <version> [--output <output directory>] [--test-install]"
}

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
    --test-install)
      TESTINSTALL=YES
      shift
      ;;
    *)
      >&2 echo "Unknown argument $1"
      exit 1
      ;;
  esac
done

require_arg "$BLD" "Build directory"
require_arg "$VERSION" "Version"

VERSION_MAJOR=${VERSION%%.*}
PREFIX=/opt/clang-$VERSION_MAJOR
PACKAGE_NAME=clang$VERSION_MAJOR

# We should be able to replace _sourcedir by buildroot and not do anything during %install, but on some distributions (eg: centos7), rpmbuild starts by removing buildroot.
run rpmbuild -bb "$WORKSPACE/clang.spec" \
  --define "_binary_payload w4.gzdio" \
  --define "_rpmfilename %%{NAME}-%%{VERSION}-%%{RELEASE}.%%{ARCH}.rpm" \
  --define "_rpmdir /tmp/RPMS" \
  --define "_sourcedir $BLD" \
  --define "_name $PACKAGE_NAME" \
  --define "_prefix $PREFIX" \
  --define "_version $VERSION" \
  --define "_release 1" \
  --verbose

if [ "$TESTINSTALL" = YES ]; then
  rpm -ivh /tmp/RPMS/*.rpm
  # Use libc++ to benefit from features not yet in libstdc++ (e.g. std::expected).
  "$PREFIX/bin/clang++" -std=c++23 -stdlib=libc++ -fopenmp "$WORKSPACE/test.cpp" -o /tmp/a.out
  LD_LIBRARY_PATH=$PREFIX/lib/$($PREFIX/bin/clang -dumpmachine)/:$PREFIX/lib:$LD_LIBRARY_PATH /tmp/a.out
  mv /tmp/RPMS/*.rpm "$OUT"
fi

if [ -n "$OUT" ]; then
  mv /tmp/RPMS/*.rpm "$OUT"
fi
