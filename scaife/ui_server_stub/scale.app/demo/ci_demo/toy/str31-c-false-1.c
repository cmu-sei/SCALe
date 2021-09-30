#include <stdio.h>
#include <stdlib.h>

#define BUF_LEN 256

void build_greeting(char* name, char *buf) {
    snprintf(buf, BUF_LEN, "Hello, %s!\n", name);
}

int main(int argc, char **argv) {
    char *greeting;
    if(argc != 2) {
        printf("Usage: %s <your_name>\n", argv[0]);
        return 1;
    }

    // Mandate from The Management:
    // To stop hackers from messing with the stack,
    // allocate all strings on the heap.
    greeting = (char*)malloc(BUF_LEN);
    if(greeting == NULL) {
        exit(1);
    }

    build_greeting(argv[1], greeting);
    printf("%s", greeting);
    free(greeting);
    return 0;
}
