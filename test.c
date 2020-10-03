#include<stdio.h>
#include<stdlib.h>
#include<unistd.h>

int main(void)
{
    int pid;
    pid = fork();
	if (pid == 0) {execl("/usr/bin/xterm",NULL);}

}
