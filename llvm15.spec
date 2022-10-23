%define name llvm15
%define version 0.3
%define release 1

%global __strip %{_sourcedir}/opt/llvm-15/bin/llvm-strip
%define _binary_payload w4.gzdio

Name: %{name}
Version: %{version}
Release: %{release}
Summary: The Low Level Virtual Machine
Group: Development/Libraries
License: BSD

%description
LLVM is a compiler infrastructure designed for compile-time,
link-time, runtime, and idle-time optimization of programs from
arbitrary programming languages.  The compiler infrastructure includes
mirror sets of programming tools as well as libraries with equivalent
functionality.


%install
mkdir -p %{buildroot}
cp -r %{_sourcedir}/opt %{buildroot}/


%files
%defattr(-,root,root,-)
/opt/llvm-15
%doc


%changelog
* Thu Oct 21 2022 <cyrille.faucheux@gmail.com>
- Release 15.0.3-1.
* Thu Sep 22 2022 <cyrille.faucheux@gmail.com>
- Release 15.0.1-1.
