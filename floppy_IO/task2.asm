org 1000h

section .data
    char_counter db 0

    prompt dd "Choose the command (1-keyboard/floppy, 2-ram/floppy, 3-floppy/ram): "
    prompt_length equ 68

    write_count_prompt dd "N or Q: "
    write_count_prompt_length equ 8

    head_prompt dd "Head: "
    head_prompt_length equ 6

    track_prompt dd "Track: "
    track_prompt_length equ 7

    sector_prompt dd "Sector: "
    sector_prompt_length equ 8

    input_data dd "Data: "
    input_data_length equ 6

section .bss
    buffer resb 255

section .text
    global _start

_start:
    ; reset the marker for the handle_enter procedure
    mov di, 0

    call display_command_list

    ; read command option
    mov ah, 00h
    int 16h

    ; display character as TTY
    mov ah, 0eh
    mov bl, 07h
    int 10h

    call newline
    jmp read_number_of_operations

    ; initialize the buffer and its counter
    ; mov si, buffer
    ; mov byte [char_counter], 0

    ; jmp read_buffer


display_command_list:
    call find_current_cursor_position

    mov ax, 0h
	mov es, ax
	mov bl, 07h
	mov cx, prompt_length
	mov bp, prompt

	mov ax, 1301h
	int 10h

    ret


read_number_of_operations:
    call find_current_cursor_position

    ; read the number of write operations
    mov ax, 0h
	mov es, ax
	mov bl, 07h
	mov cx, write_count_prompt_length
	mov bp, write_count_prompt

	mov ax, 1301h
	int 10h    

    ; clear the character buffer 
    mov byte [si], 0
    mov si, buffer

    inc di
    jmp read_buffer


read_head:
    call find_current_cursor_position

    ; read the head address
    mov ax, 0h
	mov es, ax
	mov bl, 07h
	mov cx, head_prompt_length
	mov bp, head_prompt

	mov ax, 1301h
	int 10h    

    ; clear the character buffer 
    mov byte [si], 0
    mov si, buffer

    inc di
    jmp read_buffer


read_track:
    call find_current_cursor_position

    ; read the track address
    mov ax, 0h
	mov es, ax
	mov bl, 07h
	mov cx, track_prompt_length
	mov bp, track_prompt

	mov ax, 1301h
	int 10h    

    ; clear the character buffer 
    mov byte [si], 0
    mov si, buffer

    inc di
    jmp read_buffer


read_sector:
    call find_current_cursor_position

    ; read the sector address
    mov ax, 0h
	mov es, ax
	mov bl, 07h
	mov cx, sector_prompt_length
	mov bp, sector_prompt

	mov ax, 1301h
	int 10h    

    ; clear the character buffer 
    mov byte [si], 0
    mov si, buffer

    inc di
    jmp read_buffer


read_data:
    call find_current_cursor_position

    ; read the data
    mov ax, 0h
	mov es, ax
	mov bl, 07h
	mov cx, input_data_length
	mov bp, input_data

	mov ax, 1301h
	int 10h    

    ; clear the character buffer 
    mov byte [si], 0
    mov si, buffer

    inc di
    jmp read_buffer


read_buffer:
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
    je read_buffer

    ; add character into the buffer and increment its pointer
    mov [si], al
    inc si
    inc byte [char_counter]

    ; display character as TTY
    mov ah, 0eh
    mov bl, 07h
    int 10h

    jmp read_buffer


; handle ENTER key behavior
handle_enter:
    cmp byte [char_counter], 0
    je newline_call

    ; clear the character buffer 
    mov byte [si], 0
    mov si, buffer

    ; check if the input is a number and should be converted
    cmp di, 1
    je convert_input

    cmp di, 2
    je convert_input

    cmp di, 3
    je convert_input

    cmp di, 4
    je convert_input

    cmp di, 5
    je next_prompt

    call newline

    jmp print_buffer


; handle BACKSPACE key behavior
handle_backspace:
    call find_current_cursor_position

    cmp byte [char_counter], 0
    je read_buffer

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

        jmp read_buffer


; convert string into an integer
convert_input:
    xor ax, ax
    mov cx, 10

    convert_digit:
        lodsb
        sub al, '0'
        mul cx
        add ax, dx

        cmp byte [si], 0
        je next_prompt

        jmp convert_digit   


; select the next prompt to print
next_prompt:
    call newline

    cmp di, 1
    je go_to_read_head

    cmp di, 2
    je go_to_read_track

    cmp di, 3
    je go_to_read_sector

    cmp di, 4
    je go_to_read_data

    cmp di, 5
    je print_buffer

    jmp end


go_to_read_head:
    jmp read_head


go_to_read_track:
    mov dh, al
    jmp read_track


go_to_read_sector:
    mov ch, al
    jmp read_sector


go_to_read_data:
    mov cl, al
    jmp read_data


; print character buffer
print_buffer:
    ; load character form edi into al
    lodsb

    test al, al
    jz newline_call

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


write_to_floppy:
    ; set the floppy mode to write
    mov ah, 03h
    mov al, 1

    ; set the address of the first sector to write
    mov ch, 21         
    mov dh, 1        
    mov cl, 13

    mov bx, buffer

    ; set the disk type to floppy
    mov dl, 0
    int 13h

    mov al, '0'
    add al, ah
    mov ah, 0eh
    int 10h

    ret


; move cursor to the beginning of the new line
newline:
    call find_current_cursor_position

    mov ah, 02h
    inc dh
    mov dl, 0
    int 10h

    ret


newline_call:
    call newline
    call write_to_floppy

    jmp _start


find_current_cursor_position:
    mov ah, 03h
    mov bh, 0x00
    int 10h

    ret


end:
    call newline
