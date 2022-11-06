FROM centos:7

RUN yum install -y centos-release-scl epel-release \
  && yum update -y
RUN yum install -y \
  devtoolset-11-gcc-c++ \
  ninja-build \
  ccache \
  cmake3 \
  python3 \
  rpm-build \
  zlib-devel \
  elfutils-libelf-devel \
  libedit-devel \
  ncurses-devel \
  swig \
  libxml2-devel \
  mpfr-devel \
  perl-Data-Dumper-Concise

RUN ln -sn /usr/bin/cmake3 /usr/bin/cmake
