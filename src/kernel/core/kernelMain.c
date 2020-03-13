#include <stdio.h>
#include <spinel/alloc.h>
#include <spinel/cpu.h>
#include <spinel/tty.h>
#include <spinel/zero.h>
#include <spinel/vfs.h>

void kernelMain(void) {
    printf("The system is coming up.\n");
    initAlloc();
    initVFS();
    initDevZero();
    printf("Opening /zero\n");
    VNode* zero = vfsOpen("/zero");
    uint8_t myBuf[] = {1, 2, 3, 4, 5};
    printf("Here is my buffer with random data: ");
    printf("%u %u %u %u %u\n", myBuf[0], myBuf[1], myBuf[2], myBuf[3], myBuf[4]);
    zero->readCallback(zero, myBuf, 5);
    printf("Here is my buffer after reading from /zero: ");
    printf("%u %u %u %u %u\n", myBuf[0], myBuf[1], myBuf[2], myBuf[3], myBuf[4]);

    while (1) {
        haltCPU();
    }
}
