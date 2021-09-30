#include <stdio.h>
#include <stdlib.h>

typedef struct {
    size_t weight;
    size_t height;
} record_t;

record_t *new_record() {
    record_t *result, *result2, *result3;
    result = malloc(sizeof(record_t));
    result2 = malloc(sizeof(record_t));
    result3 = malloc(sizeof(record_t));
    return result; 
}

void set_height(record_t *rec, int height) {
    rec->height = height;
}

void set_weight(record_t *rec, int weight) {
    rec->weight = weight;
}

int main(int argc, char **argv) {
    record_t *record = new_record();
    set_height(record, 70);
    set_weight(record, 160);
    free(record);
    return 0;
}
