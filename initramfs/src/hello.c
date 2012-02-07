#include <stdio.h>
#include <unistd.h>


int main()
{
	printf("Hello. This is a simple initramfs.\n");

	while(1) {
		sleep(30);
		printf("Still here...\n");
	}
}
