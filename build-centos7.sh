#!/bin/bash

docker build -t centos7-clang-builder docker -f docker/centos7.dockerfile

LLVM_VERSION=15.0.3
LLVM_VERSION_MAJOR=${LLVM_VERSION%%.*}
SRC=$PWD/llvm-project-$LLVM_VERSION
PREFIX=/opt/llvm-$LLVM_VERSION_MAJOR
PACKAGE_NAME=llvm$LLVM_VERSION_MAJOR

mkdir -p {cache,output}/centos7

docker run -i --rm \
  -v $PWD:/data:ro \
  -v $SRC:/src:ro \
  -v $PWD/cache/centos7:/cache \
  -v $PWD/output/centos7:/output \
  centos7-clang-builder bash \
  -s - << EOF
source /opt/rh/devtoolset-11/enable
set -e
mkdir /build
cd /build
cmake3 -S /src/llvm -B /build \
  -G Ninja \
  -C /data/cmake/centos7.cmake \
  -DLLVM_PARALLEL_COMPILE_JOBS=4 \
  -DLLVM_PARALLEL_LINK_JOBS=3 \
  -DCMAKE_INSTALL_PREFIX=$PREFIX
DESTDIR=/build/root cmake3 --build /build --target install -j4
rpmbuild -bb /data/llvm$LLVM_VERSION_MAJOR.spec --define "_sourcedir /build/root" --define "_rpmfilename $PACKAGE_NAME-%%{VERSION}-%%{RELEASE}.rpm" --verbose
rpm -ivh /root/rpmbuild/RPMS/*.rpm
cd /tmp
$PREFIX/bin/clang++ -std=c++2b -fopenmp /data/test.cpp
/tmp/a.out
mv /root/rpmbuild/RPMS/*.rpm /output/
EOF
