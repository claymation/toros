RM	:= rm -f

ASFLAGS	+= --fatal-warnings
ASFLAGS	+= -march=i386 --32
LDFLAGS	+= -static -nostdlib -melf_i386

kernel.elf: boot.o ../../kernel/lib.o
	$(LD) $(LDFLAGS) -T elf_i386.lds -o $@ $^

.PHONY: clean
clean:
	$(RM) boot.o kernel.elf
