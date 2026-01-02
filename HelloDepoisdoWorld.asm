; HelloDepoisdoWorld.asm — loop imprimindo 5 vezes
default rel

extern printf
global main

section .data
    msg db "Ola mundo", 10, 0

section .text
main:
    sub rsp, 40          ; shadow space + alinhamento

    mov ecx, 0           ; contador = 0

.loop:
    lea rcx, [rel msg]   ; argumento para printf
    call printf

    inc ecx              ; contador++
    cmp ecx, 5           ; chegou em 5?
    jl .loop              ; se ecx < 5, repete

    add rsp, 40
    xor eax, eax
    ret