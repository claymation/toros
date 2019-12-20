MV	 := mv -f
RM	 := rm -f
SED	 := SED

depends	 := $(subst .c,.d,$(sources))
objects	 := $(subst .c,.o,$(sources))
objects	 := $(subst .s,.o,$(objects))

CPPFLAGS += $(addprefix -I, $(includes))

CFLAGS	 += -std=gnu99 -ffreestanding
CFLAGS	 += -Wall -Wextra -Werror
CFLAGS	 += -march=i386 -m32
CFLAGS	 += -fcf-protection=none -fno-stack-clash-protection
CFLAGS	 += -fno-pic

LDFLAGS	 += -static -nostdlib -melf_i386

$(library): $(objects)
	$(LD) $(LDFLAGS) -r -o $@ $^

%/lib.o: %
	@true

.PHONY: $(subdirs)
$(subdirs):
	$(MAKE) -C $@

.PHONY: clean
clean:
ifneq "$(subdirs)" ""
	for d in $(subdirs);		\
	do				\
		$(MAKE) -C $$d clean;	\
	done
endif
	$(RM) $(objects) $(library) $(depends)

ifneq "$(MAKECMDGOALS)" "clean"
  -include $(dependencies)
endif

%.d: %.c
	$(CC) $(CFLAGS) $(CPPFLAGS) -M $< > $@
