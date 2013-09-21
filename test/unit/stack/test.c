#include <stdio.h>

int main()
{
	int foo = 1;

	printf("&foo = %p sp = %p\n", &foo, __builtin_stack_pointer());
}
