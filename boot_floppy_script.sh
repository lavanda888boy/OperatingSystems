#!/bin/bash

binary_file="$1"
bootloader="$2"

# Check if the binary file exists
if [ ! -f "$binary_file" ]; then
    echo "Error: Binary file '$binary_file' does not exist."
    exit 1
fi

# Create an empty floppy disk image (1.44MB size)
floppy_image="floppy.img"
dd if=/dev/zero of="$floppy_image" bs=512 count=2880

nasm -f bin $bootloader -o bootloader.bin
cat bootloader.bin $binary_file > temp.img

dd if=temp.img of="$floppy_image" conv=notrunc

echo "Binary file '$binary_file' successfully added to floppy image '$floppy_image'."

