#!/bin/bash

if [[ "${1}" != "skip" ]] ; then
	git clean -fdx
	./build_kernel.sh "$@" || exit 1
fi

VERSION="r20a3-$(date +%F | sed s@-@@g)"

if [ -e boot.img ] ; then
	rm arter97-kernel-$VERSION.zip 2>/dev/null
	cp boot.img arter97-kernel-$VERSION.img

	# Pack AnyKernel3
	rm -rf kernelzip
	mkdir kernelzip
	echo "
kernel.string=arter97 kernel r20a1 @ xda-developers
do.devicecheck=0
do.modules=0
do.cleanup=1
do.cleanuponabort=0
block=/dev/block/bootdevice/by-name/boot
is_slot_device=1
ramdisk_compression=gzip
" > kernelzip/props
	cp -rp ~/android/anykernel/* kernelzip/
	find . -name '*.dtb' -exec cat {} + > kernelzip/dtb
	cp arch/arm64/boot/dtbo.img kernelzip/
	touch kernelzip/vendor_boot
	cd kernelzip/
	7z a -mx9 arter97-kernel-$VERSION-tmp.zip *
	7z a -mx0 arter97-kernel-$VERSION-tmp.zip ../arch/arm64/boot/Image.gz
	zipalign -v 4 arter97-kernel-$VERSION-tmp.zip ../arter97-kernel-$VERSION.zip
	rm arter97-kernel-$VERSION-tmp.zip
	cd ..
	ls -al arter97-kernel-$VERSION.zip
fi
