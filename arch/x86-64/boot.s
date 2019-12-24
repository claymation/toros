/*
 * boot.s -- Multiboot entry point.
 */

	/*
	 * The text section.
	 */
	.text

	/*
	 * Support 64-bit processors (AMD64 and Intel 64).
	 */
	.arch generic64

	/*
	 * Mutliboot header. Per the specification, it "must be contained completely
	 * within the first 8192 bytes of the OS image, and must be longword (32-bit)
	 * aligned."
	 */
	.equiv	MULTIBOOT_MAGIC_NUMBER,	0x1BADB002
	.equiv	MULTIBOOT_FLAGS, 	0x0
	.equiv	MULTIBOOT_CHECKSUM,	-(MULTIBOOT_MAGIC_NUMBER + MULTIBOOT_FLAGS)

	.align	4

	.int	MULTIBOOT_MAGIC_NUMBER
	.int	MULTIBOOT_FLAGS
	.int	MULTIBOOT_CHECKSUM

	/*
	 * The entry point.
	 *
	 * On entry, Multiboot-compliant boot loaders assert a known machine state:
	 *
	 *   * The processor is in protected mode with paging disabled
	 *   * All segment registers are loaded with 32-bit flat segment descriptors
	 *   * Interrupts are disabled
	 *   * The A20 gate is enabled
	 *
	 * All other machine state is not defined, including ESP (no stack), GDTR (no GDT),
	 * and IDTR (no IDT), and the value of the segment selectors in the segment registers.
	 */
	.global _start
_start:
	/*
	 * Use 32-bit addresses and operands.
	 */
	.code32

	/*
	 * Set up the GDT.
	 */
	lgdt	GDTR

	/*
	 * Load CS with 32-bit protected mode segment descriptor.
	 */
	ljmp	$0x08, $1f

	/*
	 * Load data and stack segment descriptors.
	 */
1:	movw	$0x10, %dx
	movw	%dx, %ds
	movw	%dx, %es
	movw	%dx, %fs
	movw	%dx, %gs
	movw	%dx, %ss

	/*
	 * Enable physical address extensions (PAE).
	 */
	movl	%cr4, %edx
	bts	$5, %edx
	movl	%edx, %cr4

	/*
	 * Set up an identity mapping.
	 */
	leal	PML4, %edx
	movl	%edx, %cr3

	/*
	 * Enable long mode.
	 */
	movl	$0xC0000080, %ecx
	rdmsr
	bts	$8, %eax
	wrmsr

	/*
	 * Enable paging, activating long mode.
	 */
	movl	%cr0, %edx
	bts	$31, %edx
	movl	%edx, %cr0

	/*
	 * Load CS with 64-bit long mode segment descriptor.
	 */
	ljmp	$0x18, $1f

	/*
	 * Use 64-bit addresses and 32-bit operands.
	 */
1:	.code64

	/*
	 * Set up the kernel stack.
	 */
	movq	$0x200000, %rdx
	movq	%rdx, %rsp

	/*
	 * Continue in C.
	 */
	callq	main

	/*
	 * Halt.
	 */
1:	hlt
	jmp	1b

	/*
	 * The data section.
	 */
	.data

	/*
	 * Descriptor flags, byte 6.
	 */
	.equiv	DESC_READABLE,	1 << 1
	.equiv	DESC_WRITABLE,	1 << 1
	.equiv	DESC_CODE,	1 << 3
	.equiv	DESC_USER,	1 << 4
	.equiv	DESC_PRESENT,	1 << 7

	/*
	 * Descriptor flags, byte 7.
	 */
	.equiv	DESC_LONG,	1 << 5
	.equiv	DESC_32_BIT,	1 << 6
	.equiv	DESC_4_KB, 	1 << 7

	/*
	 * The Global Descriptor Table.
	 */
	.align	8
GDT:
	/*
	 * The "null" segment -- can't be used, but must exist.
	 */
	.zero	8

	/*
	 * 32-bit flat read-execute user code segment, ring 0.
	 */
	.word	0xffff
	.word	0x0000
	.byte	0x00
	.byte	DESC_PRESENT | DESC_USER | DESC_CODE | DESC_READABLE
	.byte	DESC_4_KB | DESC_32_BIT | 0xf
	.byte	0x00

	/*
	 * 32-bit flat read-write user data segment, ring 0.
	 */
	.word	0xffff
	.word	0x0000
	.byte	0x00
	.byte	DESC_PRESENT | DESC_USER | DESC_WRITABLE
	.byte	DESC_4_KB | DESC_32_BIT | 0xf
	.byte	0x00

	/*
	 * 64-bit flat user data segment, ring 0.
	 */
	.word	0x0000
	.word	0x0000
	.byte	0x00
	.byte	DESC_PRESENT | DESC_USER | DESC_CODE
	.byte	DESC_LONG
	.byte	0x00

GDTR:
	/*
	 * The 6-byte structure to load into the GDTR.
	 *
	 * The first word is the limit, or size, of the table, in bytes.
	 * The next dword is the linear (virtual) base address of the table.
	 */
	.word	GDTR - GDT
	.int	GDT


	/*
	 * Page table entry flags.
	 */
	.equiv	PAGE_PRESENT,	1 << 0
	.equiv	PAGE_WRITABLE,	1 << 1
	.equiv	PAGE_USER,	1 << 2
	.equiv	PAGE_SIZE,	1 << 7

	/*
	 * Level-4 page map: one entry for an identity map of the first 1 GiB.
	 */
	.align 4096
PML4:
	/* The | operator doesn't work with ABS and .data section symbols; + does */
	.int	PDP + (PAGE_PRESENT | PAGE_WRITABLE)
	.int	0x00000000

	/*
	 * Page directory pointer table: one entry for an identity map of the first 1 GiB.
	 */
	.align 4096
PDP:
	.int	PAGE_PRESENT | PAGE_WRITABLE | PAGE_SIZE
	.int	0x00000000

	.end
