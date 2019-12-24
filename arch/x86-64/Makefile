RM	:= rm -f
OBJCOPY	:= objcopy

ASFLAGS	+= --fatal-warnings
LDFLAGS	+= -static -nostdlib

kernel.elf: boot.o ../../kernel/lib.o
	$(LD) $(LDFLAGS) -T boot.lds -o $@ $^
	$(OBJCOPY) -O elf32-i386 $@

.PHONY: clean
clean:
	$(RM) boot.o kernel.elf
