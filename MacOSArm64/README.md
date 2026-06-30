# Rodando Assembly no macOS ARM64

Este diretório tem versões nativas para Mac Apple Silicon dos exemplos básicos do projeto.

Os arquivos originais em `BaseTests/*.asm` foram escritos para **Windows x64**:

- sintaxe NASM;
- objeto `win64`;
- ABI Windows x64, com argumentos em `RCX`, `RDX`, `R8`, `R9`;
- `shadow space` de 32 bytes;
- alguns exemplos usam WinAPI, como `ReadFile`, `WriteFile`, `Beep` e `ExitProcess`.

No macOS Apple Silicon, o caminho nativo é outro:

- arquitetura ARM64/AArch64;
- assembler do `clang`/Apple;
- formato Mach-O;
- símbolos C com `_` na frente, como `_main` e `_printf`;
- argumentos em `x0` a `x7`;
- stack alinhada em 16 bytes antes de chamar funções.

Observacao importante: em funcoes variadicas no Darwin ARM64, como `printf`, os argumentos variadicos ficam na stack. Por isso `calling_convention.s` calcula `sum5` usando registradores, mas coloca o valor final na stack antes de chamar `_printf`.

## Pré-requisito

Instale as ferramentas da Apple:

```bash
xcode-select --install
```

Confira:

```bash
clang --version
uname -m
```

`uname -m` deve mostrar `arm64`.

## Build

Dentro deste diretório:

```bash
cd MacOSArm64
make
```

## Rodando

```bash
make run-hello
make run-loop
make run-calling-convention
make run-bank-mainframe
```

Ou diretamente:

```bash
./build/hello
./build/loop
./build/calling_convention
./build/bank_mainframe
```

## Simulador bancario em estilo mainframe

O arquivo `bank_mainframe.s` simula um lote bancario em memoria:

- autorizacao simples de operador;
- criacao de clientes em uma tabela fixa;
- deposito e saque com validacao de saldo;
- mensagens de auditoria no console.

Ele nao e um banco de dados real nem um ambiente mainframe seguro de verdade. A ideia e mostrar, em Assembly ARM64 no macOS, como uma rotina poderia organizar validacao, registros fixos, transacoes e auditoria.

## Compilando um arquivo manualmente

```bash
clang -arch arm64 hello.s -o build/hello
./build/hello
```

## Sobre os exemplos com WinAPI

Arquivos como `beep_melody.asm`, `word_count.asm` e `newCat/catwinapi.asm` chamam APIs do Windows. Eles nao rodam nativamente no macOS sem serem reescritos para libc/POSIX/macOS syscalls ou sem usar Windows em VM/emulacao.
