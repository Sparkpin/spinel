#ifndef ARCH_I386_PAGING_H
#define ARCH_I386_PAGING_H

#include <stdbool.h>
#include <stdint.h>
#include <kernel/memory.h>
#include "../cpu.h"

// This isn't C++, so this is what we get for generics
#define PageAlign(addr) (addr & ~0x0FFF)
// This page if it's already page aligned, otherwise the next page
#define NearestPage(addr) ((addr & 0x0FFF) == 0 ? addr : (PageAlign(addr) + PageSize))
// The next page, no matter what
#define NextPage(addr) (PageAlign(addr) + PageSize)

static const uintptr_t KernelOffset = 0xC0000000;
static const uintptr_t KernelPageMapOffset = 0xFFC00000;

typedef enum {
    PagePresentFlag = 1,
    PageReadWriteFlag = 1 << 1,
    PageUserModeFlag = 1 << 2,
    PageWriteThroughFlag = 1 << 3,
    PageCacheDisableFlag = 1 << 4,
    PageAccessedFlag = 1 << 5,
    PageDirtyFlag = 1 << 6,
    PageLargePageFlag = 1 << 7,
    PageGlobalFlag = 1 << 8
} PageFlags;

extern void setCR3(uintptr_t* addr);
extern uintptr_t* getCR3();
extern uintptr_t* getCR2();
// Takes a linear address. Invalidates the page in the TLB
extern void invalidatePage(void* page);

// Makes .text and .rodata read-only alongside cutting the identity mapping
void improveKernelPageStructs();
// Create page directory/directory pointer table/level 1 million table
// Clones kernel mappings into it and maps the page directory somewhere.
// Returns physical address to new page directory to be shunted into CR3.
uintptr_t newTopPageMap(uintptr_t flags);
void mapPageAt(uintptr_t physical, uintptr_t virtual, uintptr_t flags);
void unmapPage(uintptr_t virtual);
void handlePageFault(ExceptionRegisters regs, unsigned int errorCode);

static inline uintptr_t getPhysicalAddr(uintptr_t addr){
    return addr - KernelOffset;
}

#endif // ndef ARCH_I386_PAGING_H
