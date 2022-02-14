org 0x7c00
jmp 0x0000:start

data:
    imagem db 16, 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 8, 8, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 8, 7, 8, 8, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 8, 7, 8, 8, 8, 8, 0, 0, 0, 0, 8, 8, 0, 0, 0, 0, 8, 8, 8, 8, 9, 1, 8, 8, 8, 8, 1, 8, 0, 0, 0, 0, 0, 0, 8, 8, 9, 9, 9, 9, 8, 9, 9, 8, 0, 0, 0, 0, 0, 0, 8, 1, 9, 9, 15, 15, 9, 9, 9, 8, 0, 0, 0, 0, 0, 0, 8, 9, 9, 9, 9, 9, 9, 9, 9, 1, 0, 0, 0, 0, 0, 0, 8, 9, 15, 15, 15, 9, 9, 9, 9, 9, 0, 0, 0, 0, 0, 0, 8, 9, 9, 9, 15, 15, 9, 9, 9, 8, 0, 0, 0, 0, 8, 8, 8, 8, 1, 9, 9, 9, 9, 8, 8, 0, 0, 0, 0, 0, 8, 8, 8, 0, 0, 8, 1, 9, 9, 0, 0, 0, 0, 0, 0, 0, 8, 8, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 8, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 8, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 8, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

start: 
    xor ax, ax
    xor bx, bx 
    xor cx, cx ;Vou usar como x
    xor dx, dx ;Vou usar como y
    mov ds, ax
    mov es, ax

    mov ah, 00h ;Começar O Modo de Video
    mov al, 13h
    int 10h

    mov si, imagem

    .loop1:
        lodsb
        mov ah, 0Ch ;Printar o pixel
        int 10h

        inc cx
        cmp cx, 16
        je .mudarDeLinha
        jmp .loop1
        .mudarDeLinha:
            mov cx, 0
            inc dx
            cmp dx, 16
            je .endloop1
            jmp .loop1

        .endloop1:
            jmp .end
   
.end:
    jmp $

times 510 - ($ - $$) db 0
dw 0xaa55