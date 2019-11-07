all:
	@gcc -m32 -c server.s
	@gcc -m32 server.o -o server
	@./server