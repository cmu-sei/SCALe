#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

int main(int argc, char **argv) {
    // The malloc() and calloc() functions return a pointer to the allocated
    // memory, which is suitably aligned for any built-in type
    uint8_t *bytes = (uint8_t*) malloc(256);
    uint32_t *four_byte_chunks = (uint32_t*)(bytes);
    //...
    free(bytes);
    return 0;
}
