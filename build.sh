#!/bin/bash
set -e

if [[ $# -eq 0  ]]
then
	BUILD_ARCH=AARCH64
elif [[ $# -eq 1  ]]
then
	BUILD_ARCH=$1
fi

case $BUILD_ARCH in
	ARM)
		export GCC5_ARM_PREFIX=arm-linux-gnueabi-
		export CROSS_COMPILE_32=arm-linux-gnueabi-
		BOOT_IMAGE_NAME=BOOTARM.efi;;
	AARCH64)
		export GCC5_AARCH64_PREFIX=aarch64-linux-gnu-
		export CROSS_COMPILE_64=aarch64-linux-gnu-
		BOOT_IMAGE_NAME=BOOTAA64.efi;;
	*)
		echo  "Usage: build.sh [ARM|AARCH64]"
		exit
esac

# clear all positional parameters
set --

export EDK_TOOLS_PATH=
export CONF_PATH=
export WORKSPACE=$PWD
export PACKAGES_PATH=$WORKSPACE/edk2

source ./edk2/edksetup.sh

getconf _NPROCESSORS_ONLN
NUM_CPUS=$((`getconf _NPROCESSORS_ONLN` + 2))

make -C edk2/BaseTools/

# Build the UEFI shell
build -n $NUM_CPUS -a $BUILD_ARCH -t GCC5 -p ShellPkg/ShellPkg.dsc -b RELEASE

# Build the SCT
./SctPkg/build.sh $BUILD_ARCH GCC RELEASE

# Assemble all the files that need to be in the zip file
mkdir -p ${BUILD_ARCH}_SCT/EFI/BOOT
cp Build/Shell/RELEASE_GCC5/$BUILD_ARCH/Shell_EA4BB293-2D7F-4456-A681-1F22F42CD0BC.efi ${BUILD_ARCH}_SCT/EFI/BOOT/$BOOT_IMAGE_NAME

mkdir -p ${BUILD_ARCH}_SCT/SCT
cp -r Build/UefiSct/RELEASE_GCC5/SctPackage${BUILD_ARCH}/$BUILD_ARCH/* ${BUILD_ARCH}_SCT/SCT/
cp Build/UefiSct/RELEASE_GCC5/SctPackage${BUILD_ARCH}/SctStartup.nsh ${BUILD_ARCH}_SCT/Startup.nsh

# Copy the SCT Parser tool into the repo
mkdir -p ${BUILD_ARCH}_SCT/sequence
cp sct_parser/* ${BUILD_ARCH}_SCT/sequence/

# Put some version information into the ESP directory
cat > ./${BUILD_ARCH}_SCT/versions.txt << EOF
EDK2_VER=`git -C ./edk2 describe`
EDK2_TEST_VER=`git -C ./edk2-test describe`
BUILD_DATE="`date`"
EOF

# Zip up the test folder
cd ${BUILD_ARCH}_SCT
zip -r ../edk2-test-${BUILD_ARCH,,}.zip *
cd ..

