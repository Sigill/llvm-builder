FROM registry.suse.com/suse/sle15:15.3

RUN zypper -n install -y --no-recommends git cmake ninja ccache
RUN zypper -n install -y --no-recommends gcc11 gcc11-c++
RUN zypper -n install -y --no-recommends zlib-devel libelf-devel libedit0 libedit-devel ncurses-devel zlib-devel swig libxml2 libxml2-devel mpfr-devel
RUN zypper -n install -y --no-recommends rpm-build

RUN curl -L https://github.com/Kitware/CMake/releases/download/v3.27.7/cmake-3.27.7-linux-x86_64.tar.gz | tar -C /opt -xz
ENV PATH="/opt/cmake-3.27.7-linux-x86_64/bin:${PATH}"
