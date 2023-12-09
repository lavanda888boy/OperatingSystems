org 1000h

section .text
    global _start

_start:
    ; receive segment:offset pair from the bootloader
    mov [add1], ax
    mov [add2], bx
    
    jmp menu


menu:
    mov byte [page], 0
    mov word [line_number], 10

    ; set text video mode
    mov ah, 00h 
    mov al, 2
    int 10h  

    ; print command disclaimer
    call find_current_cursor_position
    
    mov ax, 0h
	mov es, ax
    mov bh, [page]
	mov bl, 07h
    mov cx, disclaimer_length
	mov bp, disclaimer

	mov ax, 1301h
	int 10h 

    call newline

    ; print reboot option
    ; print command disclaimer
    call find_current_cursor_position
    
    mov ax, 0h
	mov es, ax
    mov bh, [page]
	mov bl, 07h
    mov cx, reboot_prompt_length
	mov bp, reboot_prompt

	mov ax, 1301h
	int 10h 

    ; read character
    mov ah, 00h
    int 16h

    cmp al, 'r'
    je reboot

    call newline

    ; input stripe width
    call find_current_cursor_position
    
    mov ax, 0h
	mov es, ax
    mov bh, [page]
	mov bl, 07h
    mov cx, stripe_width_prompt_length
	mov bp, stripe_width_prompt

	mov ax, 1301h
	int 10h 

    mov byte [result], 0
    call clear_buffer
    call read_buffer

    mov al, [result]
    mov byte [stripe_width], al

    call newline

    ; input stripe height
    call find_current_cursor_position
    
    mov ax, 0h
	mov es, ax
    mov bh, [page]
	mov bl, 07h
    mov cx, stripe_height_prompt_length
	mov bp, stripe_height_prompt

	mov ax, 1301h
	int 10h 

    mov byte [result], 0
    call clear_buffer
    call read_buffer

    mov al, [result]
    mov byte [stripe_height], al

    call newline


    ; input stripe indent
    call find_current_cursor_position
    
    mov ax, 0h
	mov es, ax
    mov bh, [page]
	mov bl, 07h
    mov cx, stripe_indent_prompt_length
	mov bp, stripe_indent_prompt

	mov ax, 1301h
	int 10h 

    mov byte [result], 0
    call clear_buffer
    call read_buffer

    mov al, [result]
    mov byte [stripe_indent], al

    call newline
    call draw_rainbow

    ; read character
    mov ah, 00h
    int 16h

    call change_page_number
    jmp menu
    
    jmp end


reboot:
    call change_page_number

    ; set text video mode
    mov ah, 00h 
    mov al, 2
    int 10h 

    jmp 0000h:7c00h


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


clear_buffer:
    mov byte [char_counter], 0
    mov byte [si], 0
    mov si, buffer

    ret


draw_rainbow:
    ; set graphic video mode
    mov ah, 00h 
    mov al, [video_mode]
    int 10h  

    ; red stripe
    mov al, byte [stripe_height]
    mov byte [stripes], al
    mov byte [pixel_color], 4
    call draw_stripe

    ; orange stripe
    mov al, byte [stripe_height]
    mov byte [stripes], al
    mov byte [pixel_color], 12
    call draw_stripe

    ; yellow stripe
    mov al, byte [stripe_height]
    mov byte [stripes], al
    mov byte [pixel_color], 14
    call draw_stripe

    ; green stripe
    mov al, byte [stripe_height]
    mov byte [stripes], al
    mov byte [pixel_color], 10
    call draw_stripe

    ; light blue stripe
    mov al, byte [stripe_height]
    mov byte [stripes], al
    mov byte [pixel_color], 9
    call draw_stripe

    ; dark blue stripe
    mov al, byte [stripe_height]
    mov byte [stripes], al
    mov byte [pixel_color], 1
    call draw_stripe

    ; violet stripe
    mov al, byte [stripe_height]
    mov byte [stripes], al
    mov byte [pixel_color], 5
    call draw_stripe
    
    ret

; HARDCODE INITIAL LINE NUMBER
draw_stripe:

    stripe_loop:
        mov al, byte [stripe_width]
        mov byte [line_length], al

        mov al, byte [stripe_indent]
        mov byte [left_indent], al
        mov cx, [left_indent]
        call draw_line

        cmp byte [stripes], 0
        je end_stripe_loop

        dec byte [stripes]
        jmp stripe_loop

    end_stripe_loop:

    ret


draw_line:

    draw_pixel:
        mov ah, 0ch
        mov bh, byte [page]
        mov al, [pixel_color]
        mov dx, [line_number]          
        int 10h

        inc cx

        dec byte [line_length]
        cmp byte [line_length], 0
        jne draw_pixel

    inc word [line_number]
    
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


change_page_number:
    inc byte [page]
    mov ah, 05h
    mov al, [page]
    int 10h

    ret


find_current_cursor_position:
    mov ah, 03h
    mov bh, byte [page]
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

end:


section .data
    disclaimer db "Welcome to the rainbow command! Remember, the page has the size 320x200!"
    disclaimer_length equ 72

    reboot_prompt db "Press r to reboot or any other key to continue: "
    reboot_prompt_length equ 47

    stripe_width_prompt db "Stripe width: "
    stripe_width_prompt_length equ 14

    stripe_indent_prompt db "Stripe indent: "
    stripe_indent_prompt_length equ 15

    stripe_height_prompt db "Stripe height: "
    stripe_height_prompt_length equ 15

    video_mode db 13
    pixel_color db 0

    line_length db 0
    stripe_width db 0

    left_indent dw 10
    stripe_indent dw 0

    line_number dw 10

    stripes db 0
    stripe_height dw 0

    char_counter db 0
    result db 0

    page db 0

    c db 0


section .bss
    add1 resb 2
    add2 resb 2
    buffer resb 100