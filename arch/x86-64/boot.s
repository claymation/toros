/*
 * boot.s -- Multiboot entry point.
 */

	/*
	 * The text section.
	 */
	.text

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
	 * Set up the kernel stack.
	 */
	movl	$0x200000, %edx
	movl	%edx, %esp

	/*
	 * Continue in C.
	 */
	call	main

	/*
	 * Halt.
	 */
1:	hlt
	jmp	1b

	.end
