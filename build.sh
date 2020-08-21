#!/bin/bash
set -e

export EDK_TOOLS_PATH=
export CONF_PATH=
export WORKSPACE=$PWD
export PACKAGES_PATH=$WORKSPACE/edk2

source ./edk2/edksetup.sh

getconf _NPROCESSORS_ONLN
NUM_CPUS=$((`getconf _NPROCESSORS_ONLN` + 2))

make -C edk2/BaseTools/

###########
# AARCH64

export GCC5_AARCH64_PREFIX=aarch64-linux-gnu-

# Build the UEFI shell
build -n $NUM_CPUS -a AARCH64 -t GCC5 -p ShellPkg/ShellPkg.dsc -b RELEASE

# Build the SCT
./SctPkg/build.sh AARCH64 GCC RELEASE

# Assemble all the files that need to be in the zip file
mkdir -p AARCH64_SCT/EFI/BOOT
cp Build/Shell/RELEASE_GCC5/AARCH64/Shell_EA4BB293-2D7F-4456-A681-1F22F42CD0BC.efi AARCH64_SCT/EFI/BOOT/BOOTAA64.efi

mkdir -p AARCH64_SCT/SCT
cp -r Build/UefiSct/RELEASE_GCC5/SctPackageAARCH64/AARCH64/* AARCH64_SCT/SCT/
cp Build/UefiSct/RELEASE_GCC5/SctPackageAARCH64/SctStartup.nsh AARCH64_SCT/Startup.nsh

# Put some version information into the ESP directory
cat > ./AARCH64_SCT/versions.txt << EOF
EDK2_VER=`git -C ./edk2 describe`
EDK2_TEST_VER=`git -C ./edk2-test describe`
BUILD_DATE="`date`"
EOF

# Zip up the test folder
cd AARCH64_SCT
zip -r ../edk2-test-aarch64.zip *
cd ..

###########
# ARM

export GCC5_ARM_PREFIX=arm-linux-gnueabi-

# Build the UEFI shell
build -n $NUM_CPUS -a ARM -t GCC5 -p ShellPkg/ShellPkg.dsc -b RELEASE

# Build the SCT
./SctPkg/build.sh ARM GCC RELEASE

# Assemble all the files that need to be in the zip file
mkdir -p ARM_SCT/EFI/BOOT
cp Build/Shell/RELEASE_GCC5/ARM/Shell_EA4BB293-2D7F-4456-A681-1F22F42CD0BC.efi ARM_SCT/EFI/BOOT/BOOTARM.efi

mkdir -p ARM_SCT/SCT
cp -r Build/UefiSct/RELEASE_GCC5/SctPackageARM/ARM/* ARM_SCT/SCT/
cp Build/UefiSct/RELEASE_GCC5/SctPackageARM/SctStartup.nsh ARM_SCT/Startup.nsh

# Put some version information into the ESP directory
cat > ./ARM_SCT/versions.txt << EOF
EDK2_VER=`git -C ./edk2 describe`
EDK2_TEST_VER=`git -C ./edk2-test describe`
BUILD_DATE="`date`"
EOF

# Zip up the test folder
cd ARM_SCT
zip -r ../edk2-test-arm.zip *
cd ..

