#include <stdio.h>

typedef void (*callback_t)(int);

void perform_action(int value, callback_t cb) {
    printf("C: Performing action with value %d...\n", value);
    cb(value * 2);
}
