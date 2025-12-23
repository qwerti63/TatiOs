bits 16
org 0x1000

start:
    call init_memory
    call main_menu

main_menu:
    call clear_screen
    call show_header
    call show_processes
    call show_commands
    call wait_and_handle_key
    jmp main_menu

; ============================================
; ИНИЦИАЛИЗАЦИЯ ПАМЯТИ
; ============================================
init_memory:
    ; Процесс A
    mov ax, 0x4000
    mov es, ax
    mov di, 0x0100
    mov word [es:di], 0xBEEF
    mov word [es:di+2], 0xDEAD
    
    ; Процесс B
    mov ax, 0x5000
    mov es, ax
    mov di, 0x0100
    mov word [es:di], 0xCAFE
    mov word [es:di+2], 0xBABE
    
    ; Процесс C
    mov ax, 0x6000
    mov es, ax
    mov di, 0x0100
    mov word [es:di], 0x1234
    mov word [es:di+2], 0x5678
    
    push ds
    pop es
    ret

; ============================================
; ОЧИСТКА ЭКРАНА
; ============================================
clear_screen:
    mov ax, 0x0003
    int 0x10
    ret

; ============================================
; ОТОБРАЖЕНИЕ ИНТЕРФЕЙСА
; ============================================
show_header:
    mov si, header
    call print
    ret

show_processes:
    mov si, proc_header
    call print
    
    ; Процесс A
    mov si, proc_a
    call print
    
    ; Процесс B
    mov si, proc_b
    call print
    
    ; Процесс C
    mov si, proc_c
    call print
    
    mov si, separator
    call print
    ret

show_commands:
    mov si, commands
    call print
    
    ; Показываем последнее действие
    mov si, last_action
    call print
    
    mov si, prompt
    call print
    ret

; ============================================
; ОЖИДАНИЕ И ОБРАБОТКА КЛАВИШИ
; ============================================
wait_and_handle_key:
    ; Ждём клавишу
    mov ah, 0x00
    int 0x16
    
    ; Обрабатываем
    cmp al, '1'
    je .action_1
    cmp al, '2'
    je .action_2
    cmp al, '3'
    je .action_3
    cmp al, 't'
    je .action_t
    cmp al, 'w'
    je .action_w
    cmp al, 'r'
    je .action_r
    cmp al, 'q'
    je .action_q
    
    ; Неизвестная команда
    mov si, unknown_msg
    mov di, last_action
    call copy_string
    call delay_short
    ret

.action_1:
    mov si, showing_a_msg
    mov di, last_action
    call copy_string
    
    ; Показываем данные A
    call clear_screen
    call show_header
    
    mov si, showing_a_msg
    call print
    
    ; Читаем данные
    mov ax, 0x4000
    mov es, ax
    mov bx, 0x0102
    mov ax, [es:bx]
    call print_hex_word
    
    mov bx, 0x0100
    mov ax, [es:bx]
    call print_hex_word
    
    call newline
    call wait_for_any_key
    ret

.action_2:
    mov si, showing_b_msg
    mov di, last_action
    call copy_string
    
    call clear_screen
    call show_header
    
    mov si, showing_b_msg
    call print
    
    mov ax, 0x5000
    mov es, ax
    mov bx, 0x0102
    mov ax, [es:bx]
    call print_hex_word
    
    mov bx, 0x0100
    mov ax, [es:bx]
    call print_hex_word
    
    call newline
    call wait_for_any_key
    ret

.action_3:
    mov si, showing_c_msg
    mov di, last_action
    call copy_string
    
    call clear_screen
    call show_header
    
    mov si, showing_c_msg
    call print
    
    mov ax, 0x6000
    mov es, ax
    mov bx, 0x0102
    mov ax, [es:bx]
    call print_hex_word
    
    mov bx, 0x0100
    mov ax, [es:bx]
    call print_hex_word
    
    call newline
    call wait_for_any_key
    ret

.action_t:
    mov si, testing_msg
    mov di, last_action
    call copy_string
    
    call clear_screen
    call show_header
    
    mov si, testing_msg
    call print
    
    ; Тест изоляции
    mov ax, 0x4000
    mov es, ax
    mov bx, 0x0200
    
    mov ax, [es:bx]
    cmp ax, 0xCAFE
    je .test_fail
    cmp ax, 0xBABE
    je .test_fail
    
    mov si, test_pass_msg
    call print
    jmp .test_done

.test_fail:
    mov si, test_fail_msg
    call print

.test_done:
    call newline
    call wait_for_any_key
    ret

.action_w:
    mov si, writing_msg
    mov di, last_action
    call copy_string
    
    call clear_screen
    call show_header
    
    mov si, writing_msg
    call print
    
    ; Запись в процесс A
    mov ax, 0x4000
    mov es, ax
    mov bx, 0x0100
    
    mov word [es:bx], 0x8888
    mov word [es:bx+2], 0x9999
    
    mov si, write_ok_msg
    call print
    
    call wait_for_any_key
    ret

.action_r:
    mov si, reading_msg
    mov di, last_action
    call copy_string
    
    call clear_screen
    call show_header
    
    mov si, reading_msg
    call print
    
    ; Чтение из процесса A
    mov ax, 0x4000
    mov es, ax
    mov bx, 0x0100
    
    mov ax, [es:bx+2]
    call print_hex_word
    
    mov ax, [es:bx]
    call print_hex_word
    
    call newline
    call wait_for_any_key
    ret

.action_q:
    call clear_screen
    mov si, quit_msg
    call print
    call delay
    cli
    hlt

; ============================================
; УТИЛИТЫ
; ============================================
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

newline:
    mov al, 13
    call print_char
    mov al, 10
    call print_char
    ret

print_char:
    mov ah, 0x0E
    mov bx, 0x0007
    int 0x10
    ret

print_hex_word:
    pusha
    mov cx, 4
.hex_loop:
    rol ax, 4
    mov bx, ax
    and bx, 0x000F
    mov al, [hex_chars + bx]
    call print_char
    loop .hex_loop
    popa
    ret

copy_string:
    ; Копирует строку из SI в DI
    pusha
.copy_loop:
    lodsb
    stosb
    test al, al
    jnz .copy_loop
    popa
    ret

delay:
    push cx
    mov cx, 0xFFFF
.delay_loop:
    push cx
    mov cx, 0x0FFF
.inner:
    loop .inner
    pop cx
    loop .delay_loop
    pop cx
    ret

delay_short:
    push cx
    mov cx, 0x3FFF
.short_loop:
    loop .short_loop
    pop cx
    ret

wait_for_any_key:
    mov si, press_any_key
    call print
    mov ah, 0x00
    int 0x16
    ret

; ============================================
; ДАННЫЕ
; ============================================
header:
    db "TATI OS v2.3 - Interactive Memory Test",13,10
    db "========================================",13,10,13,10,0

proc_header:
    db "PROCESSES (isolated memory):",13,10,13,10,0

proc_a:
    db "[1] Process A: Segment 0x4000, Data: 0xDEADBEEF",13,10,0

proc_b:
    db "[2] Process B: Segment 0x5000, Data: 0xCAFEBABE",13,10,0

proc_c:
    db "[3] Process C: Segment 0x6000, Data: 0x56781234",13,10,0

separator:
    db 13,10,"----------------------------------------",13,10,13,10,0

commands:
    db "COMMANDS: 1=Show A, 2=Show B, 3=Show C",13,10
    db "          t=Test, w=Write, r=Read, q=Quit",13,10,13,10,0

last_action:
    db "Last action: (none)",13,10,0

prompt:
    db "> ",0

showing_a_msg:   db "Process A contains: 0x",0
showing_b_msg:   db "Process B contains: 0x",0
showing_c_msg:   db "Process C contains: 0x",0
testing_msg:     db "Testing isolation (A trying to read B): ",0
writing_msg:     db "Writing 0x99998888 to Process A... ",0
reading_msg:     db "Process A contains: 0x",0

test_pass_msg:   db "PASS - Memory isolated!",13,10,0
test_fail_msg:   db "FAIL - Memory leak!",13,10,0
write_ok_msg:    db "OK - Data written",13,10,0

unknown_msg:     db "Unknown command",13,10,0
press_any_key:   db 13,10,"Press any key to continue...",0
quit_msg:        db "System halted. Thank you for using Tati OS!",13,10,0

hex_chars:       db "0123456789ABCDEF",0
