export ARCH ?= x86-64

arch	:= arch/$(ARCH)
libs	:= kernel
subdirs := $(arch) $(libs)

.PHONY: all
all: $(arch)

$(arch): $(libs)

.PHONY: $(subdirs)
$(subdirs):
	$(MAKE) -C $@

.PHONY: clean
clean:
	for d in $(subdirs);		\
	do				\
		$(MAKE) -C $$d clean;	\
	done
