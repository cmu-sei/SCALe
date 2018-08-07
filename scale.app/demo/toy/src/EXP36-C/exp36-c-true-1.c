#include <stdio.h>
#include <stdint.h>

struct FourByteValue {
    char b1;
    char b2;
    char b3;
    char b4;
};

int main(int argc, char **argv) {
    struct FourByteValue val;
    val.b1 = 0x25;
    val.b2 = 0x4b;
    val.b3 = 0xd5;
    val.b4 = 0xa4;
    int *int_ptr = (int*)(&val.b1);
    printf("%d\n", *int_ptr);
    return 0;
}
