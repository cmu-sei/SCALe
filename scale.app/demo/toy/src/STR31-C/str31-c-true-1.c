#include <stdio.h>

#define BUF_LEN 256

void build_greeting(char* name, char *buf) {
    sprintf(buf, "Hello, %s!\n", name);
}

int main(int argc, char **argv) {
    char greeting[BUF_LEN];
    if(argc != 2) {
        printf("Usage: %s <your_name>\n", argv[0]);
        return 1;
    }

    build_greeting(argv[1], greeting);
    printf("%s", greeting);
    return 0;
}
