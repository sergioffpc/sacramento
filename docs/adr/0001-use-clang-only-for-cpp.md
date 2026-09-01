# Use Clang as the only C++ compiler

Status: Accepted

Sacramento uses clang-cl on Windows and Clang on Debian for development,
verification, release, and acceptance. The project deliberately does not build
with MSVC `cl.exe` or GCC/G++: compiler diversity would add CI and maintenance
cost and constrain the usable C++23 subset without producing a product artefact
the project wants. The complete platform toolchains remain different where the
targets require it—Windows uses MSVC STL/CRT, the Windows SDK, and `link.exe`,
while Debian uses libstdc++ and binutils—and every admitted C++23 feature must
pass on both real Clang platform profiles.
