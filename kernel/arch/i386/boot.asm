MultibootModuleAlign equ 1 ; align modules on page boundaries
MultibootMemoryInfo equ 1 << 1 ; provide a memory map
MultibootMagic equ 0x1BADB002
MultibootFlags equ MultibootModuleAlign | MultibootMemoryInfo
MultibootChecksum equ -(MultibootMagic + MultibootFlags)

; Multiboot header
section .multiboot
align 4
    dd MultibootMagic
    dd MultibootFlags
    dd MultibootChecksum

; Read only data
section .rodata
    gdt:
    .null:
        dq      0
    .kernelCode:
        dw      0xFFFF ; Limit
        dw      0 ; Base
        db      0 ; Base
        db      0b1001_1010 ; Present, privilege 0, code, readable, nonconforming
        db      0b1100_1111 ; 4kiB granularity, 32 bit, limit
        db      0 ; Base
    .kernelData:
        dw      0xFFFF ; Limit
        dw      0 ; Base
        db      0 ; Base
        db      0b1001_0010 ; Present, privilege 0, data, expand down, writable, nonconforming
        db      0b1100_1111 ; 4kiB granularity, 32 bit, limit
        db      0 ; Base
    .userCode:
        dw      0xFFFF ; Limit
        dw      0 ; Base
        db      0 ; Base
        db      0b1111_1010 ; Present, privilege 3, code, readable, nonconforming
        db      0b1100_1111 ; 4kiB granularity, 32 bit, limit
        db      0 ; Base
    .userData:
        dw      0xFFFF ; Limit
        dw      0 ; Base
        db      0 ; Base
        db      0b1111_0010 ; Present, privilege 3, data, expand down, writable, nonconforming
        db      0b1100_1111 ; 4kiB granularity, 32 bit, limit
        db      0 ; Base
    .end:

    .desc:
        db      gdt.end - gdt
        dd      gdt

; Data, uninitialized
section .bss
align 16
    stackBottom:
        resb    16384
    stackTop:

; Code
section .text
    global _start:function (_start.end - _start)
    extern _init
    extern kernelMain
    extern terminalInitialize
    extern panic

    _start:
        cli
        mov     esp, stackTop ; set up stack
        push    eax ; first things first, push eax and ebx before they get
        push    ebx ; clobbered
        xor     ax, ax ; zero ax
        mov     ds, ax ; move 0 to data segment
        lgdt    [gdt.desc] ; load GDT
        call    _init
        call    terminalInitialize ; initialize terminal so we can panic
        ; nothing before this point can take arguments
        call    kernelMain
        ; If kernelMain ever returns, spin forever
        cli
    .hang:
        hlt
        jmp     .hang
    .end:
