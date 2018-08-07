#include <stdio.h>

void read_integer(char *s, int *val) {
    if(val == NULL) {
        return;
    }
    sscanf(s, "%d", val);
}

int main(int argc, char **argv) {
    int val;
    int result;

    if(argc != 2) {
        printf("Usage: %s <integer>\n", argv[0]);
        return 1;
    }

    read_integer(argv[1], &val);
    result = val * val;
    printf("%d\n", result);
    return 0;
}
