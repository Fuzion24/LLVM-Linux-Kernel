#include <stdio.h>
#include <string.h>
#include "util.h"

#define vla_struct(structname) size_t structname##__##next = 0
#define vla_struct_size(structname) structname##__##next

#define vla_item(structname, type, name, n) \
	type * structname##_##name; \
	size_t structname##_##name##__##pad = (structname##__##next & (__alignof__(type)-1)); \
	size_t structname##_##name##__##offset = structname##__##next + structname##_##name##__##pad; \
	size_t structname##_##name##__##sz = n * sizeof(type); \
	structname##__##next = structname##__##next + structname##_##name##__##pad + structname##_##name##__##sz; 

#define vla_ptr(ptr,structname,name) structname##_##name = (__typeof__(structname##_##name))&ptr[structname##_##name##__##offset]

TESTFUNC(NOVLAIS)
{
	vla_struct(foo);
		vla_item(foo, TYPEA, vara, a);
		vla_item(foo, TYPEB, varb, b);
		vla_item(foo, TYPEC, varc, c);
		vla_item(foo, TYPED, vard, d);

	ptr->size = vla_struct_size(foo);

	vla_ptr(ptr->buffer, foo, vara);
	vla_ptr(ptr->buffer, foo, varb);
	vla_ptr(ptr->buffer, foo, varc);
	vla_ptr(ptr->buffer, foo, vard);

	ptr->offsets = offsets(0, foo_varb__offset, foo_varc__offset, foo_vard__offset);

	memset(ptr->buffer, 0, ptr->size);
	memset(foo_vard, 4, foo_vard__sz);
	memset(foo_varc, 3, foo_varc__sz);
	memset(foo_varb, 2, foo_varb__sz);
	memset(foo_vara, 1, foo_vara__sz);
}
