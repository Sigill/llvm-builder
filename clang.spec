Name: %{_name}
Version: %{_version}
Release: %{_release}
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
DESTDIR="%{buildroot}" cmake --build "%{_sourcedir}" --target install


%files
%defattr(-,root,root,-)
%{_prefix}
