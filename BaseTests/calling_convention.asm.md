# calling_convention.asm

Este README descreve o arquivo `BaseTests/calling_convention.asm`, que demonstra a calling convention do Windows x64 usando NASM + MinGW-w64.

## Objetivo

Mostrar, na pratica, como a ABI do Windows x64 passa argumentos e como o quinto argumento vai para a stack.

## Build e execucao

```bash
nasm -f win64 BaseTests/calling_convention.asm -o BaseTests/calling_convention.o
gcc BaseTests/calling_convention.o -o BaseTests/calling_convention.exe -mconsole
BaseTests/calling_convention.exe
```

## Resumo tecnico (Windows x64 ABI)

- Argumentos 1-4: `RCX`, `RDX`, `R8`, `R9`
- Shadow space: o caller sempre reserva 32 bytes na stack
- Argumento 5+: o caller grava em `[rsp+32]` antes do `call`
- Retorno: `RAX`
- Stack: alinhamento de 16 bytes no ponto do `call`

## O que o codigo faz

### main

1) Reserva 32 bytes de shadow space e garante alinhamento:

```asm
sub rsp, 40
```

2) Prepara os 5 argumentos para `sum5(1,2,3,4,5)`:

```asm
mov ecx, 1
mov edx, 2
mov r8d, 3
mov r9d, 4
mov qword [rsp+32], 5
call sum5
```

3) Imprime o resultado com `printf` (variadica exige `eax = 0`):

```asm
lea rcx, [rel fmt]
mov rdx, rax
xor eax, eax
call printf
```

### sum5

Soma os cinco argumentos:

- Os quatro primeiros ja chegam nos registradores.
- O quinto argumento esta na stack do callee em `[rsp+40]`.

O deslocamento muda porque, ao entrar na funcao, a stack contem o endereco de retorno:

```
[rsp+0]  return address
[rsp+8]  shadow space (32 bytes)
[rsp+40] 5th arg
```

Trecho principal:

```asm
mov rax, rcx
add rax, rdx
add rax, r8
add rax, r9
add rax, [rsp+40]
ret
```

## Observacoes

- O exemplo foca apenas em convencao de chamada; nao salva registradores callee-saved.
- `default rel` simplifica enderecamento relativo em x64.
