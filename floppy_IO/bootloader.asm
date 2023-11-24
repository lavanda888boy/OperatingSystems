org 7c00h

mov ah, 0h
int 13h

mov ax, 0000h
mov es, ax
mov bx, 1000h

; load the NASM script into memory
mov ah, 02h
mov al, 3
mov ch, 0
mov cl, 2   
mov dh, 0
mov dl, 0 

int 13h

; jump to the loaded NASM script
jmp 0000h:1000h

; pad the bootloader to 510 bytes with zeros
times 510 - ($ - $$) db 0
dw 0AA55h