#!/bin/bash
echo "🚀 Tati OS - Interactive Version"
echo "Now with proper screen clearing!"

# Используем интерактивное ядро
cp src/kernel_interactive.asm src/kernel.asm

# Собираем
echo "🔨 Building..."
nasm -f bin src/boot.asm -o boot.bin
nasm -f bin src/kernel.asm -o kernel.bin

# Создаём образ
dd if=/dev/zero of=tati_interactive.img bs=512 count=2880 2>/dev/null
dd if=boot.bin of=tati_interactive.img conv=notrunc 2>/dev/null
dd if=kernel.bin of=tati_interactive.img bs=512 seek=1 conv=notrunc 2>/dev/null

echo ""
echo "════════════════════════════════════════════"
echo "HOW TO USE:"
echo "1. Wait for interface to appear"
echo "2. Press keys: 1, 2, 3, t, w, r, q"
echo "3. Screen will CLEAR and show results"
echo "4. After action, press any key to return"
echo ""
echo "NOTE: This should work properly now!"
echo "════════════════════════════════════════════"

# Запускаем
qemu-system-x86_64 \
    -drive format=raw,file=tati_interactive.img \
    -nographic \
    -serial mon:stdio \
    -m 8M \
    -no-reboot

echo ""
echo "════════════════════════════════════════════"
echo "Session ended."
