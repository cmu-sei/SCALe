#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <limits.h>

int compute_int_average(int* list) {
    int sum = 0;
    int count = 0;

    if(list == NULL || list[0] == 0) {
        return 0;
    }

    while(*list != 0) {
        if (INT_MAX - sum < *list) {
            printf("Sum too large!\n");
            exit(1);
        }
        sum += *list;
        list++;
        count++;
    }
   
    return sum / count;
}

void read_integer(char *s, int *val) {
    if(val == NULL) {
        return;
    }
    sscanf(s, "%d", val);
}

int main(int argc, char **argv) {
    int list[10];
    int result;

    for (int i = 0; i < 10; i++) {
        if (i+1 >= argc) {
            break;
        }
        read_integer(argv[i+1], &list[i]);
        if (list[i] <= 0) {
            break;
        }
    }

    result = compute_int_average(list);
    printf("Result is: %d\n", result);
    return 0;
}
