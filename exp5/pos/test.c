#include <linux/fs.h>
#include <stdio.h>
int main()
{
	char buffer[64];
	int count;
	int fd;
	int q;
	int res;

	for (q=0;q<8;q++)
	{
		buffer[q]=0x55;
	}
	fd = open("/dev/mydev", 0);
	if (fd < 0 )
		printf("\n Device open error\n");

	res = read(fd, buffer, 8);
	
	printf("\nRead result = %d\n",res);

	for (q=0;q<8;q++)
	{
		printf("%02X ", buffer[q]);
	}
	printf("\n");
	close(fd);
	return 0;
}

