org 0x7e00
jmp 0x0000:start

data:

getchar:
    mov ah, 0x00
    int 16h ;Interrupção de Teclado

    ret
printchar:
    mov ah, 0x0e
    int 10h ;Interrupção de Vídeo

    ret

deletechar:
    mov al, 0x08 ;
    call printchar
    
    mov al, ''
    call printchar

    mov al, 0x08
    call printchar

    ret

endl:
    mov al, 0x0a ; \n
    call printchar
    mov al, 0x0d ; \r
    call printchar

    ret

getstring:
    xor cx, cx;

    .loop1:
        cmp cl, 0 ; Se for a primeira vez rodando
        je .primeiraVez

        call getchar ; Leio
        cmp al, 0x0d ; O caractere lido foi backspace?
        je .teclaEnter
        cmp cl, 49
        je .loop1

        push ax ; Colocando na pilha
        inc cl ;aumentando o contador

        call printchar ;printa o que leu na tela
        jmp .loop1

        .primeiraVez:
            mov al, 0
            push ax
            inc cl
            jmp .loop1
            
        .teclaEnter:
            cmp cl, 1 ;se foi a primeira coisa que leu
            je .loop1

            call endl
            call printstring

    ret

printstring:
    xor cx, cx
    .loop2:
        pop ax
        cmp cx, 0
        je .outraPrimeiraVez
        cmp al, 0
        je .endloop

        call printchar
        jmp .loop2

        .outraPrimeiraVez:
            inc cx
            jmp .loop2

        .endloop:
    ret


start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    
    call getstring
   

jmp $