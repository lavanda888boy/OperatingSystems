org 7c00h

section .text
    jmp main

    ; pad the bootloader to 510 bytes with zeros
    times 510 - ($ - $$) db 0

    ; boot signature (55 AA)
    dw 0xAA55

main:
    ; load the NASM script into memory
    mov ah, 0x02
    mov al, 0x0F
    mov ch, 0x00    
    mov dh, 0x00
    mov dl, 0x00 
    mov bx, 0x1000
    int 0x13

    ; jump to the loaded NASM script
    jmp 0x1000:0000