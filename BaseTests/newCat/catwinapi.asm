; catwinapi.asm - "cat" minimalista via WinAPI (Windows x64)
; Build:
;   nasm -f win64 catwinapi.asm -o catwinapi.o
;   gcc catwinapi.o -o catwinapi.exe -mconsole
; Run:
;   ./catwinapi.exe arquivo.txt

default rel

extern GetStdHandle
extern WriteFile
extern CreateFileA
extern ReadFile
extern CloseHandle
extern ExitProcess

global main

%define STD_OUTPUT_HANDLE -11
%define STD_ERROR_HANDLE  -12

%define GENERIC_READ      0x80000000
%define FILE_SHARE_READ   0x00000001
%define OPEN_EXISTING     3
%define FILE_ATTRIBUTE_NORMAL 0x00000080

section .data
usage db "Uso: catwinapi.exe <arquivo>", 13, 10, 0
usage_len equ $ - usage - 1

openfail db "Erro: nao consegui abrir o arquivo.", 13, 10, 0
openfail_len equ $ - openfail - 1

readfail db "Erro: falha ao ler o arquivo.", 13, 10, 0
readfail_len equ $ - readfail - 1

writefail db "Erro: falha ao escrever no stdout.", 13, 10, 0
writefail_len equ $ - writefail - 1

section .bss
buf resb 4096

section .text
; int main(int argc, char** argv)
main:
    ; Reserva shadow space (32) + locais e mantém alinhamento
    ; RSP chega alinhado com mod16=8 (por causa do retaddr).
    ; sub rsp, 0x48 => (8 - 8) => mod16=0 em calls.
    sub rsp, 0x48

    ; guarda argc/argv em registradores voláteis? melhor copiar
    ; argc em ECX, argv em RDX (convenção do main)
    mov r8d, ecx       ; r8d = argc
    mov r9, rdx        ; r9  = argv

    ; pega stdout/stderr handles
    mov ecx, STD_OUTPUT_HANDLE
    call GetStdHandle
    mov r12, rax       ; r12 = hStdout (callee-saved)

    mov ecx, STD_ERROR_HANDLE
    call GetStdHandle
    mov r13, rax       ; r13 = hStderr (callee-saved)

    ; se argc < 2 => usage
    cmp r8d, 2
    jl .print_usage

    ; filename = argv[1]
    mov rax, [r9 + 8]  ; argv[1] (ponteiro 8 bytes)
    mov r14, rax       ; r14 = filename (callee-saved)

    ; hFile = CreateFileA(filename, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL)
    mov rcx, r14                   ; lpFileName
    mov edx, GENERIC_READ          ; dwDesiredAccess
    mov r8d, FILE_SHARE_READ       ; dwShareMode
    xor r9d, r9d                   ; lpSecurityAttributes = NULL

    ; args 5,6,7 vão na stack (depois do shadow space)
    mov dword [rsp + 0x20], OPEN_EXISTING
    mov dword [rsp + 0x28], FILE_ATTRIBUTE_NORMAL
    mov qword [rsp + 0x30], 0       ; hTemplateFile = NULL

    call CreateFileA
    mov rbx, rax                    ; rbx = hFile (callee-saved)

    ; INVALID_HANDLE_VALUE = -1
    cmp rbx, -1
    je .open_failed

.read_loop:
    ; ReadFile(hFile, buf, 4096, &bytesRead, NULL)
    mov rcx, rbx
    lea rdx, [rel buf]
    mov r8d, 4096
    lea r9, [rsp + 0x38]           ; bytesRead (QWORD local)

    mov qword [rsp + 0x20], 0      ; lpOverlapped = NULL
    call ReadFile
    test eax, eax
    jz .read_failed

    ; se bytesRead == 0 => EOF
    mov rax, [rsp + 0x38]
    test rax, rax
    jz .done_ok

    ; WriteFile(stdout, buf, bytesRead, &bytesWritten, NULL)
    mov rcx, r12
    lea rdx, [rel buf]
    mov r8, [rsp + 0x38]           ; nNumberOfBytesToWrite
    lea r9, [rsp + 0x40]           ; bytesWritten (QWORD local)

    mov qword [rsp + 0x20], 0      ; lpOverlapped = NULL
    call WriteFile
    test eax, eax
    jz .write_failed

    jmp .read_loop

.print_usage:
    ; WriteFile(stderr, usage, usage_len, &bw, NULL)
    mov rcx, r13
    lea rdx, [rel usage]
    mov r8d, usage_len
    lea r9, [rsp + 0x40]
    mov qword [rsp + 0x20], 0
    call WriteFile

    mov ecx, 1
    call ExitProcess

.open_failed:
    mov rcx, r13
    lea rdx, [rel openfail]
    mov r8d, openfail_len
    lea r9, [rsp + 0x40]
    mov qword [rsp + 0x20], 0
    call WriteFile

    mov ecx, 2
    call ExitProcess

.read_failed:
    mov rcx, r13
    lea rdx, [rel readfail]
    mov r8d, readfail_len
    lea r9, [rsp + 0x40]
    mov qword [rsp + 0x20], 0
    call WriteFile

    mov ecx, 3
    call ExitProcess

.write_failed:
    mov rcx, r13
    lea rdx, [rel writefail]
    mov r8d, writefail_len
    lea r9, [rsp + 0x40]
    mov qword [rsp + 0x20], 0
    call WriteFile

    mov ecx, 4
    call ExitProcess

.done_ok:
    ; CloseHandle(hFile)
    mov rcx, rbx
    call CloseHandle

    mov ecx, 0
    call ExitProcess
