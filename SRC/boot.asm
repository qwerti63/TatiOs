bits 16
org 0x7C00

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    
    ; Сохраняем номер диска
    mov [boot_drive], dl
    
    ; Очищаем экран
    mov ax, 0x0003
    int 0x10
    
    ; Заголовок
    mov si, msg_boot
    call print
    
    ; Загружаем ядро
    mov bx, 0x1000      ; Адрес
    mov ah, 0x02        ; Читать
    mov al, 16          ; 16 секторов = 8KB
    mov ch, 0           ; Цилиндр
    mov cl, 2           ; Сектор 2
    mov dh, 0           ; Головка
    mov dl, [boot_drive]
    int 0x13
    jc disk_error
    
    ; Успех
    mov si, msg_loaded
    call print
    
    ; Короткая задержка
    mov cx, 0x7FFF
delay:
    loop delay
    
    ; Прыжок в ядро
    jmp 0x0000:0x1000

disk_error:
    mov si, msg_error
    call print
    jmp $

print:
    mov ah, 0x0E
    mov bx, 0x0007
.loop:
    lodsb
    test al, al
    jz .done
    int 0x10
    jmp .loop
.done:
    ret

boot_drive db 0

msg_boot:
    db "Tati OS Bootloader v2.0",13,10
    db "Loading kernel...",13,10,0

msg_loaded:
    db "Kernel loaded at 0x1000",13,10
    db "Starting Tati OS...",13,10,13,10,0

msg_error:
    db "Disk error! System halted.",13,10,0

times 510-($-$$) db 0
dw 0xAA55
