#include <stdio.h>
#include <string.h>

typedef struct {
    char* name;
    int age;
} Person;

void print_person(Person* p) {
    if (p == NULL) return;
    printf("C says: Person is %s, age %d\n", p->name, p->age);
}

void have_birthday(Person* p) {
    if (p == NULL) return;
    p->age += 1;
    printf("C says: Happy Birthday %s! You are now %d.\n", p->name, p->age);
}
