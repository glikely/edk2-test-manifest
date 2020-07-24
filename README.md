git-repo Manifest for building the UEFI Self Certification Test (SCT) suite
from mainline edk2 and edk2-test for AARCH64

Usage
-----

 $ mkdir edk2-test-build
 $ cd edk2-test-build
 $ repo init -u https://github.com/glikely/edk2-test-manifest
 $ repo sync
 $ ./build.sh

A zip file will be created containing the SCT which can be unzipped onto a
flash drive
