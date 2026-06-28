.section __TEXT,__text,regular,pure_instructions
.globl _main
.p2align 2

_main:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    str x19, [sp, #16]

    mov w19, #0

L_loop:
    adrp x0, msg@PAGE
    add x0, x0, msg@PAGEOFF
    bl _printf

    add w19, w19, #1
    cmp w19, #10
    b.lt L_loop

    ldr x19, [sp, #16]
    mov w0, #0
    ldp x29, x30, [sp], #32
    ret

.section __DATA,__data
msg:
    .asciz "Ola mundo\n"
