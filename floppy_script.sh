#!/bin/bash

# Check if the path to the binary file is provided as an argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <path_to_binary_file>"
    exit 1
fi

# Path to the binary file passed as an argument
binary_file="$1"

# Check if the binary file exists
if [ ! -f "$binary_file" ]; then
    echo "Error: Binary file '$binary_file' does not exist."
    exit 1
fi

# Create an empty floppy disk image (1.44MB size)
floppy_image="floppy.img"
dd if=/dev/zero of="$floppy_image" bs=512 count=2880

# Write the binary file to the floppy image
dd if="$binary_file" of="$floppy_image" conv=notrunc

echo "Binary file '$binary_file' successfully added to floppy image '$floppy_image'."