FROM registry.suse.com/suse/sle15:15.5
# FROM registry.suse.com/bci/bci-base:15.5

RUN zypper -n install -y --no-recommends git cmake ninja ccache
RUN zypper -n install -y --no-recommends gcc12 gcc12-c++
RUN zypper -n install -y --no-recommends zlib-devel libelf-devel libedit0 libedit-devel ncurses-devel zlib-devel swig libxml2 libxml2-devel mpfr-devel
RUN zypper -n install -y --no-recommends rpm-build
