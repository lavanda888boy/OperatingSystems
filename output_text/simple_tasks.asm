org 7c00h; initial address from which the data is started to be stored

section .data
	letter db 'X', 07h;
	line dd "Hallo"; 

section .text
	global _start

_start:
	; printing letter 'A'
	; TTY output
	mov ah, 0eh;
	mov al, '1'; ascii code for the letter 'A'
	mov bl, 0x07; white color attribute
	int 10h;	
	
	; write char
	mov ah, 0ah;
	mov al, 'A';
	mov bh, 0x00; video page number
	mov cx, 1; number characters to display
	int 10h;

	; move cursor
	mov ah, 02h;
	mov dh, 0x00;
	mov dl, 0x03;
	int 10h;

	; write char/attribute
	mov ah, 09h;
	mov al, '9';
	mov bl, 0x04; red color attribute
	mov cx, 1;
	int 10h;

	; move cursor
	mov ah, 02h;
	mov dh, 0x03;
	mov dl, dh;
	int 10h;

	; display char/attribute
	mov ax, 0h;
	mov es, ax;
	mov cx, 0x01;
	mov dh, 0x01;
	mov dl, dh;
	mov bp, letter;
	mov ax, 1302h
	int 10h;

	; display char/attribute + update cursor
	mov ax, 0h;
	mov es, ax;
	mov cx, 0x01;
	mov dh, 0x02;
	mov dl, dh;
	mov bp, letter;
	mov ax, 1303h
	int 10h;

	; display string
	mov ax, 0h; address of the start of the memory
	mov es, ax; 
	mov bl, 0x02; color attribute
	mov cx, 0x05;
	mov dh, 0x03;
	mov dl, dh;
	mov bp, line; address of the variable to display
	mov ax, 1300h;
	int 10h;

	; display string + update cursor
	mov ax, 0h;
	mov es, ax;
	mov bl, 0x03; cyan color attribute
	mov cx, 0x05;
	mov dh, 0x04;
	mov dl, dh;
	mov bp, line;
	mov ax, 1301h;
	int 10h; 	
