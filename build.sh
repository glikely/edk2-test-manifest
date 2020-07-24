#!/bin/bash
set -e

export EDK_TOOLS_PATH=
export CONF_PATH=
export WORKSPACE=$PWD
export PACKAGES_PATH=$WORKSPACE/edk2
export GCC5_AARCH64_PREFIX=aarch64-linux-gnu-
export CROSS_COMPILE=aarch64-linux-gnu-

source ./edk2/edksetup.sh

getconf _NPROCESSORS_ONLN
NUM_CPUS=$((`getconf _NPROCESSORS_ONLN` + 2))

# Build the UEFI shell
make -C edk2/BaseTools/
build -n $NUM_CPUS -a AARCH64 -t GCC5 -p ShellPkg/ShellPkg.dsc -b RELEASE

# Build the SCT
./SctPkg/build.sh AARCH64 GCC RELEASE

# Assemble all the files that need to be in the zip file
mkdir -p TEST_ESP/EFI/BOOT
cp Build/Shell/RELEASE_GCC5/AARCH64/Shell_EA4BB293-2D7F-4456-A681-1F22F42CD0BC.efi TEST_ESP/EFI/BOOT/BOOTAA64.efi
cp Build/Shell/RELEASE_GCC5/AARCH64/Shell_EA4BB293-2D7F-4456-A681-1F22F42CD0BC.efi TEST_ESP/Shell.efi
mkdir -p TEST_ESP/SCT
cp -r Build/UefiSct/RELEASE_GCC5/SctPackageAARCH64/AARCH64/* TEST_ESP/SCT/
cp scripts/SctStartup.nsh TEST_ESP/

# Put some version information into the ESP directory
cat > ./Build/UefiSct/RELEASE_GCC5/SctPackageAARCH64/AARCH64/versions.txt << EOF
EDK2_VER=`git -C ./edk2 describe`
EDK2_TEST_VER=`git -C ./edk2-test describe`
BUILD_DATE="`date`"
EOF

# Zip up the test folder
cd TEST_ESP
zip -r ../edk2-test-aarch64.zip *
