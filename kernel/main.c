void main(void)
{
	volatile char *screen = (volatile char *)0xB8000;

	screen[0] = '0' + sizeof(void *);
	screen[1] = 7;
}
