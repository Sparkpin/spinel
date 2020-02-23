MultibootModuleAlign equ 1 ; align modules on page boundaries
MultibootMemoryInfo equ 1 << 1 ; provide a memory map
MultibootMagic equ 0x1BADB002
MultibootFlags equ MultibootModuleAlign | MultibootMemoryInfo
MultibootChecksum equ -(MultibootMagic + MultibootFlags)

KernelOffset equ 0xC0000000
PresentFlag equ 1
ReadWriteFlag equ 1 << 1
UserModeFlag equ 1 << 2
WriteThroughFlag equ 1 << 3
CacheDisableFlag equ 1 << 4
AccessedFlag equ 1 << 5
DirtyFlag equ 1 << 6
LargePageFlag equ 1 << 7
GlobalFlag equ 1 << 8

; Multiboot header
section .multiboot
align 4
    dd MultibootMagic
    dd MultibootFlags
    dd MultibootChecksum

; Data, uninitialized
section .bss
align 16
    stackBottom:
        resb    16384
    stackTop:

; Data, initialized
section .data
align 4096
    global kernelPageTable
    global kernelPageDirectory
    kernelPageTable:
        %assign i 0
        %rep    1024
            dd      (i * 0x1000) | PresentFlag | ReadWriteFlag
            %assign i i+1
        %endrep
    kernelPageDirectory:
        dd      kernelPageTable - KernelOffset + 0x03
        times 767 dd 0
        dd      kernelPageTable - KernelOffset + 0x03
        times 254 dd 0
        dd      kernelPageDirectory - KernelOffset + 0x03

; Code
section .text
    global _start:function
    extern _init
    extern archBoot
    extern kernelMain

    _start:
        cli
        ; First: set up paging
        mov     esp, stackTop - KernelOffset ; set up temp stack
        ; eax = magic number, ebx = multiboot info
        ; unfortunately, eax is volatile. edi isn't, so let's use that
        mov     edi, eax
        ; load the page directory... no mov cr3, immediate here
        mov     eax, kernelPageDirectory - KernelOffset
        mov     cr3, eax
        ; Now enable paging
        mov     eax, cr0
        or      eax, 1 << 31
        mov     cr0, eax
        ; let's go to our paged code
        lea     ecx, [.pagingDone]
        jmp     ecx
    .pagingDone:
        ; We can't cut the identity mapping yet because of the multiboot struct
        mov     esp, stackTop ; set up stack
        call    _init
        push    edi
        push    ebx
        call    archBoot ; go to C land to continue booting
        call    kernelMain ; Finally, let's go to the actual kernel!
        ; If kernelMain ever returns, spin forever
        cli
    .hang:
        hlt
        jmp     .hang