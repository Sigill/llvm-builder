#!/bin/bash

docker build -t sles-15.3-clang-builder docker -f docker/sles15.3.dockerfile

LLVM_VERSION=15.0.3
LLVM_VERSION_MAJOR=${LLVM_VERSION%%.*}
SRC=$PWD/llvm-project-$LLVM_VERSION
PREFIX=/opt/llvm-$LLVM_VERSION_MAJOR
PACKAGE_NAME=llvm$LLVM_VERSION_MAJOR

mkdir -p {cache,output}/sles15.3

docker run -i --rm \
    -v $PWD:/data:ro \
    -v $SRC:/src:ro \
    -v $PWD/cache/sles15.3:/cache \
    -v $PWD/output/sles15.3:/output \
    sles-15.3-clang-builder bash \
    -s - << EOF
set -e
mkdir /build
cmake -S /src/llvm -B /build \
    -G Ninja \
    -C /data/cmake/sles15.x.cmake \
    -DLLVM_PARALLEL_COMPILE_JOBS=4 \
    -DLLVM_PARALLEL_LINK_JOBS=3 \
    -DCMAKE_INSTALL_PREFIX=$PREFIX
DESTDIR=/build/root cmake --build /build --target install -j4
env -C /build rpmbuild -bb /data/llvm$LLVM_VERSION_MAJOR.spec --define "_sourcedir /build/root" --define "_rpmfilename $PACKAGE_NAME-%%{VERSION}-%%{RELEASE}.rpm" --verbose
rpm -ivh /usr/src/packages/RPMS/*.rpm
env -C /tmp $PREFIX/bin/clang++ -std=c++2b -fopenmp /data/test.cpp
/tmp/a.out
mv /usr/src/packages/RPMS/*.rpm /output/
EOF
