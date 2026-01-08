; word_count.asm - count bytes/lines/words from STDIN using ReadFile
; Build:
;   nasm -f win64 word_count.asm -o word_count.o
;   gcc word_count.o -o word_count.exe -mconsole
; Run:
;   type some.txt | word_count.exe
;   echo hello world | word_count.exe
;
; Step-by-step overview (learning notes):
; 1) Reserve a buffer and a DWORD for bytes_read in .bss.
; 2) Get the STDIN handle with GetStdHandle(-10).
; 3) Loop: ReadFile into the buffer until it returns 0 bytes.
; 4) For each byte:
;    - count lines on '\n'
;    - count words on transitions from whitespace -> non-whitespace
; 5) Print the counters with printf.
;
; Registers used:
;   rbx  = STDIN handle (callee-saved)
;   r12  = total bytes
;   r13  = total lines
;   r14  = total words
;   r15b = in_word flag (0 or 1)
;   rsi  = buffer cursor

default rel

extern GetStdHandle
extern ReadFile
extern printf

global main

BUFFER_SIZE equ 256

section .data
    fmt db "bytes=%I64u", 10, "lines=%I64u", 10, "words=%I64u", 10, 0

section .bss
    buf resb BUFFER_SIZE
    bytes_read resd 1

section .text
main:
    ; Prologue: save callee-saved regs and align the stack.
    push rbx
    push rsi
    push r12
    push r13
    push r14
    push r15
    sub rsp, 40              ; 32 bytes shadow + alignment

    ; Step 2: get STDIN handle.
    mov ecx, -10             ; STD_INPUT_HANDLE
    call GetStdHandle
    mov rbx, rax

    ; Initialize counters and state.
    xor r12d, r12d            ; bytes
    xor r13d, r13d            ; lines
    xor r14d, r14d            ; words
    xor r15d, r15d            ; in_word = 0

.read_loop:
    ; Step 3: ReadFile(hStdin, buf, BUFFER_SIZE, &bytes_read, NULL).
    mov rcx, rbx
    lea rdx, [rel buf]
    mov r8d, BUFFER_SIZE
    lea r9, [rel bytes_read]
    mov qword [rsp+32], 0     ; 5th arg: lpOverlapped = NULL
    call ReadFile

    test eax, eax             ; ReadFile success?
    jz .done

    mov eax, [rel bytes_read]
    test eax, eax             ; 0 bytes -> EOF
    jz .done

    add r12, rax              ; total bytes += bytes_read
    lea rsi, [rel buf]
    mov ecx, [rel bytes_read] ; loop counter

.process_loop:
    mov al, [rsi]

    ; Count lines on '\n'.
    cmp al, 10
    jne .not_nl
    inc r13
.not_nl:

    ; Whitespace set: space, tab, CR, LF.
    cmp al, ' '
    je .is_ws
    cmp al, 9
    je .is_ws
    cmp al, 10
    je .is_ws
    cmp al, 13
    je .is_ws

    ; Non-whitespace: count a word only when entering it.
    test r15b, r15b
    jne .next
    inc r14
    mov r15b, 1
    jmp .next

.is_ws:
    mov r15b, 0

.next:
    inc rsi
    dec ecx
    jnz .process_loop
    jmp .read_loop

.done:
    ; Step 5: print results (format + 3 args).
    lea rcx, [rel fmt]
    mov rdx, r12
    mov r8, r13
    mov r9, r14
    xor eax, eax              ; safe for variadic call
    call printf

    ; Epilogue.
    add rsp, 40
    pop r15
    pop r14
    pop r13
    pop r12
    pop rsi
    pop rbx
    xor eax, eax
    ret
