org 0x7E00
jmp 0x0000:start

data:
    string times 15 db 0
    number times 3 db 0

getchar:
  mov ah, 0x00
  int 16h
  ret

putchar:
	mov ah,0x0e
	int 10h
	ret

delchar:
  mov al, 0x08          ; backspace
  call putchar
  mov al, ' '
  call putchar
  mov al, 0x08          ; backspace
  call putchar
  ret
  
endl:
  mov al, 0x0a          ; line feed
  call putchar
  mov al, 0x0d          ; carriage return
  call putchar
  ret


prints:             ; mov si, string
  .loop:
    lodsb           ; bota character em al 
    cmp al, 0
    je .endloop
    call putchar
    jmp .loop
  .endloop:
  ret

gets:                 ; mov di, string
  xor cx, cx          ; zerar contador
  .loop1:
    call getchar
    cmp al, 0x08      ; backspace
    je .backspace
    cmp al, 0x0d      ; carriage return
    je .done
    cmp cl, 10        ; string limit checker
    je .loop1
    
    stosb
    inc cl
    call putchar
    
    jmp .loop1
    .backspace:
      cmp cl, 0       ; is empty?
      je .loop1
      dec di
      dec cl
      mov byte[di], 0
      call delchar
    jmp .loop1
  .done:
  mov al, 0
  stosb
  call endl
  ret

stoi:                ; mov si, string
  xor cx, cx
  xor ax, ax
  .loop1:
    push ax
    lodsb
    mov cl, al
    pop ax
    cmp cl, 0        ; check EOF(NULL)
    je .endloop1
    sub cl, 48       ; '9'-'0' = 9
    mov bx, 10
    mul bx           ; 999*10 = 9990
    add ax, cx       ; 9990+9 = 9999
    jmp .loop1
  .endloop1:
  ret

start:
    xor ax, ax
    xor bx, bx
    xor cx, cx
    xor dx, dx
    mov ds, ax
    mov es, ax

    mov ah, 00h
    mov al, 03h
    int 10h

    mov di, string
    call gets

    mov di, number
    call gets

    mov si, number
    call stoi

    mov bx, ax
    mov si, string

    .loop2:
      ;call putchar
      cmp bx, 0
      je .endloop2
      
      dec bx
      lodsb
      jmp .loop2

      .endloop2:


    call putchar

jmp $
