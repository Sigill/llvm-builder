#!/bin/bash
set -e

WORKSPACE=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
source $WORKSPACE/utils.sh

SRC=
BLD=
CACHE=
VERSION=
CC=
CXX=
J=
K=
L=

function usage() {
  echo "$0 --source <source-dir> --build <build-dir> --cache <cache dir> -v|--version <version> [--cc <c compiler>] [--cxx <cxx compiler>] [-j <number>] [-k <number>] [-l <number>]"
}

while [[ $# -gt 0 ]]; do
  case $1 in
    --source)
      SRC="$2"
      shift 2
      ;;
    --build)
      BLD="$2"
      shift 2
      ;;
    --cache)
      CACHE="$2"
      shift 2
      ;;
    -v|--version)
      VERSION="$2"
      shift 2
      ;;
    --cc)
      CC="$2"
      shift 2
      ;;
    --cxx)
      CXX="$2"
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
    -h|--help)
      usage
      exit 0
      ;;
    *)
      >&2 echo "Unknown argument $1"
      >&2 usage
      exit 1
      ;;
  esac
done

require_arg "$SRC" "Source directory"
require_arg "$BLD" "Build directory"
require_arg "$CACHE" "Cache directory"
require_arg "$VERSION" "Version"

VERSION_MAJOR=${VERSION%%.*}
PREFIX=/opt/clang-$VERSION_MAJOR

mkdir -p "$BLD"
run cmake -S "$SRC/llvm" -B "$BLD" \
  -G Ninja \
  -DCMAKE_C_COMPILER=${CC:-gcc} \
  -DCMAKE_CXX_COMPILER=${CXX:-g++} \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=ON \
  -DLLVM_CCACHE_BUILD=ON \
  -DLLVM_CCACHE_DIR="$CACHE/ccache" \
  -DLLVM_TARGETS_TO_BUILD=Native \
  -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra" \
  -DLLVM_ENABLE_RUNTIMES=openmp \
  -DLLVM_INCLUDE_TESTS=OFF \
  -DLLVM_INCLUDE_BENCHMARKS=OFF \
  -DLLVM_INCLUDE_EXAMPLES=OFF \
  -DLLVM_PARALLEL_COMPILE_JOBS=${K:-$(nproc)} \
  -DLLVM_PARALLEL_LINK_JOBS=${L:-$(nproc)} \
  -DCMAKE_INSTALL_PREFIX="$PREFIX"

cmake --build "$BLD" -j ${J:-$(nproc)}
