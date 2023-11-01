FROM registry.suse.com/suse/sle15:15.4

RUN zypper -n install -y --no-recommends git cmake ninja ccache
RUN zypper -n install -y --no-recommends gcc11 gcc11-c++
RUN zypper -n install -y --no-recommends zlib-devel libelf-devel libedit0 libedit-devel ncurses-devel zlib-devel swig libxml2 libxml2-devel mpfr-devel
RUN zypper -n install -y --no-recommends rpm-build
