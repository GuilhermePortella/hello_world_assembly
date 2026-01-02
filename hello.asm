; hello.asm (Windows x64, NASM, MinGW-w64/UCRT64)
default rel

extern printf
global main

section .data
    msg db "Hello, world!", 10, 0

section .text
main:
    sub rsp, 40              ; 32 bytes shadow space + alinhamento
    lea rcx, [rel msg]       ; 1º argumento (Windows x64) em RCX
    call printf
    add rsp, 40
    xor eax, eax
    ret