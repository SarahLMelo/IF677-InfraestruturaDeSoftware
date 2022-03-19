org 0x7E00
jmp 0x0000:start

    nomeJogo times 9 db 'CODIGO.OOO', 0
    inicio db 'Pressione ENTER para iniciar', 0
    pcGenio db '          -----', 0 
    texto1 db 'Regras do jogo:', 0
    texto2 db '1- Voce possui 6 tentativas para acertar o codigo', 0
    texto3 db '2- A palavra possui todas as letras      diferentes!', 0
    texto4 db '3- Se a letra estiver no local certo     sera pintada de', 0
    texto5 db '4- Se a letra estiver no local errado    sera pintada de ', 0
    texto6 db '5- Se nao tiver a letra, sera pintada de ', 0
    verde db 'VERDE', 0
    amarelo db 'AMARELO', 0
    vermelho db 'VERMELHO', 0
    segredo db 'e ficara oculta', 0
    cuidado db 'ENTER para pular', 0


prints:             ; mov si, string
  .loop2:
    lodsb           ; bota character em al 
    cmp al, 0
    je .endloop2
    call putchar
    jmp .loop2
  .endloop2:
  ret

tempoCarregar:
	mov bp, 800
	mov dx, 800
	delayTela:
		dec bp
		nop
		jnz delayTela
	dec dx
	jnz delayTela

ret

;tela p escrever as instruções
telaCarregar:
    ;inicia modo de video
    mov ah, 0 
    mov al, 13
    int 10h

    ;escolhe a cor da tela
    mov ah, 0xb 
    mov bh, 0
    mov bl, 9;cor da tela
    int 10h

    ;regras do jogo (texto na tela)
    mov ah, 02h
	mov bh, 00h
	mov dh, 1
	mov dl, 13
	int 10h

    mov si, texto1
    mov bl, 15 ;cor do nome escrito
    call prints

    ;regra 1
    mov ah, 02h
	mov bh, 00h
	mov dh, 5
	mov dl, 0
	int 10h

    mov si, texto2
    mov bl, 15 ;cor do nome escrito
    call prints

    ;regra 2
    mov ah, 02h
	mov bh, 00h
	mov dh, 9
	mov dl, 0
	int 10h

    mov si, texto3
    mov bl, 15 ;cor do nome escrito
    call prints

    ;regra 3
    mov ah, 02h
	mov bh, 00h
	mov dh, 12
	mov dl, 0
	int 10h

    mov si, texto4
    mov bl, 15 ;cor do nome escrito
    call prints

    ;regra 4
    mov ah, 02h
	mov bh, 00h
	mov dh, 16
	mov dl, 0
	int 10h

    mov si, texto5
    mov bl, 15 ;cor do nome escrito
    call prints

    ;regra 5
    mov ah, 02h
	mov bh, 00h
	mov dh, 20
	mov dl, 0
	int 10h

    mov si, texto6
    mov bl, 15 ;cor do nome escrito
    call prints

    ;VERDE
    mov ah, 02h
	mov bh, 00h
	mov dh, 13
	mov dl, 14
	int 10h

    mov si, verde
    mov bl, 10 ;cor do nome escrito
    call prints

    ;AMARELO
    mov ah, 02h
	mov bh, 00h
	mov dh, 17
	mov dl, 17
	int 10h

    mov si, amarelo
    mov bl, 14 ;cor do nome escrito
    call prints

    ;segredo
    mov ah, 02h
	mov bh, 00h
	mov dh, 17
	mov dl, 25
	int 10h

    mov si, segredo
    mov bl, 15 ;cor do nome escrito
    call prints



    ;VERMELHO
    mov ah, 02h
	mov bh, 00h
	mov dh, 21
	mov dl, 1
	int 10h

    mov si, vermelho
    mov bl, 12 ;cor do nome escrito
    call prints

    ;segredo
    mov ah, 02h
	mov bh, 00h
	mov dh, 21
	mov dl, 10
	int 10h

    mov si, segredo
    mov bl, 15 ;cor do nome escrito
    call prints

    ;enter p comecar
    mov ah, 02h
	mov bh, 00h
	mov dh, 23
	mov dl, 22
	int 10h

    mov si, cuidado
    mov bl, 7 ;cor do nome escrito
    call prints




putchar:
  mov ah, 0x0e
  int 10h
  ret

start:
    xor ax, ax
    mov es, ax
    mov ds, ax

    ;inicia modo de video
    mov ah, 0 
    mov al, 13
    int 10h

    ;escolhe a cor da tela
    mov ah, 0xb 
    mov bh, 0
    mov bl, 3;cor da tela
    int 10h

    ;colocando o nome do jogo no meio
    mov ah, 02h
	mov bh, 00h
	mov dh, 7
	mov dl, 14
	int 10h

    mov si, nomeJogo
    mov bl, 1 ;cor do nome escrito
    call prints

    ;texto do enter
    mov ah, 02h
	mov bh, 00h
	mov dh, 13
	mov dl, 6
	int 10h

    mov si, inicio
    mov bl, 0x0F ;cor do nome escrito
    call prints

    ;linha do enter
    mov ah, 02h
	mov bh, 00h
	mov dh, 14
	mov dl, 6
	int 10h

    mov si, pcGenio
    mov bl, 4 ;cor do nome escrito
    call prints


enter:
    mov ah, 0x00
    int 16h
    cmp al, 0x0d
    je fim
    jmp enter

fim:
    call tempoCarregar
    call telaCarregar
    mov ah, 0x00
    int 16h
    cmp al, 0x0d
    je jogo
    jmp fim
    


jogo:
;Setando a posição do disco onde kernel.asm foi armazenado(ES:BX = [0x500:0x0])
	mov ax,0x860		;0x860<<1 + 0 = 0x8600
	mov es,ax
	xor bx,bx		;Zerando o offset

;Setando a posição da Ram onde o jogo será lido
	mov ah, 0x02	;comando de ler setor do disco
	mov al,8		;quantidade de blocos ocupados por jogo
	mov dl,0		;drive floppy

;Usaremos as seguintes posições na memoria:
	mov ch,0		;trilha 0
	mov cl,7		;setor 7
	mov dh,0		;cabeca 0
	int 13h
	jc jogo	;em caso de erro, tenta de novo
	
break:
	jmp 0x8600

exit: 
