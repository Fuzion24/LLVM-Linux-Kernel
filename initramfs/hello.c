#include <stdio.h>
#include <unistd.h>


int main()
{
	printf("Hello. This is a simple initramfs.\n");

	while(1) {
		// Using usleep(10,000,000) for 10 sec sleep
		// FIXME - sleep(10) causes a hang
		usleep(10000000);
		printf("Still here...\n");
	}
}
