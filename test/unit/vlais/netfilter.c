#include <stdio.h>
 
#define padbytes(offset, type) ((-offset) & (__alignof__(type)-1))

/* tbl2 has the following structure equivalent, but without using VLAIS:
 * struct {
 *	struct type##_replace repl;
 *	struct type##_standard entries[nhooks];
 *	struct type##_error term;
 * } *tbl2;
 */

struct foo_replace {
	int a;
	char b;
};

struct foo_standard {
	char a[3];
	int  b;
};

struct foo_error {
	int a;
};

#if !defined(__clang__)
#define xt_alloc_initial_table(type) ({ \
	unsigned int nhooks = 4; \
 	struct { \
 		struct type##_replace repl; \
		struct type##_standard entries[nhooks]; \
		struct type##_error term; \
	} *tbl = malloc(sizeof(*tbl)); \
	printf("tbl size %d\n", sizeof(*tbl)); \
	free(tbl); \
})
#endif


#define xt_alloc_initial_table2(type) ({ \
	unsigned int nhooks = 4; \
 	struct { \
 		struct type##_replace repl; \
		char data[0]; \
	} *tbl2; \
	size_t p1 = padbytes(sizeof(tbl2->repl), struct type##_standard); \
	size_t ost = sizeof(tbl2->repl) + p1 + nhooks * sizeof(struct type##_standard); \
	size_t p2 = padbytes(ost, struct type##_error); \
	size_t tbl_sz = ost + p2 + sizeof(struct type##_error); \
	tbl2 = malloc(sizeof(tbl_sz)); \
	printf("tbl2 size %d\n", tbl_sz); \
	free(tbl2); \
})

int main()
{
	struct foo_standard *bar;
#if !defined(__clang__)
	xt_alloc_initial_table(foo);
#endif
	xt_alloc_initial_table2(foo);
	printf("Sz %d %d\n", sizeof(*bar), sizeof(struct foo_standard));
}


