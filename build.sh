#!/bin/bash
set -e

# Build the SCT
export CROSS_COMPILE=aarch64-linux-gnu-
./SctPkg/build.sh AARCH64 GCC RELEASE

# Build the UEFI shell
export GCC5_AARCH64_PREFIX=aarch64-linux-gnu-
cd edk2
source ./edksetup.sh
make -C BaseTools/
build -a AARCH64 -t GCC5 -p ShellPkg/ShellPkg.dsc -b RELEASE
cd ..
unset GCC5_AARCH64_PREFIX

# Put some version information into the build directory
cat > ./Build/UefiSct/RELEASE_GCC5/SctPackageAARCH64/AARCH64/versions.txt << EOF
EDK2_VER=`git -C ./edk2 describe`
EDK2_TEST_VER=`git -C ./edk2-test describe`
EOF

# Zip up the image
zip -r edk2-test-aarch64.zip Build/UefiSct/RELEASE_GCC5/SctPackageAARCH64/AARCH64 edk2/Build/Shell/RELEASE_GCC5/AARCH64/*.efi
