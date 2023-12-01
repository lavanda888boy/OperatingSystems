org 1000h

section .data
    video_mode db 13
    pixel_color db 0
    line_length db 0

section .text
    global _start

_start:
    ; set graphic video mode
    mov ah, 00h 
    mov al, [video_mode]
    int 10h  

    mov al, 4
    mov cx, 10
    mov byte [pixel_color], 4
    mov byte [line_length], 20
    call draw_line


draw_line:
    
    draw_pixel:
        mov ah, 0ch
        mov al, [pixel_color]          
        mov dx, 10
        int 10h

        inc cx

        dec byte [line_length]
        cmp byte [line_length], 0
        jne draw_pixel
    
    ret
