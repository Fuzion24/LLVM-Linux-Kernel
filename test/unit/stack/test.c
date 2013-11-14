#include <stdio.h>

int main()
{
	printf("sp = %p\n", __builtin_stack_pointer());
}
