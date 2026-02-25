#include <stdio.h>

typedef struct {
    int x;
    int y;
} Point;

void greet(const char* name, Point* p) {
    printf("Hello, %s! Your point is at (%d, %d)\n", name, p->x, p->y);
}
