org 1000h

section .data
    char_counter db 0

section .bss
    buffer resb 255

section .text
    global _start

_start:
    ; initialize the buffer and its counter
    mov si, buffer
    mov byte [char_counter], 0

    jmp read_char


read_char:
    ; read character
    mov ah, 00h
    int 16h

    ; check if the ENTER key was introduced
    cmp al, 0dh
    je handle_enter

    ; check if the BACKSPACE key was introduced
    cmp al, 08h
    je handle_backspace

    ; check if the buffer limit is reached
    cmp byte [char_counter], 255
    je read_char

    ; add character into the buffer and increment its pointer
    mov [si], al
    inc si
    inc byte [char_counter]

    ; display character
    mov ah, 0ah
    mov bh, 0x00
    mov cx, 1
    int 10h

    ; move cursor
    mov ah, 02h
    inc dl
    int 10h

    jmp read_char


; handle ENTER key behavior
handle_enter:
    cmp dl, 0
    je newline

    cmp byte [char_counter], 0
    je newline

    ; clear the character buffer 
    mov byte [si], 0
    mov si, buffer

    call buffer_new_line

    jmp print_buffer


; handle BACKSPACE key behavior
handle_backspace:
    cmp dl, 0
    je read_char

    ; clear last buffer char 
    dec si
    dec byte [char_counter]

    ; move cursor to the left
    mov ah, 02h
    dec dl
    int 10h

    ; print space instead of the cleared char
    mov ah, 0ah
    mov al, ' '
    mov bh, 0x00
    mov cx, 1
    int 10h

    jmp read_char


; print character buffer
print_buffer:
    lodsb; load character form edi into al

    test al, al
    jz newline

    ; display character
    mov ah, 0ah
    mov bh, 0x00
    mov cx, 1
    int 10h

    ; move cursor
    mov ah, 02h
    inc dl
    int 10h

    jmp print_buffer


; move cursor to the bottom of the buffer
buffer_new_line:
    ; find current cursor position
    mov ah, 03h
    int 10h

    ; update the cursor correspondingly
    mov ah, 02h
    inc dh
    mov dl, 0
    int 10h

    ret


; move cursor to the beginning of the new line
newline:
    mov ah, 02h
    inc dh
    mov dl, 0
    int 10h

    jmp _start
