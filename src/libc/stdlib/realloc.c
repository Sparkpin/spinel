#include <stddef.h>
#include <stdio.h>

#ifdef __LIBCKERN
#include <spinel/alloc.h>
#endif

void* realloc(void* ptr, size_t size) {
    #ifdef __LIBCKERN
        return krealloc(ptr, size);
    #else
        printf("realloc not implemented for hosted\n");
        (void)size;
        (void)ptr;
        return NULL;
    #endif // def __LIBCKERN
}