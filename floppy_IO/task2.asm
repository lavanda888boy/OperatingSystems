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

    ; display character as TTY
    mov ah, 0eh
    mov bl, 07h
    int 10h

    jmp read_char


; handle ENTER key behavior
handle_enter:
    cmp byte [char_counter], 0
    je newline

    ; clear the character buffer 
    mov byte [si], 0
    mov si, buffer

    jmp print_buffer


; handle BACKSPACE key behavior
handle_backspace:
    call find_current_cursor_position

    cmp byte [char_counter], 0
    je read_char

    cmp dl, 0
    je previous_line

    jmp continue_backspace

    previous_line:
        call prev_line
        jmp continue_backspace

    ; move backspace cursor to the previous line
    prev_line:
        call find_current_cursor_position

        mov ah, 02h
        dec dh
        mov dl, 80
        int 10h

        ret

    continue_backspace:
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
    call find_current_cursor_position

    ; print the buffer
    inc dh
    mov dl, 0h

    mov ax, 0h
    mov es, ax
    mov bp, buffer
    mov bl, 07h
    mov cx, [char_counter]

    mov ax, 1301h
    int 10h

    jmp newline


; move cursor to the beginning of the new line
newline:
    call find_current_cursor_position

    mov ah, 02h
    inc dh
    mov dl, 0
    int 10h

    jmp _start


find_current_cursor_position:
    ; find current cursor position
    mov ah, 03h
    mov bh, 0x00
    int 10h

    ret


end:
