#include <stdio.h>

int main()
{
	register unsigned long sp asm("sp");

	printf("sp = %p\n", sp);
}
