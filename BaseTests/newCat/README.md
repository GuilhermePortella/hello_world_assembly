rm -f catwinapi.o catwinapi.exe
nasm -f win64 catwinapi.asm -o catwinapi.o
gcc catwinapi.o -o catwinapi.exe -mconsole
./catwinapi.exe catwinapi.asm