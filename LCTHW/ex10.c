#include<stdio.h>

int main(int argc, char *argv[])
{
	int i = 0;
	argv[1] = "make";
	for(i = 0; i < argc; i++)
	{
		printf("arg %d: %s\n", i, argv[i]);
	}

	return 0;
}

