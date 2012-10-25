#include <stdio.h>
#include <string.h>
#include "valign.h"

extern void printHex(char *buffer, size_t size);

//#define truncalign(num,padwidth) ((long)(num) & ~((padwidth)-1))
//#define padalign(num,padwidth) truncalign((long)(num) + ((padwidth)-1), padwidth)
//#define paddedsize(offset,n,type,nexttype) (padalign((offset) + (n) * sizeof(type), __alignof__(nexttype)) - (offset))
//#define paddedstart(ptr,offset,type) (type *)padalign((long)ptr+(offset),__alignof__(type))

long NOVLAIS(int a, int b, int c, int d)
{
	struct foo {
		int a;
		char *b[];
	} foobar;

	size_t sa = paddedsize(0, a,char,short);
	size_t sb = paddedsize(sa, b,short,int);
	size_t sc = paddedsize(sa+sb,c,int,long);
	size_t sd = paddedsize(sa+sb+sc,d,long,long);
	size_t total = sa+sb+sc+sd;
	char buffer[total];
	printf("real sizes: a:%ld b:%ld c:%ld d:%ld\n", a*sizeof(char), b*sizeof(short), c*sizeof(int), d*sizeof(long));
	printf("calc sizes: a:%d b:%d c:%d d:%d\n", (int)sa, (int)sb, (int)sc, (int)sd);

	char *aa = paddedstart(buffer, 0, char);
	short *bb = paddedstart(aa, sa, short);
	int *cc = paddedstart(bb, sb, int);
	long *dd = paddedstart(cc, sc, long);
	long long *ee = paddedstart(dd, sd, long long);

	//printf("Bottom bits: %02X %02X %02X %02X 0x%ld\n", (int)aa&0x3, (int)bb&0x3, (int)cc&0x7, (int)dd&0x7, (long)ee-(long)aa);
	//printf("Bottom bits: %02lX %02lX %02lX %02lX 0x%ld\n", (long)aa-(long)aa, (long)bb-(long)aa, (long)cc-(long)aa, (long)dd-(long)aa, (long)ee-(long)aa);
	//printf("Start a: 0x%04x\n", (int)paddedstart(NULL, 0, char));
	//printf("Start b: 0x%04x\n", (int)paddedstart(NULL, sa, short));
	//printf("Start c: 0x%04x\n", (int)paddedstart(NULL, sb, int));
	//printf("Start d: 0x%04x\n", (int)paddedstart(NULL, sc, long));

	long ret = 0 | sa<<16 | (sa+sb)<<8 | (sa+sb+sc);
	printf("no-vlais: 0x%08X (%ld:%ld)\n", (int)ret, total, sizeof(buffer));

	memset(buffer, 0, sizeof(buffer));
	memset(dd, 4, d*sizeof(long));
	memset(cc, 3, c*sizeof(int));
	memset(bb, 2, b*sizeof(short));
	memset(aa, 1, a*sizeof(char));
	printHex(buffer, sizeof(buffer));

	return ret;
}
