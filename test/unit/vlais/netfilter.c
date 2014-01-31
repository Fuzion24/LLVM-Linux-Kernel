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
	char a;
};

struct foo_error {
	short int a;
	char b;
};

#if !defined(__clang__)
#define xt_alloc_initial_table(type) ({ \
	unsigned int nhooks = 5; \
 	struct { \
 		struct type##_replace repl; \
		struct type##_standard entries[nhooks]; \
		struct type##_error term; \
	} *tbl = malloc(sizeof(*tbl)); \
	printf("tbl size %d\n", sizeof(*tbl)); \
	printf("offset of entries %d\n", (void *)&tbl->entries[0]-(void *)tbl); \
	printf("offset of term %d\n", (void *)&tbl->term-(void *)tbl); \
	printf("repl size %d\n", sizeof(tbl->repl)); \
	printf("entry size %d\n", sizeof(tbl->entries[0])); \
	printf("term size %d\n", sizeof(tbl->term)); \
	free(tbl); \
})
#endif


#define xt_alloc_initial_table2(type) ({ \
	unsigned int nhooks = 5; \
 	struct { \
 		struct type##_replace repl; \
		char data[0]; \
	} *tbl2; \
	struct type##_standard *entries; \
	struct type##_error *term; \
	size_t pad1 = padbytes(sizeof(tbl2->repl), *entries); \
	size_t offset = pad1 + nhooks * sizeof(*entries); \
	size_t pad2 = padbytes(sizeof(tbl2->repl)+offset, *term); \
	size_t offset2 = offset + pad2 + sizeof(*term); \
	size_t pad3 = padbytes(sizeof(tbl2->repl)+offset2, tbl2->repl); \
	size_t tbl_sz = sizeof(tbl2->repl) + offset2 + pad3; \
	tbl2 = malloc(sizeof(tbl_sz)); \
	entries = (struct type##_standard *)&tbl2->data[pad1]; \
	term = (struct type##_error *)&tbl2->data[offset+pad2]; \
	printf("tbl2 size %d\n", tbl_sz); \
	printf("offset of entries %d\n", (void *)entries-(void *)tbl2); \
	printf("offset of term %d\n", (void *)term-(void *)tbl2); \
	printf("p1 %d p2 %d p3 %d\n", pad1, pad2, pad3); \
	printf("repl size %d\n", sizeof(tbl2->repl)); \
	printf("entry size %d\n", sizeof(entries[0])); \
	printf("term size %d\n", sizeof(*term)); \
	free(tbl2); \
})

int main()
{
	struct foo_standard *bar;
#if !defined(__clang__)
	xt_alloc_initial_table(foo);
	printf("------------\n");
#endif
	xt_alloc_initial_table2(foo);
	printf("Sz %d %d\n", sizeof(*bar), sizeof(struct foo_standard));
}


