#include <stdio.h>
#include <string.h>

extern void printHex(char *buffer, size_t size);

#define paddedsize(offset,name,type,n) \
	type *name; \
	size_t pad_##name = (~__alignof__(type)) & (offset % __alignof__(type)); \
	size_t offset_##name = offset + pad_##name; \
	size_t sz_##name = n * sizeof(type); \
	size_t next_##name = offset + pad_##name + sz_##name; 
	
#define paddedstart(ptr,name) name = (typeof(name))&ptr[offset_##name]

long NOVLAIS(int a, int b, int c, int d, int p)
{
	paddedsize(0,          var_a, char,  a);
	paddedsize(next_var_a, var_b, short, b);
	paddedsize(next_var_b, var_c, int,   c);
	paddedsize(next_var_c, var_d, long,  d);
	size_t total = next_var_d;
	char buffer[total];

	//printf("real sizes: a:%ld b:%ld c:%ld d:%ld\n", a*sizeof(char), b*sizeof(short), c*sizeof(int), d*sizeof(long));
	//printf("calc sizes: a:%d b:%d c:%d d:%d\n", (int)sz_var_a, (int)sz_var_b, (int)sz_var_c, (int)sz_var_d);

	paddedstart(buffer, var_a);
	paddedstart(buffer, var_b);
	paddedstart(buffer, var_c);
	paddedstart(buffer, var_d);

	long ret = 0 | offset_var_b<<16 | offset_var_c<<8 | offset_var_d;
	if(p) printf("no-vlais: 0x%08X (%ld:%ld)\n", (int)ret, total, sizeof(buffer));

	memset(buffer, 0, sizeof(buffer));
	memset(var_d, 4, d*sizeof(long));
	memset(var_c, 3, c*sizeof(int));
	memset(var_b, 2, b*sizeof(short));
	memset(var_a, 1, a*sizeof(char));
	if(p) printHex(buffer, sizeof(buffer));

	return ret;
}
