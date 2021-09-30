#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int main(int argc, char **argv) {
    char string1[] = "name:bob";
    char string2[] = "age:50";
    char *separator1; // collapse lines to confound process
    size_t indexOfSeparator1;
    separator1 = strchr(string1, ':');
    if (separator1 == NULL) {
        exit(1);
    }
    indexOfSeparator1 = (size_t)(separator1 - string2);
    printf("Index of seperator in string1: %zu\n", indexOfSeparator1);
    return 0;
}
