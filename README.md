# Latest Clang

Scripts to build recent versions of Clang for various Linux distributions.

## Debian/Ubuntu

Pre-build packages are available here: <https://apt.llvm.org/>.

## SLES15.x/CentOS7

```sh
git clone --depth 1 -b llvmorg-x.y.z --single-branch https://github.com/llvm/llvm-project.git llvm-project-x.y.z

./build-containerized.sh --env sles15.3|sles15.4|centos7 --source llvm-project-x.y.z -v x.y.z -j N
```

## License

The content of this repository is released under the terms of the BSD Zero Clause License. See the LICENSE.txt file for more details.
