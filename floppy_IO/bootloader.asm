org 7d00h

mov byte [marker], 0

; print initial prompt
mov si, prompt
call print

call newline

mov si, hts_prompt
call print
call newline


; print sector count prompt
mov ah, 0eh
mov al, '>'
mov bl, 07h
int 10h

mov byte [result], 0
call clear
call read_buffer

mov al, [result]
mov byte [sc], al

call newline


; print head prompt
mov ah, 0eh
mov al, '>'
mov bl, 07h
int 10h

mov byte [result], 0
call clear
call read_buffer

mov al, [result]
mov byte [h], al

call newline


; print track prompt
mov ah, 0eh
mov al, '>'
mov bl, 07h
int 10h

mov byte [result], 0
call clear
call read_buffer

mov al, [result]
mov byte [t], al

call newline


; print sector prompt
mov ah, 0eh
mov al, '>'
mov bl, 07h
int 10h

mov byte [result], 0
call clear
call read_buffer

mov al, [result]
mov byte [s], al

call newline
call newline

inc byte [marker]

; print ram address prompt
mov si, so_prompt
call print
call newline

; print segment prompt
mov ah, 0eh
mov al, '>'
mov bl, 07h
int 10h

call clear
call read_buffer

mov ax, [hex_result]
mov [add1], ax

call newline

; print offset prompt
mov ah, 0eh
mov al, '>'
mov bl, 07h
int 10h

call clear
call read_buffer

mov ax, [hex_result]
mov [add2], ax

call newline

call load_kernel

; print a prompt to load the kernel
mov si, kernel_start
call newline
call print

; read option
mov ah, 00h
int 16h

; display character as TTY
mov ah, 0eh
mov bl, 07h
int 10h

call newline
call newline

; remember segment and offset in ax:bx
mov ax, [add1]
mov bx, [add2]

; jump to the loaded NASM script
add ax, bx
jmp ax


load_kernel:
    mov ah, 0h
    int 13h

    mov ax, [add2]
    mov es, ax
    mov bx, [add1]

    ; load the NASM script into memory
    mov ah, 02h
    mov al, [sc]
    mov ch, [t]
    mov cl, [s]   
    mov dh, [h]
    mov dl, 0 

    int 13h

    ; print error code
    mov al, '0'
    add al, ah
    mov ah, 0eh
    int 10h

    call newline

    ret


read_buffer:

    read_char:
        ; read character
        mov ah, 00h
        int 16h

        ; check if the ENTER key was introduced
        cmp al, 0dh
        je hdl_enter

        ; check if the BACKSPACE key was introduced
        cmp al, 08h
        je hdl_backspace

        ; add character into the buffer and increment its pointer
        mov [si], al
        inc si
        inc byte [c]

        ; display character as TTY
        mov ah, 0eh
        mov bl, 07h
        int 10h

        jmp read_char
    
    hdl_enter:
        mov byte [si], 0
        mov si, buffer

        cmp byte [marker], 0
        je atoi_jump
        jmp atoh_jump

    hdl_backspace:
        call cursor

        cmp byte [c], 0
        je read_char

        ; clear last buffer char 
        dec si
        dec byte [c]

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
    
    atoi_jump:
        call atoi
        jmp end_read_buffer

    atoh_jump:
        call atoh
        jmp end_read_buffer

    end_read_buffer:

    ret


atoi:
    xor ax, ax
    xor bx, bx

    atoi_d:
        lodsb

        sub al, '0'
        xor bh, bh
        imul bx, 10
        add bl, al
        mov [result], bl

        dec byte [c]
        cmp byte [c], 0
        jne atoi_d

    ret


atoh:
    xor bx, bx
    mov di, hex_result

    atoh_s:
        xor ax, ax
        mov al, [si]

        cmp al, 65
        jg atoh_l
        sub al, 48
        jmp continue

        atoh_l:
            sub al, 55
            jmp continue

        continue:
            mov bx, [di]
            imul bx, 16
            add bx, ax
            mov [di], bx

            inc si
            
        dec byte [c]
        jnz atoh_s

    ret


print:
    call cursor
    
    print_char:
        mov al, [si]
        cmp al, '$'
        je end_print

        mov ah, 0eh
        int 10h
        inc si
        jmp print_char

    end_print: 
        ret  


clear:
    mov byte [c], 0
    mov byte [si], 0
    mov si, buffer

    ret


cursor:
    mov ah, 03h
    mov bh, 0
    int 10h

    ret


newline:
    call cursor

    mov ah, 02h
    mov bh, 0
    inc dh
    mov dl, 0
    int 10h

    ret


section .data:
    prompt db 'Welcome, Sevastian. Press any key to continue: $'
    hts_prompt db "Enter CHTS script address$"
    so_prompt db "Enter XXXX:YYYY RAM address$"
    kernel_start db "Press any key to load the kernel: $"

    sc db 0
    h db 0
    t db 0
    s db 0

    c db 0
    result db 0

    marker db 0


section .bss:
    hex_result resb 2
    add1 resb 2
    add2 resb 2
    buffer resb 2

dw 0AA55h