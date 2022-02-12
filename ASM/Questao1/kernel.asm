org 0x7e00
jmp 0x0000:start

data:
    posCol: dd 0x00
    posLin: dd 0x00
    color: db 0x00
    savingAddress: db 0x00

getchar:
    mov ah, 0x00
    int 16h

stringToInt:
    pop ax ;retirando o comando inicial
    mov [savingAddress], al;

    .loop2:
        pop ax
        mov [color], al

        pop ax
        cmp al, 'e'
        jne .add10

    .add10:
        mov al, 0x0a
        add [color], al ;adicionei a casa decimal extra
        jmp .finish

    .finish:
        mov ax, 0x30
        sub [color], ax ;deixando o valor em inteiro



    push savingAddress
    ret

getstring:
    .loop1:
        call getchar
        cmp al, 0x20 ;se for igual a espaço (' '), pule para o próximo loop
        je .loop1
        cmp al, 0x2C ;Se for igual a ,
        je .virgula
        jne .save

        .save:
            push ax
            jmp .loop1
            
        .virgula:
            call stringToInt
            mov al, 'e'
            push ax
            call printarPixel
            jmp .loop1
        

printarPixel:
    mov ah, 0Ch
    mov al, [color]
    mov bh, 00h
    mov cx, [posLin]
    mov dx, [posCol]
    int 10h

    mov ax, 0Fh
    cmp [posCol], ax
    je .pulaLinha
    jne .pulaColuna

    .pulaLinha:
        mov ax, [posLin]
        inc ax
        mov [posLin], ax
        mov ax, 00h
        mov [posCol], ax
        ret
    .pulaColuna:
        mov ax, [posCol]
        inc ax
        mov [posCol], ax
        ret


start:
    mov ah, 00h
    mov al, 04h ;Escolhendo modo
    int 10h ; executando

    ;setando o fundo de branco
    mov ah, 06h
    mov al, 00h
    mov bh, 0Fh
    mov ch, 00h
    mov cl, 00h
    mov dh, 0Fh
    mov dl, 0Fh
    int 10h

    
    call getstring
   

jmp $