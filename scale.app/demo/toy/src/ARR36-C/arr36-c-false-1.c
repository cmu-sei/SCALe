#include <stdio.h>
#include <stdlib.h>

int *min(int* list) {
    if(list == NULL || list[0] == 0) {
        return NULL;
    }

    int *min_addr = list;
    list++;
    while(*list != 0) {
        if(*list < *min_addr) {
            min_addr = list;
        }
        list++;
    }
    return min_addr;
}

int *max(int* list) {
    if(list == NULL || list[0] == 0) {
        return NULL;
    }

    int *max_addr = list;
    list++;
    while(*list != 0) {
        if(*list > *max_addr) {
            max_addr = list;
        }
        list++;
    }
    return max_addr;
}

int main(int argc, char **argv) {
    int list[] = {10, 0};
    int *min_addr = min(list);
    int *max_addr = max(list);
    if(min_addr != NULL && max_addr != NULL) {
        int diff = max_addr - min_addr;
        if(diff == 0) {
            printf("The min and max are the same!\n");
        }
    }
    return 0;
}
