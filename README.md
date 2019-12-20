# torOS

Tiny multi-user multi-tasking 64-bit real-time operating system.


## Build

Supports Linux build host with GNU toolchain.

    make


## Boot

The `kernel.elf` artifact boots on x86-64 machines.

* QEMU

    qemu-system-x86_64 -kernel arch/x86-64/kernel.elf

* Grub

    $ cat /boot/grub/custom.cfg 
    menuentry 'TorOS' {
            multiboot /boot/kernel.elf
    }


## Copying

This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.
