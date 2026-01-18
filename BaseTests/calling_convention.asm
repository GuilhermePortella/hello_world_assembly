; calling_convention.asm (Windows x64, NASM, MinGW-w64/UCRT64)
; Build:
;   nasm -f win64 calling_convention.asm -o calling_convention.o
;   gcc calling_convention.o -o calling_convention.exe -mconsole
; Run:
;   calling_convention.exe
;
; Windows x64 ABI quick demo:
; - RCX, RDX, R8, R9 hold args 1-4
; - caller reserves 32 bytes of shadow space
; - 5th arg goes on the stack
; - return value in RAX

default rel

extern printf
global main

section .data
    fmt db "sum5(1,2,3,4,5) = %I64d", 10, 0

section .text
main:
    sub rsp, 40              ; 32 bytes shadow space + alignment

    ; Prepare args for sum5(1,2,3,4,5).
    mov ecx, 1
    mov edx, 2
    mov r8d, 3
    mov r9d, 4
    mov qword [rsp+32], 5    ; 5th arg at call site
    call sum5

    ; Print the result (RAX) with printf.
    lea rcx, [rel fmt]
    mov rdx, rax
    xor eax, eax             ; required for variadic calls
    call printf

    add rsp, 40
    xor eax, eax
    ret

; sum5(a,b,c,d,e) -> a+b+c+d+e
sum5:
    ; 5th arg lives at [rsp+40] in the callee:
    ; [rsp+0]  return address
    ; [rsp+8]  shadow space (32 bytes total)
    ; [rsp+40] 5th arg
    mov rax, rcx
    add rax, rdx
    add rax, r8
    add rax, r9
    add rax, [rsp+40]
    ret
