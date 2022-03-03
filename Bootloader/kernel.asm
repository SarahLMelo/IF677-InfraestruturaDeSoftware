org 0x8600
jmp 0x0000:start

data:
    emptyString times 7 db '______',0
    chosenWord times 7 db 'ENIGMA',0
    writenString times 7 db 0

readchar:
  mov ah, 0x00
  int 16h
  ret

putchar: ;mov al, char e mov bl, color
    mov ah, 09h
    mov cx, 0x01
    int 10h

    inc dl
    mov ah, 02h
    int 10h

    ret

delchar:
    mov ah, 03h
    int 10h

    mov ah, 02h
    dec dl
    int 10h

    mov al, '_'
    mov bl, 0Fh
    call putchar

    mov ah, 03h
    int 10h

    mov ah, 02h
    dec dl
    int 10h

    ret

endl:
  ; Acha onde o cursor está
    mov ah, 03h
    int 10h

    ;Pula a linha
    mov ah, 02h
    inc dh
    int 10h

    ret

  ret

readString: ; mov di, string
    xor cx, cx          ; zerar contador
    push cx

    .loop1:
      call readchar
      cmp al, 0x08      ; backspace
      je .backspace
      cmp al, 0x0d      ; enter
      je .done
      pop cx
      cmp cl, 6        ; string limit checker
      je .limit
      cmp al, 'A'
      jl .limit      ;Se não for uma letra maíuscula
      cmp al, 'Z'
      jg .limit       ;Se não for uma letra maíuscula
    
    stosb
    inc cl
    push cx
    mov bl, 0x0F ;Deixando branco
    call putchar
    
    jmp .loop1
    .limit:
      push cx
      jmp .loop1

    .backspace:
      pop cx
      cmp cl, 0       ; is empty?
      je .limit
      dec di
      dec cl
      push cx
      mov byte[di], 0
      call delchar
    jmp .loop1

  .done:
  pop cx
  mov al, 0
  stosb

  ret

lineBegin: ;seta o cursor no começo da linha
    ; Acha onde o cursor está
    mov ah, 03h
    int 10h

    ;Move para o inicio da linha
    mov ah, 02h
    mov dl, 17
    int 10h

    ret

startVideo:
    mov ah, 00h
    mov al, 0Dh
    int 10h

    mov ah, 02h
    mov bh, 01h
    mov dl, 17
    int 10h

    ret

prints:             ; mov si, string
  .loop2:
    lodsb           ; bota character em al 
    cmp al, 0
    je .endloop2
    call putchar
    jmp .loop2
  .endloop2:
  ret

checkWord:
  mov si, writenString
  xor cx, cx
  push cx
  
  .loop3:
    lodsb
    cmp al, 0
    je .endloop3

    cmp al, 'E'
    je .E

    cmp al, 'N'
    je .N

    cmp al, 'I'
    je .I

    cmp al, 'G'
    je .G

    cmp al, 'M'
    je .M

    cmp al, 'A'
    je .A

    jmp .notInTheWord

  .E:
    pop cx
    cmp cx, 0
    je .right
    jmp .wrongPlace

  .N:
    pop cx
    cmp cx, 1
    je .right
    jmp .wrongPlace

  .I:
    pop cx
    cmp cx, 2
    je .right
    jmp .wrongPlace

  .G:
    pop cx
    cmp cx, 3
    je .right
    jmp .wrongPlace

  .M:
    pop cx
    cmp cx, 4
    je .right
    jmp .wrongPlace

  .A:
    pop cx
    cmp cx, 5
    je .right
    jmp .wrongPlace

  .notInTheWord:
    pop cx
    inc cx
    push cx
    mov bl, 0x04 ;Deixando vermelho
    call putchar
    jmp .loop3

  .right:
    inc cx
    push cx
    mov bl, 0x02 ;Deixando verde
    call putchar
    jmp .loop3

  .wrongPlace:
    inc cx
    push cx
    mov bl, 0x0E ;Deixando amarelo
    call putchar
    jmp .loop3

  .endloop3:
  pop cx
  ret

;ajeitar a condição de parada!
round:
    mov si, emptyString
    mov bl, 0x0F
    call prints
    
    call lineBegin

    mov di, writenString
    call readString

    call lineBegin
    call checkWord

    call endl
    call lineBegin

    jmp round;



start:
    xor ax, ax
    xor bx, bx
    xor cx, cx
    xor dx, dx
    mov ds, ax
    mov es, ax
    
    call startVideo

    call round


   

jmp $