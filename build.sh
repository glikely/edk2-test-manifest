#!/bin/sh

cd edk2
export CROSS_COMPILE=aarch64-linux-gnu-

./SctPkg/build.sh AARCH64 GCC
