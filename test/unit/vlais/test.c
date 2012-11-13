#include <stdio.h>
#include <stdlib.h>
#include <time.h>

extern int vlais(int a, int b, int c, int d, int p);
/*
extern int novlais_gcc(int a, int b, int c, int d);
extern int novlais_clang(int a, int b, int c, int d);
*/

#define QUOTEME(x) #x
#define vlais_args 1, 2, 3, 3
#define NO_VLAIS_TEST(name) \
extern int name ## _gcc(int, int, int, int, int); \
extern int name ## _clang(int, int, int, int, int); \
void test_ ## name (int soln) { \
	long ret = name ## _gcc(vlais_args, 1); \
	if (ret != soln) { \
		printf("FAIL: " QUOTEME(name) " doesn't work with gcc\n"); \
		exit(1); \
	} else { \
		printf("PASS: " QUOTEME(name) " with gcc\n"); \
	} \
\
	ret = name ## _clang(vlais_args, 1); \
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

#define runtime(func) \
	do { \
		time_t before, after; \
		time(&before); \
		unsigned long i; \
		for(i=1000000000L; i; i--) \
			func(vlais_args, 0); \
		time(&after); \
		printf(QUOTEME(func) " took %ld secs\n", after-before); \
	} while(0)

int main(void)
{
	long test1 = vlais(vlais_args, 1);
	printf("PASS: vlais with gcc\n");

	test_novlais(test1);
	test_novlais1(test1);
	test_novlais2(test1);

	runtime(vlais);
	runtime(novlais2_gcc);
	runtime(novlais2_clang);

	return 0;
}
