#include <stdio.h>

#define get_sp(var) asm ("mov %0, r13" : "=r" (var))

int main()
{
	register unsigned long int sp asm("sp");
	register unsigned long int sp2;

	// Test the GCC extension
	printf("sp = %lu\n", sp);

	get_sp(sp2);
	printf("sp = %lu\n", sp2);

	return 0;
}

