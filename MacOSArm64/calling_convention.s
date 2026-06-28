.section __TEXT,__text,regular,pure_instructions
.globl _main
.p2align 2

_main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    mov x0, #1
    mov x1, #2
    mov x2, #3
    mov x3, #4
    mov x4, #5
    bl _sum5

    mov x9, x0
    adrp x0, fmt@PAGE
    add x0, x0, fmt@PAGEOFF
    sub sp, sp, #16
    str x9, [sp]
    bl _printf
    add sp, sp, #16

    mov w0, #0
    ldp x29, x30, [sp], #16
    ret

.p2align 2
_sum5:
    add x0, x0, x1
    add x0, x0, x2
    add x0, x0, x3
    add x0, x0, x4
    ret

.section __DATA,__data
fmt:
    .asciz "sum5(1,2,3,4,5) = %lld\n"
