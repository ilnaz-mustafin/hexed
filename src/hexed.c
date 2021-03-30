#include <stdio.h>
#include "libs/cli_test.h"
#include "libs/libtest.h"

int main(int argc, char *argv[])
{
    int i = 3;
    printf("This is test output from main\n");
    libtest();

    cli_test(&i);
    return 0;
}