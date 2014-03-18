#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>
 
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
	printf("tbl size %lu\n", sizeof(*tbl)); \
	printf("offset of entries %lu\n", (void *)&tbl->entries[0]-(void *)tbl); \
	printf("offset of term %lu\n", (void *)&tbl->term-(void *)tbl); \
	printf("repl size %lu\n", sizeof(tbl->repl)); \
	printf("entry size %lu\n", sizeof(tbl->entries[0])); \
	printf("term size %lu\n", sizeof(tbl->term)); \
	free(tbl); \
})
#endif


#define xt_alloc_initial_table2(type) ({ \
	unsigned int nhooks = 5; \
 	struct { \
 		struct type##_replace repl; \
		struct type##_standard entries[]; \
	} *tbl2; \
	struct type##_error *term; \
	size_t entries_end = offsetof(typeof(*tbl2), entries[nhooks-1])+sizeof(tbl2->entries[0]); \
	size_t term_offset = (entries_end + __alignof__(*term) - 1) & ~(__alignof__(*term) - 1); \
	size_t term_end = term_offset + sizeof(*term); \
	size_t tbl_sz = (term_end + __alignof__(tbl2->repl) - 1) & ~(__alignof__(tbl2->repl) - 1); \
	tbl2 = malloc(tbl_sz); \
	term = (struct type##_error *)&(((char *)tbl2)[term_offset]); \
	printf("tbl2 size %lu\n", tbl_sz); \
	printf("offset of entries %lu\n", (void *)&tbl2->entries[0]-(void *)tbl2); \
	printf("offset of term %lu\n", (void *)term-(void *)tbl2); \
	printf("p2 %lu p3 %lu\n", term_offset-entries_end, tbl_sz-term_end); \
	printf("repl size %lu\n", sizeof(tbl2->repl)); \
	printf("entry size %lu\n", sizeof(tbl2->entries[0])); \
	printf("term size %lu\n", sizeof(*term)); \
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
	printf("Sz %lu %lu\n", sizeof(*bar), sizeof(struct foo_standard));
}


