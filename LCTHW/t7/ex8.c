#include<stdio.h>

int main(int argc, char* argv[])
{
	char chr[5] = {'a','b','\0'};
	int num[10] = {1,2,3,4,5};
	printf("%d\n",chr[0] * num[1]);
	num[1] = 100;
	printf("%d\n", num[1]);
	chr[1] ="sharp";
	printf("%c\n", chr[1]);

	return 0;
}

