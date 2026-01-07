; beep_melody.asm - demo: arrays + loop + WinAPI Beep (no printf / no file IO)
; Build:
;   nasm -f win64 beep_melody.asm -o beep_melody.o
;   gcc beep_melody.o -o beep_melody.exe -mconsole
; Run:
;   ./beep_melody.exe

default rel

extern Beep
extern Sleep
extern ExitProcess

global main

section .data
    ; Simple melody as (freq, duration) arrays with 0 sentinel.
    freqs dd 523, 659, 784, 1047, 0
    durs  dd 120, 120, 120, 200, 0
    pause_ms dd 80

section .text
main:
    ; Preserve nonvolatile regs we use.
    push rbx
    push rdi
    sub rsp, 40              ; shadow space + alignment

    lea rbx, [rel freqs]
    lea rdi, [rel durs]

.loop:
    mov eax, [rbx]
    test eax, eax
    jz .done

    mov ecx, eax             ; Beep(dwFreq)
    mov edx, [rdi]            ; Beep(dwDuration)
    call Beep

    mov ecx, [rel pause_ms]
    call Sleep

    add rbx, 4
    add rdi, 4
    jmp .loop

.done:
    add rsp, 40
    pop rdi
    pop rbx
    xor ecx, ecx
    call ExitProcess
