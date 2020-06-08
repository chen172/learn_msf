#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv[])
{
    printf("0x%x\n", inet_addr(argv[1]));
    return 0;
}
