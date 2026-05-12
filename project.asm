; To-Do List for DOSBox - NASM
; assemble: nasm list.asm -o list.com
bits 16
org 100h
jmp start
menu db 13,10,'--- TO DO LIST ---',13,10
        db '1. Add Task',13,10
        db '2. View Tasks',13,10
        db '3. Exit',13,10
        db 'Choice: $'
prompt db 13,10,'Enter task: $'
fname db 'name.txt',0
newline db 13,10,'$'
errmsg db 13,10,'File error!$'
handle dw 0
tasklen dw 0
inbuf db 255
        db 0
        times 255 db 0
taskbuf times 260 db 0
readbuf times 512 db 0
start:
main_loop:
    mov dx, menu
    mov ah, 09h
    int 21h
    mov ah, 01h ; key lo
    int 21h
    cmp al, '1'
    jne check2
    jmp add_task
check2:
    cmp al, '2'
    jne check3
    jmp view_task
check3:
    cmp al, '3'
    jne main_loop
    jmp exit_prog
; ---------- ADD ----------
add_task:
    mov dx, prompt
    mov ah, 09h
    int 21h
    mov dx, inbuf
    mov ah, 0Ah
    int 21h
    mov cl, [inbuf+1]
    xor ch, ch
    or cx, cx
    jnz have_text
    jmp main_loop ; khali input
have_text:
    mov si, inbuf+2
    mov di, taskbuf
    rep movsb
    mov byte [di], 13
    inc di
    mov byte [di], 10
    inc di
    mov ax, di
    sub ax, taskbuf
    mov [tasklen], ax
    ; open file
    mov dx, fname
    mov al, 2
    mov ah, 3Dh
    int 21h
    jnc opened_ok
    ; create if not exist
    mov dx, fname
    xor cx, cx
    mov ah, 3Ch
    int 21h
    jc go_error
opened_ok:
    mov [handle], ax
    ; seek to end (append)
    mov bx, [handle]
    mov ax, 4202h
    xor cx, cx
    xor dx, dx
    int 21h
    ; write
    mov bx, [handle]
    mov cx, [tasklen]
    mov dx, taskbuf
    mov ah, 40h
    int 21h
    ; close
    mov bx, [handle]
    mov ah, 3Eh
    int 21h
    jmp main_loop
go_error:
    jmp error
; ---------- VIEW ----------
view_task:
    mov dx, fname
    mov al, 0
    mov ah, 3Dh
    int 21h
    jc go_error
    mov [handle], ax
read_loop:
    mov bx, [handle]
    mov cx, 512
    mov dx, readbuf
    mov ah, 3Fh
    int 21h
    or ax, ax
    jz close_view
    mov cx, ax
    mov bx, 1
    mov dx, readbuf
    mov ah, 40h
    int 21h
    jmp read_loop
close_view:
    mov bx, [handle]
    mov ah, 3Eh
    int 21h
    mov dx, newline
    mov ah, 09h
    int 21h
    jmp main_loop
error:
    mov dx, errmsg
    mov ah, 09h
    int 21h
    jmp main_loop
exit_prog:
    mov ax, 4C00h
    int 21h