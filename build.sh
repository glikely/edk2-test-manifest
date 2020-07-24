#!/bin/sh

# Build the SCT
export CROSS_COMPILE=aarch64-linux-gnu-
./SctPkg/build.sh AARCH64 GCC RELEASE

# Put some version information into the build directory
cat > ./Build/UefiSct/RELEASE_GCC5/SctPackageAARCH64/AARCH64/versions.txt << EOF
EDK2_VER=`git -C ./edk2 describe`
EDK2_TEST_VER=`git -C ./edk2-test describe`
EOF

# Zip up the image
zip -r edk2-test-aarch64.zip Build/UefiSct/RELEASE_GCC5/SctPackageAARCH64/AARCH64
