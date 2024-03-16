#include <linux/fs.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <pthread.h>
#include <string.h>

#define TOUPPER(x) (((x >= 'a') && (x <= 'z')) ? x - 'a' + 'A' : x)
#define TOLOWER(x) (((x >= 'A') && (x <= 'Z')) ? x - 'A' + 'a' : x)

struct cmd_buffer_type
{
	int mutex;
	int cmd_ready;
	char cmd[100];
} cmd_buffer;

void getWebResp()
{
	char ch;
	char cmd_buf[100];
	int ch_rcved = 0;
	while (1)
	{

		ch = getchar();
		ch = TOUPPER(ch);
		if (ch_rcved < 1024)
		{
			cmd_buf[ch_rcved++] = ch;
			if (ch == '\n')
			{
				cmd_buf[ch_rcved - 1] = '\0';
				cmd_buffer.mutex = cmd_buffer.mutex - 1;
				while (cmd_buffer.mutex < 0)
					;
				strcpy(cmd_buffer.cmd, cmd_buf);
				cmd_buffer.cmd_ready = 1;
				ch_rcved = 0;
				cmd_buffer.mutex = cmd_buffer.mutex + 1;
			}
		}
		else
		{
			ch_rcved = 0; // Error command,discards
		}
	}
}

int main()
{
	int bar_num;
	int qi;
	int running = 0;
	int fd;
	int res;
	char str[100];
	char webCmd[100];
	char outBuf[100];
	char buffer[3];
	pthread_t tidp;

	for (int q = 0; q < 3; q++)
	{
		buffer[q] = 0x00;
	}
	fd = open("/dev/position", 0);
	if (fd < 0)
		printf("\n Device open error\n");

	str[0] = '\0';

	cmd_buffer.mutex = 1;
	cmd_buffer.cmd_ready = 0;
	cmd_buffer.cmd[0] = '\0';
	webCmd[0] = '\0';

	if (pthread_create(&tidp, NULL, getWebResp, NULL) == -1)
	{
		printf("Creat thread error");
		return 1;
	}

	do
	{
		cmd_buffer.mutex = cmd_buffer.mutex - 1;
		while (cmd_buffer.mutex < 0)
			;
		if (cmd_buffer.cmd_ready == 1)
		{
			strcpy(webCmd, cmd_buffer.cmd);
			cmd_buffer.cmd_ready = 0;

			// STATE 1 IS GETTING POS
			if (!strcmp(webCmd, "START"))
				running = 2;
			if (!strcmp(webCmd, "STOP"))
				running = 0;
			if (strstr(webCmd, "TYPE:"))
			{
				strcpy(outBuf, "type:");
				for (qi = 5; webCmd[qi] != '\0'; qi++)
				{
					outBuf[qi] = TOLOWER(webCmd[qi]);
				}
				outBuf[qi] = '\0';
				printf("%s", outBuf);
			}
		}
		cmd_buffer.mutex = cmd_buffer.mutex + 1;

		if (running == 1)
		{
			res = read(fd, buffer, 3);
			printf("%i,%i,%i\n", buffer[0], buffer[1], buffer[2]);
			fflush(stdout);
		}
		else if (running == 0)
		{
			close(fd);
		}
		else if (running == 2)
		{
			fd = open("/dev/position", 0);
			if (fd < 0)
				printf("\n Device open error\n");
			running = 1;
		}
		usleep(1000000);
	} while (1);
}
