org 1000h

section .text
    global _start

_start:
    ; set graphic video mode
    mov ah, 00h 
    mov al, [video_mode]
    int 10h  

    ; red stripe
    mov byte [stripes], 10
    mov byte [pixel_color], 4
    call draw_stripe

    ; orange stripe
    mov byte [stripes], 10
    mov byte [pixel_color], 12
    call draw_stripe

    ; yellow stripe
    mov byte [stripes], 10
    mov byte [pixel_color], 14
    call draw_stripe

    ; green stripe
    mov byte [stripes], 10
    mov byte [pixel_color], 10
    call draw_stripe

    ; light blue stripe
    mov byte [stripes], 10
    mov byte [pixel_color], 9
    call draw_stripe

    ; dark blue stripe
    mov byte [stripes], 10
    mov byte [pixel_color], 1
    call draw_stripe

    ; violet stripe
    mov byte [stripes], 10
    mov byte [pixel_color], 5
    call draw_stripe


draw_stripe:

    stripe_loop:
        mov byte [line_length], 240
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
        mov al, [pixel_color]
        mov dx, [line_number]          
        int 10h

        inc cx

        dec byte [line_length]
        cmp byte [line_length], 0
        jne draw_pixel

    inc word [line_number]
    
    ret

end:


section .data
    video_mode db 13
    pixel_color db 0
    line_length db 0
    left_indent dw 10
    line_number dw 10
    stripes db 0