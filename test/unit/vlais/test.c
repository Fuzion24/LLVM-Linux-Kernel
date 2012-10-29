#include <stdio.h>
#include <stdlib.h>

extern int vlais(int a, int b, int c, int d);
extern int novlais_gcc(int a, int b, int c, int d);
extern int novlais_clang(int a, int b, int c, int d);

int main(void)
{
	long test1 = vlais(1, 2, 3, 3);
	printf("PASS: vlais with gcc\n");

	long test2 = novlais_gcc(1, 2, 3, 3);
	if (test1 != test2) {
		printf("E: no-vlais.c doesn't work with gcc\n");
		exit(1);
	} else {
		printf("PASS: no-vlais with gcc\n");
	}
	
	long test3 = novlais_clang(1, 2, 3, 3);
	if (test1 != test3) {
		printf("E: no-vlais.c doesn't work with clang\n");
		exit(1);
	} else {
		printf("PASS: no-vlais with clang\n");
	}
	
	return 0;
}
