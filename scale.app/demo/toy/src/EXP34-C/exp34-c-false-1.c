#include <stdio.h>
#include <stdlib.h>

static void (*exit_function)(int rc);

typedef struct {
    size_t weight;
    size_t height;
} record_t;

record_t *new_record() {
    record_t *result;
    result = malloc(sizeof(record_t));
    return result; 
}

void set_height(record_t *rec, int height) {
    rec->height = height;
}

void set_weight(record_t *rec, int weight) {
    rec->weight = weight;
}

void print_msg_and_abort(int rc) {
    printf("Terminating the program!\n");
    exit(rc);
}

int main(int argc, char **argv) {
    exit_function = print_msg_and_abort;
    record_t *record = new_record();
    if(record == NULL) {
        exit_function(1);
    }
    set_height(record, 70);
    set_weight(record, 160);
    free(record);
    return 0;
}
