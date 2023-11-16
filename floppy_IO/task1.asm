org 7c00h

section .data
    delimiter dd "@@@FAF-213 Sevastian BAJENOV###"
    delimiter_length equ 31
    delimiter_count equ 10
    
    first_sector equ 13
    first_track equ 21

    last_sector equ 6
    last_track equ 23

section .bss
    buffer resb 100

section .text
    global _start


_start:
    ; set the delimiter copy parameters
    mov di, buffer

    mov dx, delimiter_length
    mov bx, delimiter_count

    call write_buffer
    call write_start_delimiter
    call write_end_delimiter
    jmp end


write_buffer:
    ; copy the delimiter a certain number of times consecutively into the buffer
    mov si, delimiter
    mov cx, delimiter_length
    rep movsb

    dec bx
    cmp bx, 0
    jg write_buffer
    ret


write_start_delimiter:
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
    ret


write_end_delimiter:
    ; set the floppy mode to write
    mov ah, 03h
    mov al, 1

    ; set the address of the first sector to write
    mov ch, last_track         
    mov dh, 1        
    mov cl, last_sector

    mov bx, buffer

    ; set the disk type to floppy
    mov dl, 0
    int 13h
    ret

end:

