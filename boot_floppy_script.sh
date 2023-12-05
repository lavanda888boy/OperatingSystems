#!/bin/bash

binary_file="$1"
bootloader="$2"

# Check if the binary file exists
if [ ! -f "$binary_file" ]; then
    echo "Error: Binary file '$binary_file' does not exist."
    exit 1
fi

nasm -f bin $bootloader -o bootloader.bin

# Create an empty floppy disk image (1.44MB size)
floppy_image="floppy.img"
truncate -s 1474560 bootloader.bin
mv bootloader.bin $floppy_image

dd if="$binary_file" of="$floppy_image" bs=512 seek=2 conv=notrunc

echo "Binary file '$binary_file' successfully added to floppy image '$floppy_image'."

