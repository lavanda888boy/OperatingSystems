org 7c00h

section .data
    delimiter dd "@@@FAF-213 Sevastian BAJENOV###"
    delimiter_count equ 10
    
    first_sector equ 13
    first_track equ 21

    last_sector equ 6
    last_track equ 23

section .bss
    buffer resb 512

section .text
    global _start


_start:
    mov ecx, 0
    mov esi, 0

    jmp write_start_delimiter


write_start_delimiter:
    ; set the floppy mode to write
    mov ah, 03h
    mov al, 1

    ; set the address of the first sector to write
    mov ch, first_track         
    mov dh, 1        
    mov cl, first_sector

    mov bx, delimiter

    ; set the disk type to floppy
    mov dl, 0
    int 13h


write_end_delimiter:
    ; set the floppy mode to write
    mov ah, 03h
    mov al, 1

    ; set the address of the first sector to write
    mov ch, last_track         
    mov dh, 1        
    mov cl, last_sector

    mov bx, delimiter

    ; set the disk type to floppy
    mov dl, 0
    int 13h
