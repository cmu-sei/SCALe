#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <limits.h>

parse(const char *str) {
    errno = 0;
    char *temp;
    long long int val = strtoll(str, &temp, 0);
    if (temp == str || *temp != '\0' || ((val == LONG_MIN || val == LONG_MAX) && errno == ERANGE)) {
        printf("Parsing failed!\n"); 
        exit(1);
    }
    return val;
}

int main(int argc, char **argv) {
    int ii;
    for(ii = 1; ii < argc; ii++) {
        const long long int parsed = parse(argv[ii]); // eliminate diagnostic
        printf("Parsed integer: %lld\n", parsed);
    }
    return 0;
}
