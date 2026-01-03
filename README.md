# Hello World em Assembly (W x64)

Este repositório documenta a implementação de um **Hello World em Assembly x86-64 no Windows** usando **NASM** e **MinGW-w64 (MSYS2 / UCRT64)**.

Mais importante do que o código final, este doc registra todos os erros reais cometidos durante o processo, explicando:
- por que eles aconteceram
- como diagnosticá-los
- como resolvê-los corretamente

> Este README não é um tutorial “happy path”.  
> Ele existe porque o *happy path não existe* quando se aprende assembly em maquinas W x64.

---

## Objetivos

Ao final deste projeto, você deve ser capaz de:

- Compilar Assembly (`.asm`) com NASM
- Linkar corretamente com `gcc` (MinGW-w64)
- Entender diferenças entre **32-bit vs 64-bit**
- Respeitar a **Windows x64 ABI**
- Implementar loops sem bugs de registradores
- Diagnosticar erros de toolchain, PATH e linker

---

## Ambiente utilizado

- Windows 10/11 (64-bit)
- NASM
- MSYS2 (UCRT64)
- MinGW-w64 (x86_64)
- GCC (via MSYS2)

---

## Estrutura do projeto

```
hello_world_assembly/
├── hello.asm
├── .gitignore
└── README.md
```

---

## Código final (Hello World)

```asm
default rel

extern printf
global main

section .data
    msg db "Hello, world!", 10, 0

section .text
main:
    sub rsp, 40              ; shadow space + alinhamento
    lea rcx, [rel msg]       ; 1º argumento (Windows x64 ABI)
    call printf
    add rsp, 40
    xor eax, eax
    ret
```

---

## Build e execução

```bash
nasm -f win64 hello.asm -o hello.o
gcc hello.o -o hello.exe -mconsole
./hello.exe
```

---

## Erros comuns encontrados

### 1. `'nasm' is not recognized`

**Causa:** NASM não está no PATH  
**Diagnóstico:**
```bat
"C:\Program Files\NASM\nasm.exe" -v
```

---

### 2. GCC não linka: `file format not recognized`

**Causa:** GCC 32-bit tentando linkar objeto 64-bit  
**Diagnóstico:**
```bash
gcc -dumpmachine
```

Saída problemática:
```
mingw32
```

---

### 3. Instruções não suportadas em 32-bit

```text
instruction not supported in 32-bit mode
```

**Causa:** código usa registradores 64-bit (`rcx`, `rsp`) com `-f win32`.

---

### 4. `gcc: command not found` no MSYS2

**Causa:** toolchain não instalado  
**Correção:**
```bash
pacman -S mingw-w64-ucrt-x86_64-toolchain
```

---

### 5. Executável roda mesmo sem compilar

**Causa:** `.exe` antigo ainda existe.  
**Correção obrigatória:**
```bash
rm -f hello.o hello.exe
```

---

### 6. `_printf`, `WinMain`, relocation truncada

**Causas combinadas:**
- símbolo errado (`_printf` vs `printf`)
- entry point errado (`_main` vs `main`)
- ausência de `default rel`
- subsystem incorreto

---

## Loop com limite (exemplo correto)

```asm
xor r12d, r12d       ; contador seguro (callee-saved)

.loop:
    lea rcx, [rel msg]
    call printf
    inc r12d
    cmp r12d, 10
    jl .loop
```

---

## Bug clássico evitado

Usar `ECX` como contador **e** `RCX` como argumento:

```asm
mov ecx, 0
lea rcx, [rel msg]   ; destrói o contador
```

Dica:
> Nunca reutilize registradores de argumento para estado do programa.

---

## Diagramas conceituais

### Windows x64 Calling Convention

```
Argumentos:
RCX → 1º argumento
RDX → 2º argumento
R8  → 3º argumento
R9  → 4º argumento

Caller-saved:
RAX, RCX, RDX, R8, R9, R10, R11

Callee-saved:
RBX, RBP, RDI, RSI, R12–R15
```

---

### Stack frame em `main`

```
┌───────────────────────────────┐
│ Retorno para o runtime C      │
├───────────────────────────────┤
│ Shadow space (32 bytes)       │
│                               │
│                               │
│                               │
├───────────────────────────────┤
│ Alinhamento (16 bytes)        │
└───────────────────────────────┘

```

Por isso:
```asm
sub rsp, 40
```

---

## .gitignore recomendado

```gitignore
# Build artifacts
*.o
*.obj
*.exe
*.dll

# Temporários
*~
*.tmp
*.log

# IDEs
.vscode/
.idea/

# OS
.DS_Store
Thumbs.db
```

---

## Conclusão

Este projeto demonstra que aprender Assembly no Windows não é sobre sintaxe —
é sobre **entender o sistema**:

- toolchains
- ABI
- arquitetura
- linking
- registradores
- disciplina

Se você chegou até aqui, você **não “brincou” com assembly**.  
Você aprendeu.
