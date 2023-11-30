org 7c00h

; print initial prompt
mov si, prompt
call print_string

; read option
mov ah, 00h
int 16h

; display character as TTY
mov ah, 0eh
mov bl, 07h
int 10h

call newline


; print sector count prompt
mov si, sector_count_prompt
call print_string

mov byte [result], 0
call clear_buffer
call read_buffer

mov al, [result]
mov byte [sector_count], al

call newline


; print head prompt
mov si, head_prompt
call print_string

mov byte [result], 0
call clear_buffer
call read_buffer

mov al, [result]
mov byte [head], al

call newline


; print track prompt
mov si, track_prompt
call print_string

mov byte [result], 0
call clear_buffer
call read_buffer

mov al, [result]
mov byte [track], al

call newline


; print sector prompt
mov si, sector_prompt
call print_string

mov byte [result], 0
call clear_buffer
call read_buffer

mov al, [result]
mov byte [sector], al

call newline

call load_kernel

; print final message
mov si, kernel_success
call newline
call print_string
call newline
call newline


; jump to the loaded NASM script
jmp 0000h:1000h


load_kernel:
    mov ah, 0h
    int 13h

    mov ax, 0000h
    mov es, ax
    mov bx, 1000h

    ; load the NASM script into memory
    mov ah, 02h
    mov al, [sector_count]
    mov ch, [track]
    mov cl, [sector]   
    mov dh, [head]
    mov dl, 0 

    int 13h

    ret


read_buffer:

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

        ; add character into the buffer and increment its pointer
        mov [si], al
        inc si
        inc byte [char_counter]

        ; display character as TTY
        mov ah, 0eh
        mov bl, 07h
        int 10h

        jmp read_char
    
    handle_enter:
        mov byte [si], 0
        mov si, buffer
        call convert_input_int
        jmp end_read_buffer

    handle_backspace:
        call find_current_cursor_position

        cmp byte [char_counter], 0
        je read_char

        ; clear last buffer char 
        dec si
        dec byte [char_counter]

        ; move cursor to the left
        mov ah, 02h
        mov bh, 0
        dec dl
        int 10h

        ; print space instead of the cleared char
        mov ah, 0ah
        mov al, ' '
        mov bh, 0
        mov cx, 1
        int 10h

        jmp read_char

    end_read_buffer:

    ret


convert_input_int:
    xor ax, ax
    xor bx, bx

    convert_digit:
        lodsb

        sub al, '0'
        xor bh, bh
        imul bx, 10
        add bl, al
        mov [result], bl

        dec byte [char_counter]
        cmp byte [char_counter], 0
        jne convert_digit

    ret


print_string:
    call find_current_cursor_position
    
    print_char:
        mov al, [si]
        cmp al, '$'
        je end_print_string

        mov ah, 0eh
        int 10h
        inc si
        jmp print_char

    end_print_string: 
        ret  


clear_buffer:
    mov byte [char_counter], 0
    mov byte [si], 0
    mov si, buffer

    ret


find_current_cursor_position:
    mov ah, 03h
    mov bh, 0
    int 10h

    ret


newline:
    call find_current_cursor_position

    mov ah, 02h
    mov bh, 0
    inc dh
    mov dl, 0
    int 10h

    ret


section .data:
    prompt db 'Press any key to continue: $'
    sector_count_prompt db "Sector count: $"
    head_prompt db "Head: $"
    track_prompt db "Track: $"
    sector_prompt db "Sector: $"
    kernel_success db "Kernel loaded!$"

    sector_count db 0
    head db 0
    track db 0
    sector db 0

    char_counter db 0
    result db 0


section .bss:
    buffer resb 255


; pad the bootloader to 510 bytes with zeros
times 510-($-$$) db 0
dw 0AA55h