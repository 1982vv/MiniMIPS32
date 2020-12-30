	.file	1 "fib.c"
	.section .mdebug.abi32
	.previous
	.nan	legacy
	.module	fp=32
	.module	nooddspreg
	.text
	.globl	A
	.data
	.align	2
	.type	A, @object
	.size	A, 40
A:
	.word	1
	.word	2
	.word	3
	.word	4
	.word	5
	.word	6
	.word	7
	.word	8
	.word	9
	.word	10
	.text
	.align	2
	.globl	main
$LFB0 = .
	.cfi_startproc
	.set	nomips16
	.set	nomicromips
	.ent	main
	.type	main, @function
main:
	.frame	$fp,16,$31		# vars= 8, regs= 1/0, args= 0, gp= 0
	.mask	0x40000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-16
	.cfi_def_cfa_offset 16
	sw	$fp,12($sp)
	.cfi_offset 30, -4
	move	$fp,$sp
	.cfi_def_cfa_register 30
	li	$2,96			# 0x60
	sw	$2,0($fp)
	lui	$2,%hi(A)
	addiu	$2,$2,%lo(A)
	lw	$2,36($2)
	lw	$3,0($fp)
	nop
	subu	$2,$3,$2
	sw	$2,0($fp)
	lui	$2,%hi(A)
	addiu	$2,$2,%lo(A)
	lw	$2,28($2)
	lw	$3,0($fp)
	nop
	mult	$3,$2
	mflo	$2
	sw	$2,0($fp)
	lui	$2,%hi(A)
	addiu	$2,$2,%lo(A)
	lw	$3,0($fp)
	nop
	sw	$3,12($2)
	lui	$2,%hi(A)
	addiu	$2,$2,%lo(A)
	lw	$3,20($2)
	lui	$2,%hi(A)
	addiu	$2,$2,%lo(A)
	lw	$2,24($2)
	nop
	slt	$2,$3,$2
	andi	$2,$2,0x00ff
	sw	$2,4($fp)
	lw	$2,0($fp)
	nop
	addiu	$2,$2,7
	sw	$2,0($fp)
	lw	$2,0($fp)
	nop
	andi	$2,$2,0x1f
	sw	$2,0($fp)
	lui	$2,%hi(A)
	addiu	$2,$2,%lo(A)
	lw	$2,16($2)
	lw	$3,0($fp)
	nop
	or	$2,$3,$2
	sw	$2,0($fp)
	lui	$2,%hi(A)
	addiu	$2,$2,%lo(A)
	lw	$2,12($2)
	lw	$3,0($fp)
	nop
	addu	$2,$3,$2
	sw	$2,0($fp)
	move	$2,$0
	move	$sp,$fp
	.cfi_def_cfa_register 29
	lw	$fp,12($sp)
	addiu	$sp,$sp,16
	.cfi_restore 30
	.cfi_def_cfa_offset 0
	jr	$31
	nop

	.set	macro
	.set	reorder
	.end	main
	.cfi_endproc
$LFE0:
	.size	main, .-main
	.ident	"GCC: (GNU) 10.2.0"
