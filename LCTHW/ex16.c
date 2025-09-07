#include<stdio.h>
#include<stdlib.h>
#include<assert.h>
#include<string.h>

struct Person {
	char *name;
	int age;
	int height;
	int weight;
};

struct Person *Person_create(char *name, int age, int height, int weight)
{
	struct Person *who = malloc(sizeof(struct Person));
	assert(who != NULL);
	
	who->name = strdup(name);
	who->age = age;
	who->height = height;
	who->weight = weight;

	return who;
}	
	

void Person_destroy(struct Person *who)
{
	assert(who != NULL);

	free(who->name);
	free(who);
}

void Person_print(struct Person *who)
{
	printf("Name is %s\n", who->name);
	printf("age is %d\n", who->age);
	printf("height is %d cm\n", who->height);
	printf("weight is %d kg.\n", who->weight);
}

int main(int argc, char *argv[])
{
	struct Person *Jon = Person_create("Jon", 18, 183, 71);
	Person_print(Jon);
	Person_destroy(Jon);
	printf("Jon's location is %p\n", Jon);

	return 0;
}

