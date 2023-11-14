org 7c00h

section .data
    delimiter dd "@@@FAF-213 Sevastian BAJENOV###"
    delimiter_length equ 42
    delimiter_count equ 10
    
    first_sector equ 13
    first_track equ 21

section .bss
    buffer resb 512

section .text
    global _start

_start:
    mov ecx, 0
    
    jmp write_buffer

write_buffer:
    ; Copy one character from original string to repeated string
    mov al, [original_string + esi]
    mov [repeated_string + ecx], al

    ; Increment indices
    inc esi
    inc ecx

    ; Check if we reached the end of the original string
    cmp byte [original_string + esi], 0
    jnz repeat_loop

    ; Check if we repeated the string ten times
    cmp ecx, repeat_count * 10
    je  end_program

    ; If not, reset index for the original string and repeat
    mov esi, 0
    jmp write_buffer

write_delimiters:
    ; set the floppy mode to write
    mov ah, 03h
    mov al, 1

    ; set the address of the first sector to write
    mov ch, first_track         
    mov dh, 1        
    mov cl, first_sector

    mov bx, buffer

    ; set the disk type to floppy
    mov dl, 0

    int 13h
