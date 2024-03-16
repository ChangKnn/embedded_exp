#include <linux/fs.h>
#include <time.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>

int main()
{
	char buffer[3];
	int count;
	int fd;
	int q;
	int res;

	for (q=0;q<3;q++)
	{
		buffer[q]=0x00;
	}
	fd = open("/dev/position", 0);
	if (fd < 0 )
		printf("\n Device open error\n");

	res = read(fd, buffer, 3);

  setbuf(stdout, NULL);
  for (int i = 0; i < 100; i++) {
    printf("%i,%i,%i\n",buffer[0],buffer[1],buffer[2] );
    usleep(500000);
  }


	close(fd);
	return 0;
}
