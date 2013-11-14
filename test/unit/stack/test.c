#include <stdio.h>

#define xxx() 
int main()
{
#if 0
	register unsigned long r13 asm("r13");
	asm("" : "=r"(r13));
	register unsigned long foo asm("sp");
        asm("" : "=r"(foo));
	printf("sp = %p\n", r13);
#endif

	printf("sp = %p\n", __builtin_stack_pointer());
}
