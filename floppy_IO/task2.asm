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

    segment_prompt dd "Segment: "
    segment_prompt_length equ 9

    offset_prompt dd "Offset: "
    offset_prompt_length equ 8

    index db 0
    adress_marker db 0

    result db 0
    hex_result db 0

    adress_1 db 0
    adress_2 db 0

    repetitions db 0

    head db 0
    track db 0
    sector db 0

section .bss
    buffer resb 255

section .text
    global _start

_start:
    ; reset the marker for the handle_enter procedure
    mov byte [index], 0

    ; reset marker for reading memory address
    mov byte [adress_marker], 0

    call display_command_list

    ; read command option
    mov ah, 00h
    int 16h

    ; display character as TTY
    mov ah, 0eh
    mov bl, 07h
    int 10h

    mov si, buffer
    mov byte [char_counter], 0

    call newline

    cmp al, '1'
    je read_number_of_operations

    cmp al, '2'
    je read_segment

    cmp al, '3'
    je read_segment

    jmp newline_simple_call


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

    inc byte [index]
    jmp read_buffer


read_segment:
    mov si, buffer
    mov byte [char_counter], 0

    call find_current_cursor_position

    mov ax, 0h
	mov es, ax
	mov bl, 07h
	mov cx, segment_prompt_length
	mov bp, segment_prompt

	mov ax, 1301h
	int 10h

    mov byte [si], 0
    mov si, buffer

    inc byte [adress_marker]

    jmp read_buffer


read_offset:
    mov si, buffer
    mov byte [char_counter], 0

    call find_current_cursor_position

    mov ax, 0h
	mov es, ax
	mov bl, 07h
	mov cx, offset_prompt_length
	mov bp, offset_prompt

	mov ax, 1301h
	int 10h

    mov byte [si], 0
    mov si, buffer

    inc byte [adress_marker]

    jmp read_buffer


read_head:
    call find_current_cursor_position

    mov si, buffer
    mov byte [char_counter], 0

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

    inc byte [index]
    jmp read_buffer


read_track:
    call find_current_cursor_position

    mov si, buffer
    mov byte [char_counter], 0

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

    inc byte [index]
    jmp read_buffer


read_sector:
    call find_current_cursor_position

    mov si, buffer
    mov byte [char_counter], 0

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

    inc byte [index]
    jmp read_buffer


read_data:
    call find_current_cursor_position

    mov si, buffer
    mov byte [char_counter], 0

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

    inc byte [index]
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
    je newline_simple_call

    ; clear the character buffer 
    mov byte [si], 0
    mov si, buffer

    ; check if the memory address was introduced and it should be converted
    cmp byte [adress_marker], 1
    je convert_input_hex

    cmp byte [adress_marker], 2
    je check_direction

    check_direction:
        cmp byte [index], 0
        je convert_input_hex

        cmp byte [index], 1
        je convert_input_int

        cmp byte [index], 2
        je convert_input_int

        cmp byte [index], 3
        je convert_input_int

        cmp byte [index], 4
        je convert_input_int

        cmp byte [index], 5
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

    jmp next_prompt


; convert string into a hex
convert_input_hex:
    xor ax, ax
    xor cx, cx

    convert_symbol:
        lodsb

        sub al, 30h

        cmp al, 9h
        jg process_letter
        jmp continue

        process_letter:
            sub al, 7h
            jmp continue

        continue:
            rol al, 4
            add ch, al
            ;add ch, al

        dec byte [char_counter]
        cmp byte [char_counter], 0
        jne convert_symbol

    call newline
    ;mov [hex_result], ch
    mov ah, 0eh
    mov al, ch
    int 10h

    jmp next_prompt


; select the next prompt to print
next_prompt:
    call newline

    cmp byte [adress_marker], 1
    je go_to_read_offset

    cmp byte [adress_marker], 2
    je check_another_direction

    check_another_direction:
        cmp byte [index], 0
        je go_to_read_number_of_operations

        cmp byte [index], 1
        je go_to_read_head

        cmp byte [index], 2
        je go_to_read_track

        cmp byte [index], 3
        je go_to_read_sector

        cmp byte [adress_marker], 0
        jne read_from_floppy

        cmp byte [index], 4
        je go_to_read_data

        call newline

        cmp byte [index], 5
        je print_buffer

    jmp end


go_to_read_offset:
    mov ax, [hex_result]
    mov [adress_1], ax
    jmp read_offset


go_to_read_number_of_operations:
    mov ax, [hex_result]
    mov [adress_2], ax
    jmp read_number_of_operations


go_to_read_head:
    mov al, [result]
    mov [repetitions], al
    jmp read_head


go_to_read_track:
    mov al, [result]
    mov [head], al
    jmp read_track


go_to_read_sector:
    mov al, [result]
    mov [track], al
    jmp read_sector


go_to_read_data:
    mov al, [result]
    mov byte [sector], al
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
    mov dh, [head] 
    mov ch, [track]     
    mov cl, [sector]

    mov bx, buffer

    ; set the disk type to floppy
    mov dl, 0
    int 13h

    ; print error code
    mov al, '0'
    add al, ah
    mov ah, 0eh
    int 10h

    call newline

    dec byte [repetitions]
    inc byte [sector]
    cmp byte [repetitions], 0
    jne write_to_floppy

    call newline
    jmp _start


read_from_floppy:
    ; clear the character buffer 
    mov byte [si], 0
    mov si, buffer

    ; set the floppy mode to read
    mov ah, 02h
    mov al, [repetitions]

    mov dh, [head]
    mov ch, [track]
    mov cl, [sector]

    mov dl, 0    
    mov ax, [adress_1]
    mov es, ax
    mov bx, [adress_2]

    int 13h

    call newline

    ; print error code
    mov al, '0'
    add al, ah
    mov ah, 0eh
    int 10h

    call newline
    call newline

    ; ; print data from the floppy
    ; call find_current_cursor_position

    ; mov ax, [adress_1]
	; mov es, ax
	; mov bl, 07h
	; mov cx, [adress_2]
	; mov bp, [adress_2]

	; mov ax, 1301h
	; int 10h   

    jmp _start


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

    ; clear the character buffer 
    mov byte [si], 0
    mov si, buffer
    inc si

    jmp write_to_floppy


newline_simple_call:
    call newline
    call newline
    jmp _start


find_current_cursor_position:
    mov ah, 03h
    mov bh, 0x00
    int 10h

    ret


end:
    call newline
