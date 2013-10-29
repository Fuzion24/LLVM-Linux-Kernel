#include "common.h"

#define MT_NORMAL 4

int main()
{
	u64 foo, tmp;

	asm volatile(
	"	mrs	%0, mair_el1\n"
	"	bfi	%0, %1, %2, #8\n"
	"	msr	mair_el1, %0\n"
	"	isb\n"
	: "=&r" (tmp)
	: "r" (foo), "i" (MT_NORMAL * 8));

#if 0 // This fails for clang
	asm volatile(
	"	mrs	%0, mair_el1\n"
	"	bfi	%0, %1, #%2, #8\n"
	"	msr	mair_el1, %0\n"
	"	isb\n"
	: "=&r" (tmp)
	: "r" (foo), "i" (MT_NORMAL * 8));
#endif
}
