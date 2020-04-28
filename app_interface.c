#include <stdio.h>

#include "app_interface.h"


#pragma weak app_main

int app_main(int argc, char* argv[])
{

    printf("Hello World on stdout!\n");
    fprintf(stderr, "Hello World on stderr!\n");

    return 0;
}

// eof

