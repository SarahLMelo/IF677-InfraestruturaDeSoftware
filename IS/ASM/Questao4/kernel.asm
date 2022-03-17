org 0x7c00
jmp 0x0000:main

data:
  string times 5 db 0
  par db 'par', 13, 10, 0
  impar db 'impar', 13, 10, 0
  
  
putchar:
  mov ah, 0x0e
  int 10h
  ret
  
getchar:
  mov ah, 0x00
  int 16h
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
  
reverse:              ; mov si, string
  mov di, si
  xor cx, cx          ; zerar contador
  .loop1:             ; botar string na stack
    lodsb
    cmp al, 0
    je .endloop1
    inc cl
    push ax
    jmp .loop1
  .endloop1:
  .loop2:             ; remover string da stack        
    pop ax
    stosb
    loop .loop2
  ret
  
tostring:              ; mov ax, int / mov di, string
  push di
  .loop1:
    cmp ax, 0
    je .endloop1
    xor dx, dx
    mov bx, 10
    div bx            ; ax = 9999 -> ax = 999, dx = 9
    xchg ax, dx       ; swap ax, dx
    add ax, 48        ; 9 + '0' = '9'
    stosb
    xchg ax, dx
    jmp .loop1
  .endloop1:
  pop si
  cmp si, di
  jne .done
  mov al, 48
  stosb
  .done:
  mov al, 0
  stosb
  call reverse
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

  
main:
  xor ax, ax
  mov ds, ax ;nao posso zerar diretamente!
  mov es, ax ;importante para o codigo

  mov di, string
  call gets
  mov si, string
  call stoi
  push ax ;lendo o x

  mov di, string
  call gets
  mov si, string
  call stoi
  push ax ;lendo o y

  mov di, string
  call gets
  mov si, string
  call stoi
  push ax ;lendo o z

  mov di, string
  call gets
  mov si, string
  call stoi
  push ax ;lendo o w

  pop ax ;w
  pop bx ;z
  pop cx ;y
  pop dx ;x

  add dx, cx ;como tenho x+y nos dois lados posso usar um registrador so -> x+y em dx
  mov cx, dx ;cx tmb é x+y

  add dx, bx ;dx é a parte de cima -> fazendo a operação (x+y+z)
  sub dx, ax ;parte de cima completa -> fazendo a operação (x+y+z-w)


  ;fazendo as operações da parte de baixo
  add cx, ax ; -> (x+y+w)
  sub cx, bx ; -> (x+y+w-z)

  ;divisão
  mov ax, dx
  div cl ;divindo ax por cl (sempre)
  ;na divisao o resto fica em ah e o resultado em al!

  push ax ;nao quero perder o valor de ax
  mov ah, 0 ;zerei ah p ax ficar com o valor de al
  mov di, string
  call tostring

  mov si, string
  call prints
  call endl

  ;para o resto:
  pop ax
  push ax
  mov al, ah
  mov ah, 0
  cmp al, 0
  je .fim
  mov di, string
  call tostring
  mov si, string
  call prints
  call endl
  pop ax
  mov ah, 0 ;nao preciso mais do resto
  mov cl, 2
  div cl


  cmp al, 0
  je .par
  mov si, impar
  call prints
  jmp .fim

  .par:
    mov si, par
    call prints

  .fim:
  
times 510-($-$$) db 0
dw 0xaa55