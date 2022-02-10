;Testando Assembly

global _start

section .text:
    _start:
        mov eax, 0x4 ;eax é o registrador temporário e 0x4 é o código para escrever
        mov ebx, 1 ;fd do argumento da função write no linux
        mov ecx, message ;buffer do argumento da função write do linux
        mov edx, messageLenght ;Contagem de bits
        int 0x80

        mov eax, 0x1 ;guarda a saida no registrador
        mov ebx, 0
        int 0x80 ;executa a instrução do registrador eax


section .data:
    message: db "Hello World!", 0xA
    messageLenght: equ $-message