#include <stdio.h>
#include <string.h>

extern void printHex(char *buffer, size_t size);

#define vla_struct(structname) size_t structname##__##next = 0
#define vla_struct_size(structname) structname##__##next

	//size_t pad_##structname##_##name = (~__alignof__(type)) & (next_##structname & (__alignof__(type)-1)); 
#define vla_item(structname, type, name, n) \
	type * structname##_##name; \
	size_t structname##_##name##__##pad = (structname##__##next & (__alignof__(type)-1)); \
	size_t structname##_##name##__##offset = structname##__##next + structname##_##name##__##pad; \
	size_t structname##_##name##__##sz = n * sizeof(type); \
	structname##__##next = structname##__##next + structname##_##name##__##pad + structname##_##name##__##sz; 

#define vla_ptr(ptr,structname,name) structname##_##name = (typeof(structname##_##name))&ptr[structname##_##name##__##offset]

long NOVLAIS(int a, int b, int c, int d, int p)
{
	vla_struct(foo);
		vla_item(foo, char,  vara, a);
		vla_item(foo, short, varb, b);
		vla_item(foo, int,   varc, c);
		vla_item(foo, long,  vard, d);

	size_t total = vla_struct_size(foo);
	char buffer[total];

	vla_ptr(buffer, foo, vara);
	vla_ptr(buffer, foo, varb);
	vla_ptr(buffer, foo, varc);
	vla_ptr(buffer, foo, vard);

	long ret = 0 | foo_varb__offset<<16 | foo_varc__offset<<8 | foo_vard__offset;
	if(p) printf("no-vlais: 0x%08X (%ld:%ld)\n", (int)ret, total, sizeof(buffer));

	memset(buffer, 0, sizeof(buffer));
	memset(foo_vard, 4, d*sizeof(long));
	memset(foo_varc, 3, c*sizeof(int));
	memset(foo_varb, 2, b*sizeof(short));
	memset(foo_vara, 1, a*sizeof(char));
	if(p) printHex(buffer, sizeof(buffer));

	return ret;
}
