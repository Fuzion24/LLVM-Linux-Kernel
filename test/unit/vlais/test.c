#include <stdio.h>
#include <stdlib.h>

extern int vlais(int a, int b, int c, int d);
extern int novlais_gcc(int a, int b, int c, int d);
extern int novlais_clang(int a, int b, int c, int d);

#define QUOTEME(x) #x
#define vlais_args 1, 2, 3, 3
#define NO_VLAIS_TEST(name) \
extern int name ## _gcc(int, int, int, int); \
extern int name ## _clang(int, int, int, int); \
void test_ ## name (int soln) { \
	long ret = name ## _gcc(vlais_args); \
	if (ret != soln) { \
		printf("FAIL: " QUOTEME(name) " doesn't work with gcc\n"); \
		exit(1); \
	} else { \
		printf("PASS: " QUOTEME(name) " with gcc\n"); \
	} \
\
	ret = name ## _clang(vlais_args); \
	if (ret != soln) { \
		printf("FAIL: " QUOTEME(name) " doesn't work with clang\n"); \
		exit(1); \
	} else { \
		printf("PASS: " QUOTEME(name) " with clang\n"); \
	} \
}

NO_VLAIS_TEST(novlais)
NO_VLAIS_TEST(novlais1)
NO_VLAIS_TEST(novlais2)

int main(void)
{
	long test1 = vlais(vlais_args);
	printf("PASS: vlais with gcc\n");

	test_novlais(test1);
	test_novlais1(test1);
	test_novlais2(test1);

	return 0;
}
