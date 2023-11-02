org 7c00h

section .text
    global _start

_start:
    mov ax, 0xB800; address of the Video memory
    mov es, ax;          
    xor di, di; offset to write caracters to video memory pointer
    
    mov ax, 'A';
    stosb; write the character to the memory
    mov	ax, 0x03; text color
    stosb; write the attribute to the memory

    mov ax, 'B';
    stosb; write the character to the memory
    mov	ax, 0x04; text color
    stosb; write the attribute to the memory

    mov ax, 'C';
    stosb; write the character to the memory
    mov	ax, 0x05; text color
    stosb; write the attribute to the memory
