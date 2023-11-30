org 7c00h

mov ah, 0h
int 13h

mov ax, 0000h
mov es, ax
mov bx, 1000h

; load the NASM script into memory
mov ah, 02h
mov al, 3
mov ch, 0
mov cl, 2   
mov dh, 0
mov dl, 0 

int 13h

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
call newline


; print head prompt
mov si, head_prompt
call print_string
call newline


; print track prompt
mov si, track_prompt
call print_string
call newline


; print sector prompt
mov si, sector_prompt
call print_string
call newline


; print final message
mov si, kernel_success
call newline
call print_string
call newline
call newline


; jump to the loaded NASM script
jmp 0000h:1000h


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


prompt db 'Press any key to continue: $'
sector_count_prompt db "N or Q: $"
head_prompt db "Head: $"
track_prompt db "Track: $"
sector_prompt db "Sector: $"
kernel_success db "Kernel loaded!$"

; pad the bootloader to 510 bytes with zeros
times 510 - ($ - $$) db 0
dw 0AA55h