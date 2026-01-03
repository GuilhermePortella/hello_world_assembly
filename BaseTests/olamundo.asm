; hello.asm — loop controlado (10 vezes)
default rel

extern printf
global main

section .data
    msg db "Ola mundo", 10, 0

section .text
main:
    sub rsp, 40          ; shadow space + alinhamento

    xor r12d, r12d       ; contador = 0

.loop:
    lea rcx, [rel msg]   ; argumento para printf
    call printf

    inc r12d             ; contador++
    cmp r12d, 10         ; limite = 10
    jl .loop             ; se < 10, continua

    add rsp, 40
    xor eax, eax
    ret
