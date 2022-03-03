org 0x7E00
jmp 0x0000:start

    nomeJogo times 9 db 'AMGINE', 0
    inicio db 'Pressione ENTER para iniciar', 0
    pcGenio db '          -----', 0 
    detalhes db 'A palavra secreta possui 6 letras', 0
    detalhes1 db '(todas diferentes)', 0 

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

;tempo p ler as instruções
tempoMaior:
    mov bp, 10000
	mov dx, 10000
	delayTela1:
		dec bp
		nop
		jnz delayTela1
	dec dx
	jnz delayTela1

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
    mov bl, 2;cor da tela
    int 10h

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
	mov dl, 17
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
    call tempoMaior


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