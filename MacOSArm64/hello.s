.section __TEXT,__text,regular,pure_instructions
.globl _main
.p2align 2

_main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    adrp x0, msg@PAGE
    add x0, x0, msg@PAGEOFF
    bl _printf

    mov w0, #0
    ldp x29, x30, [sp], #16
    ret

.section __DATA,__data
msg:
    .asciz "Hello, world!\n"
