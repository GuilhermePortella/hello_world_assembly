.equ MAX_CLIENTS, 4
.equ SUCCESS, 1
.equ FAILURE, 0

.section __TEXT,__text,regular,pure_instructions
.globl _main
.p2align 2

_main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    adrp x0, banner@PAGE
    add x0, x0, banner@PAGEOFF
    bl _printf

    mov x0, #1977
    bl _authorize_operator
    cbz w0, operator_denied

    adrp x0, auth_ok@PAGE
    add x0, x0, auth_ok@PAGEOFF
    bl _printf

    mov x0, #1001
    mov x1, #4312
    mov x2, #5000
    bl _create_client
    mov x1, #1001
    bl _print_create_result

    mov x0, #1002
    mov x1, #9208
    mov x2, #7500
    bl _create_client
    mov x1, #1002
    bl _print_create_result

    mov x0, #1001
    mov x1, #1200
    bl _deposit
    mov x1, #1001
    mov x2, #1200
    bl _print_deposit_result

    mov x0, #1002
    mov x1, #9000
    bl _withdraw
    mov x1, #1002
    mov x2, #9000
    bl _print_withdraw_result

    mov x0, #1002
    mov x1, #2500
    bl _withdraw
    mov x1, #1002
    mov x2, #2500
    bl _print_withdraw_result

    mov x0, #1001
    bl _print_balance

    mov x0, #1002
    bl _print_balance

    adrp x0, footer@PAGE
    add x0, x0, footer@PAGEOFF
    bl _printf

    mov w0, #0
    ldp x29, x30, [sp], #16
    ret

operator_denied:
    adrp x0, auth_fail@PAGE
    add x0, x0, auth_fail@PAGEOFF
    bl _printf
    mov w0, #1
    ldp x29, x30, [sp], #16
    ret

.p2align 2
_authorize_operator:
    mov x9, #1977
    cmp x0, x9
    cset w0, eq
    ret

.p2align 2
_create_client:
    adrp x9, client_count@PAGE
    add x9, x9, client_count@PAGEOFF
    ldr x10, [x9]
    cmp x10, #MAX_CLIENTS
    b.ge create_full

    adrp x11, client_ids@PAGE
    add x11, x11, client_ids@PAGEOFF
    str x0, [x11, x10, lsl #3]

    adrp x11, client_pin_hashes@PAGE
    add x11, x11, client_pin_hashes@PAGEOFF
    str x1, [x11, x10, lsl #3]

    adrp x11, client_balances@PAGE
    add x11, x11, client_balances@PAGEOFF
    str x2, [x11, x10, lsl #3]

    add x10, x10, #1
    str x10, [x9]
    mov w0, #SUCCESS
    ret

create_full:
    mov w0, #FAILURE
    ret

.p2align 2
_deposit:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!

    mov x19, x1
    bl _find_client
    cmp x0, #-1
    b.eq deposit_fail

    adrp x9, client_balances@PAGE
    add x9, x9, client_balances@PAGEOFF
    ldr x20, [x9, x0, lsl #3]
    add x20, x20, x19
    str x20, [x9, x0, lsl #3]
    mov w0, #SUCCESS
    b deposit_done

deposit_fail:
    mov w0, #FAILURE

deposit_done:
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

.p2align 2
_withdraw:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!

    mov x19, x1
    bl _find_client
    cmp x0, #-1
    b.eq withdraw_fail

    adrp x9, client_balances@PAGE
    add x9, x9, client_balances@PAGEOFF
    ldr x20, [x9, x0, lsl #3]
    cmp x20, x19
    b.lt withdraw_fail
    sub x20, x20, x19
    str x20, [x9, x0, lsl #3]
    mov w0, #SUCCESS
    b withdraw_done

withdraw_fail:
    mov w0, #FAILURE

withdraw_done:
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

.p2align 2
_find_client:
    adrp x9, client_count@PAGE
    add x9, x9, client_count@PAGEOFF
    ldr x10, [x9]
    mov x11, #0

find_loop:
    cmp x11, x10
    b.ge find_not_found

    adrp x12, client_ids@PAGE
    add x12, x12, client_ids@PAGEOFF
    ldr x13, [x12, x11, lsl #3]
    cmp x13, x0
    b.eq find_found
    add x11, x11, #1
    b find_loop

find_found:
    mov x0, x11
    ret

find_not_found:
    mov x0, #-1
    ret

.p2align 2
_print_create_result:
    cmp w0, #SUCCESS
    b.eq print_create_ok
    adrp x0, create_fail_fmt@PAGE
    add x0, x0, create_fail_fmt@PAGEOFF
    b print_one_arg

print_create_ok:
    adrp x0, create_ok_fmt@PAGE
    add x0, x0, create_ok_fmt@PAGEOFF
    b print_one_arg

.p2align 2
_print_deposit_result:
    cmp w0, #SUCCESS
    b.eq print_deposit_ok
    adrp x0, deposit_fail_fmt@PAGE
    add x0, x0, deposit_fail_fmt@PAGEOFF
    b print_two_args

print_deposit_ok:
    adrp x0, deposit_ok_fmt@PAGE
    add x0, x0, deposit_ok_fmt@PAGEOFF
    b print_two_args

.p2align 2
_print_withdraw_result:
    cmp w0, #SUCCESS
    b.eq print_withdraw_ok
    adrp x0, withdraw_fail_fmt@PAGE
    add x0, x0, withdraw_fail_fmt@PAGEOFF
    b print_two_args

print_withdraw_ok:
    adrp x0, withdraw_ok_fmt@PAGE
    add x0, x0, withdraw_ok_fmt@PAGEOFF
    b print_two_args

.p2align 2
_print_balance:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!

    mov x19, x0
    bl _find_client
    cmp x0, #-1
    b.eq print_balance_missing

    adrp x9, client_balances@PAGE
    add x9, x9, client_balances@PAGEOFF
    ldr x20, [x9, x0, lsl #3]

    adrp x0, balance_fmt@PAGE
    add x0, x0, balance_fmt@PAGEOFF
    mov x1, x19
    mov x2, x20
    bl print_two_args
    b print_balance_done

print_balance_missing:
    adrp x0, balance_missing_fmt@PAGE
    add x0, x0, balance_missing_fmt@PAGEOFF
    mov x1, x19
    bl print_one_arg

print_balance_done:
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

.p2align 2
print_one_arg:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #16
    str x1, [sp]
    bl _printf
    add sp, sp, #16
    ldp x29, x30, [sp], #16
    ret

.p2align 2
print_two_args:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #16
    str x1, [sp]
    str x2, [sp, #8]
    bl _printf
    add sp, sp, #16
    ldp x29, x30, [sp], #16
    ret

.section __DATA,__data
banner:
    .asciz "=== Simulador bancario mainframe / macOS ARM64 ===\n"
auth_ok:
    .asciz "[SEC] operador autorizado; iniciando transacao batch.\n"
auth_fail:
    .asciz "[SEC] operador recusado; lote abortado.\n"
create_ok_fmt:
    .asciz "[DB2] cliente %lld criado em tabela segura simulada.\n"
create_fail_fmt:
    .asciz "[DB2] falha ao criar cliente %lld; tabela cheia.\n"
deposit_ok_fmt:
    .asciz "[TXN] deposito aprovado: cliente %lld, valor %lld centavos.\n"
deposit_fail_fmt:
    .asciz "[TXN] deposito recusado: cliente %lld, valor %lld centavos.\n"
withdraw_ok_fmt:
    .asciz "[TXN] saque aprovado: cliente %lld, valor %lld centavos.\n"
withdraw_fail_fmt:
    .asciz "[TXN] saque recusado: cliente %lld, valor %lld centavos.\n"
balance_fmt:
    .asciz "[AUDIT] saldo final cliente %lld = %lld centavos.\n"
balance_missing_fmt:
    .asciz "[AUDIT] cliente %lld nao localizado.\n"
footer:
    .asciz "=== fim do lote: commit simulado e auditoria gravada ===\n"

.p2align 3
client_count:
    .quad 0
client_ids:
    .space 32
client_pin_hashes:
    .space 32
client_balances:
    .space 32
