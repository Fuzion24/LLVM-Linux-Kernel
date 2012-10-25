#include <stdio.h>
#include <stddef.h>
#include <string.h>

extern void printHex(char *buffer, size_t size);

long vlais(int a, int b, int c, int d)
{
	struct vlais {
		char a[a];
		short b[b];
		int c[c];
		long d[d];
	} v;

/*
	long ret1 = ((long)&v.a - (long)&v) << 24;
	ret1 |= ((long)&v.b - (long)&v) << 16;
	ret1 |= ((long)&v.c - (long)&v) << 8;
	ret1 |= ((long)&v.d - (long)&v);
	printf("vlais: 0x%08X (%d)\n", (unsigned int)ret1, sizeof(struct vlais));
*/

	long ret = offsetof(struct vlais, a) << 24;
	ret |= offsetof(struct vlais, b) << 16;
	ret |= offsetof(struct vlais, c) << 8;
	ret |= offsetof(struct vlais, d);
	printf("vlais:    0x%08X (%ld)\n", (unsigned int)ret, sizeof(struct vlais));

	memset(&v, 0, sizeof(v));
	memset(v.d, 4, d*sizeof(long));
	memset(v.c, 3, c*sizeof(int));
	memset(v.b, 2, b*sizeof(short));
	memset(v.a, 1, a*sizeof(char));
	printHex((char*)&v, sizeof(v));

	return ret;
}
