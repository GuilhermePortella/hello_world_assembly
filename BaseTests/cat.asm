default rel

extern printf
global main

section .data
cat db " /\_/\ ", 10,\
       "( o.o )", 10,\
       " > ^ < ", 10, 0

section .text
main:
    sub rsp, 40
    lea rcx, [rel cat]     ; printf(cat)
    call printf
    add rsp, 40
    xor eax, eax
    ret
