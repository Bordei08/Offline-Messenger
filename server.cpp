#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include "command.h"

void start_client();



#define PORT 4444

int main()
{

	int sockfd, ret;
	struct sockaddr_in serverAddr;

	struct sockaddr_in newAddr;

	socklen_t addr_size;

	char buffer[1024];
	pid_t childpid;

	sockfd = socket(AF_INET, SOCK_STREAM, 0);
	if (sockfd < 0)
	{
		printf("[-]Error in connection.\n");
		exit(1);
	}
	printf("[+]Server Socket is created.\n");

	memset(&serverAddr, '\0', sizeof(serverAddr));
	serverAddr.sin_family = AF_INET;
	serverAddr.sin_port = htons(PORT);
	serverAddr.sin_addr.s_addr = inet_addr("127.0.0.1");

	ret = bind(sockfd, (struct sockaddr *)&serverAddr, sizeof(serverAddr));
	if (ret < 0)
	{
		printf("[-]Error in binding.\n");
		exit(1);
	}
	printf("[+]Bind to port %d\n", 4444);

	if (listen(sockfd, 10) == 0)
	{
		printf("[+]Listening....\n");
	}
	else
	{
		printf("[-]Error in binding.\n");
	}

	int pid;
	while (1)
	{
		users[count_user ].key = accept(sockfd, (struct sockaddr *)&newAddr, &addr_size);
		if (users[count_user++].key < 0)
		{
			printf("ERROR ACCEPT!\n");
			exit(1);
		}
		printf("Connection accepted from %s:%d\n", inet_ntoa(newAddr.sin_addr), ntohs(newAddr.sin_port));
		pid = fork();
		if ((childpid = pid) == 0)
		{
			close(sockfd);
			start_client();
		}
	}

	return 0;
}

void start_client()
{
	bool online_stat = 0;
	char answer[1024];
	char buffer[1024];

	while (online_stat == 0)
	{
		bzero(buffer, sizeof(buffer));
		printf("Salut sunt aici \n");
		//	std :: cout << buffer<<std :: endl;
		recv(users[count_user - 1].key, buffer, 1024, 0);

		switch (client_in(buffer))
		{
		case -1:
			strcpy(answer, "EXIT");
			send(users[count_user - 1].key, answer, strlen(answer), 0);
			exit(0);
			users[count_user - 1].key = -1;
			break;
		case 0:
		
			online_stat = 1;
			break;
		case 1:
			strcpy(answer, "[-]Username invalid /register!!");
			send(users[count_user - 1].key, answer, strlen(answer), 0);
			break;
		case 2:
			strcpy(answer, "[-]Exista un user cu acest username");
			send(users[count_user - 1].key, answer, strlen(answer), 0);
			break;
		case 4:
			strcpy(answer, "[+]Te_ai inregistrat, /login username ! ");
			send(users[count_user - 1].key, answer, strlen(answer), 0);
			break;
		default:
			strcpy(answer, "[-]Command not found");
			send(users[count_user - 1].key, answer, strlen(answer), 0);
		}
	}

    

    std :: cout <<"Salut te pup \n";
   bool in_cmd = 0;
    char all[]="all";
	std :: cout << history_conv(all)<< std :: endl;
	if( unseen_msg() !=  "empty"){
	   
			  strcpy(answer, "[!] Aveti mesaje noi! ");
			 send(users[count_user - 1].key, answer, strlen(answer), 0);
		}
		else{
             strcpy(answer, "[+]Te_ai logat! ");
			send(users[count_user - 1].key, answer, strlen(answer), 0);
		}
		//testing();
        std :: cout <<  "    AICI   "<<std ::endl;
    while(1){
		in_cmd = 0;
		bzero(buffer, sizeof(buffer));
		printf("Salut sunt aici dupa /login \n");
		//	std :: cout << buffer<<std :: endl;
		recv(users[count_user - 1].key, buffer, 1024, 0);
		
        

		if(strcmp(buffer,"/all-users") == 0){
			 in_cmd = 1;
			//std :: cout<<"A intrat"<< std :: endl;
			std ::  string s = all_users();
			//std :: cout << all_users();
			send(users[count_user - 1].key, s.c_str(), s.size(), 0);
			
		}
		if(strstr(buffer, "exit")){
			 in_cmd = 1;
			 mod_stat_user(users[count_user - 1].username_on, -1);
			strcpy(answer, "EXIT");
			send(users[count_user - 1].key, answer, strlen(answer), 0);
			online_stat = 1;
		}

		if(strstr(buffer, "/send")){
			 in_cmd = 1;
			char cmd[1024], sep[] = " ";
			strcpy(cmd,buffer + 6);
			char * p = strtok(cmd,sep);
			char to_user[100] = "", msg[1024] = "";
            strcpy(to_user, p);
			while(p){
                  p = strtok(NULL,sep);
				  if(p){
                     strcat(msg, p);
					 strcat(msg, " ");
				  } 
			}
			if(verf_username(to_user) == 0){
				strcpy(answer, "[-] Nu exista acest username!");
			    send(users[count_user - 1].key, answer, strlen(answer), 0);
			}
			else{
			    send_msg_to(to_user, msg);
			     strcpy(answer, "[+] mesaj trimis cu succes catre ");
				 strcat(answer, to_user);
		         send(users[count_user - 1].key, answer, strlen(answer), 0);
			}
		}
		if(strstr(buffer, "/unseen-msg")){
			//std :: cout << "SALUT" << std ::endl;
			 in_cmd = 1;
			if(unseen_msg() ==  "empty"){
			  strcpy(answer, "[-]Nu aveti mesaje noi ");
			 send(users[count_user - 1].key, answer, strlen(answer), 0);
		}
		    else{
              std ::  string s = unseen_msg();
			send(users[count_user - 1].key, s.c_str(), s.size(), 0);
		  }
		}

		if(strstr(buffer, "/history-conv")){
			 in_cmd = 1;
			 char token[100];
			 strcpy(token, buffer + 14);
			 std :: cout << token <<  "!!!!!!!!!!!!!"<<std :: endl;
			if(history_conv(all) ==  "empty"){
			  strcpy(answer, "[-]Nu aveti nicio conversatie ");
			 send(users[count_user - 1].key, answer, strlen(answer), 0);
		}
		    else{
              std ::  string s = history_conv(token);
			send(users[count_user - 1].key, s.c_str(), s.size(), 0);
		  }
		}

      
       if(strcmp("/logout", buffer) == 0){
		    in_cmd = 1;
			mod_stat_user(users[count_user - 1].username_on, -1);
		   strcpy(answer, "[+] Te ai delogat cu succes");
		 send(users[count_user - 1].key, answer, strlen(answer), 0);
		   start_client();
		   exit(0);
		   close(users[count_user - 1].key);
	   }
        
		if(strstr(buffer, "/reply")) {
			in_cmd = 1;

			std :: cout << "IN MORTI MA TII "<<std :: endl;
			char cmd[1024], sep[] = " ";
			strcpy(cmd,buffer + 6);
			std:: cout << cmd << std:: endl;
			char * p = strtok(cmd,sep);
			char to_user[100] = "", msg[1024] = "";
            strcpy(to_user, p);
			while(p){
                  p = strtok(NULL,sep);
				  if(p){
                     strcat(msg, p);
					 strcat(msg, " ");
				  } 
				  
			}
			std :: cout << to_user<<std::endl;
			std :: cout << msg<<std :: endl;
			if(exist_conv(to_user) != 1){
				replay_to(to_user, msg);
				strcpy(answer, "[+] Replay trimis cu succes!");
		      send(users[count_user - 1].key, answer, strlen(answer), 0);
			}
			else{
				strcpy(answer, "[-] Nu ai nicio conv cu acest user !!");
		      send(users[count_user - 1].key, answer, strlen(answer), 0);
			}
		}

	   if(in_cmd == 0){
		   strcpy(answer, "[-] Nu exista aceasta comanda!");
		 send(users[count_user - 1].key, answer, strlen(answer), 0);
	   }
	   
	}

	exit(0);
	close(users[count_user - 1].key);
}