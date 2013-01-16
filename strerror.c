#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
	int e;
	const char usage[] = "usage: strerror N\n";

	if(argc != 2) {
		goto usage;
	}
	
	e = strtol(argv[1], NULL, 10);
	if(e == 0) 
		goto usage;

	printf("errno of %d: %s\n", e, strerror(e));

	return 0;
usage:
	printf(usage);
	return 1;
}