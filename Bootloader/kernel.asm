org 0x7E00
jmp 0x0000:start

data:
    emptyString times 7 db '______',0
    chosenWord times 7 db 0
    writenString times 7 db 0

    freqArray times 26 db 0


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


round:
    mov si, emptyString
    mov bl, 0x0F
    call prints
    
    call lineBegin

    mov di, writenString
    call readString

    call lineBegin
    call endl

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