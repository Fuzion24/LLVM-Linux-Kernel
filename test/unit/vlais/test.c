#include <stdio.h>

extern int vlais(int a, int b, int c, int d);
extern int novlais_gcc(int a, int b, int c, int d);
extern int novlais_clang(int a, int b, int c, int d);

int main(void)
{
	long test1 = vlais(1, 2, 3, 3);
	long test2 = novlais_gcc(1, 2, 3, 3);
	long test3 = novlais_clang(1, 2, 3, 3);
	return 0;
}
