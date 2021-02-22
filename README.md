# EDK2 SCT Build Environment

git-repo Manifest for building the UEFI Self Certification Test (SCT) suite
from mainline edk2 and edk2-test for AARCH64 and ARM.
Use this to build a zip file containing the EDK2 shell and the SCT that
can be unzipped onto a USB drive.

## Usage

```bash
mkdir edk2-test-build
cd edk2-test-build
repo init -u https://github.com/glikely/edk2-test-manifest
repo sync
./buildzip.sh AARCH64
```

Both 64-bit (AARCH64) and 32-bit (ARM) Arm builds are supported.
To perform a 32-bit build, pass the parameter "ARM" to buildzip.sh.
```bash
./buildzip.sh ARM
```
A zip file will be created containing the SCT which can be unzipped onto a
flash drive.

## Ccache

On a system where a ccache lib dir with symlinks exists, you can reuse
compilation results between builds by prepending the ccache lib dir to your
$PATH.
```bash
export PATH="/usr/lib/ccache:$PATH"
./build.sh
```

## TODO

* Add support for other architectures
