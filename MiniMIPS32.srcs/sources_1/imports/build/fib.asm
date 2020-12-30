
build/fib:     file format elf32-littlemips
build/fib


Disassembly of section .text:

00000000 <main>:
main():
   0:	27bdfff0 	addiu	sp,sp,-16
   4:	afbe000c 	sw	s8,12(sp)
   8:	03a0f025 	move	s8,sp
   c:	24020060 	li	v0,96
  10:	afc20000 	sw	v0,0(s8)
  14:	3c020001 	lui	v0,0x1
  18:	24420000 	addiu	v0,v0,0
  1c:	8c420024 	lw	v0,36(v0)
  20:	8fc30000 	lw	v1,0(s8)
  24:	00000000 	nop
  28:	00621023 	subu	v0,v1,v0
  2c:	afc20000 	sw	v0,0(s8)
  30:	3c020001 	lui	v0,0x1
  34:	24420000 	addiu	v0,v0,0
  38:	8c42001c 	lw	v0,28(v0)
  3c:	8fc30000 	lw	v1,0(s8)
  40:	00000000 	nop
  44:	00620018 	mult	v1,v0
  48:	00001012 	mflo	v0
  4c:	afc20000 	sw	v0,0(s8)
  50:	3c020001 	lui	v0,0x1
  54:	24420000 	addiu	v0,v0,0
  58:	8fc30000 	lw	v1,0(s8)
  5c:	00000000 	nop
  60:	ac43000c 	sw	v1,12(v0)
  64:	3c020001 	lui	v0,0x1
  68:	24420000 	addiu	v0,v0,0
  6c:	8c430014 	lw	v1,20(v0)
  70:	3c020001 	lui	v0,0x1
  74:	24420000 	addiu	v0,v0,0
  78:	8c420018 	lw	v0,24(v0)
  7c:	00000000 	nop
  80:	0062102a 	slt	v0,v1,v0
  84:	304200ff 	andi	v0,v0,0xff
  88:	afc20004 	sw	v0,4(s8)
  8c:	8fc20000 	lw	v0,0(s8)
  90:	00000000 	nop
  94:	24420007 	addiu	v0,v0,7
  98:	afc20000 	sw	v0,0(s8)
  9c:	8fc20000 	lw	v0,0(s8)
  a0:	00000000 	nop
  a4:	3042001f 	andi	v0,v0,0x1f
  a8:	afc20000 	sw	v0,0(s8)
  ac:	3c020001 	lui	v0,0x1
  b0:	24420000 	addiu	v0,v0,0
  b4:	8c420010 	lw	v0,16(v0)
  b8:	8fc30000 	lw	v1,0(s8)
  bc:	00000000 	nop
  c0:	00621025 	or	v0,v1,v0
  c4:	afc20000 	sw	v0,0(s8)
  c8:	3c020001 	lui	v0,0x1
  cc:	24420000 	addiu	v0,v0,0
  d0:	8c42000c 	lw	v0,12(v0)
  d4:	8fc30000 	lw	v1,0(s8)
  d8:	00000000 	nop
  dc:	00621021 	addu	v0,v1,v0
  e0:	afc20000 	sw	v0,0(s8)
  e4:	00001025 	move	v0,zero
  e8:	03c0e825 	move	sp,s8
  ec:	8fbe000c 	lw	s8,12(sp)
  f0:	27bd0010 	addiu	sp,sp,16
  f4:	03e00008 	jr	ra
  f8:	00000000 	nop

Disassembly of section .MIPS.abiflags:

00000100 <.MIPS.abiflags>:
 100:	00010000 	sll	zero,at,0x0
 104:	01000101 	0x1000101
	...

Disassembly of section .eh_frame:

00000118 <.eh_frame>:
 118:	00000010 	mfhi	zero
 11c:	00000000 	nop
 120:	00527a01 	0x527a01
 124:	011f7c01 	0x11f7c01
 128:	001d0d0b 	0x1d0d0b
 12c:	00000020 	add	zero,zero,zero
 130:	00000018 	mult	zero,zero
 134:	00000000 	nop
 138:	000000fc 	0xfc
 13c:	100e4400 	beq	zero,t6,11140 <_stack+0x160>
 140:	44019e44 	0x44019e44
 144:	e0021e0d 	swc0	c0_entrylo,7693(zero)
 148:	de481d0d 	0xde481d0d
 14c:	0000000e 	0xe

Disassembly of section .data:

00010000 <A>:
_fdata():
   10000:	00000001 	0x1
   10004:	00000002 	srl	zero,zero,0x0
   10008:	00000003 	sra	zero,zero,0x0
   1000c:	00000004 	sllv	zero,zero,zero
   10010:	00000005 	0x5
   10014:	00000006 	srlv	zero,zero,zero
   10018:	00000007 	srav	zero,zero,zero
   1001c:	00000008 	jr	zero
   10020:	00000009 	jalr	zero,zero
   10024:	0000000a 	0xa

Disassembly of section .reginfo:

00000000 <.reginfo>:
   0:	e000000c 	swc0	c0_index,12(zero)
	...
  14:	00018020 	add	s0,zero,at

Disassembly of section .pdr:

00000000 <.pdr>:
   0:	00000000 	nop
   4:	40000000 	mfc0	zero,c0_index
   8:	fffffffc 	0xfffffffc
	...
  14:	00000010 	mfhi	zero
  18:	0000001e 	0x1e
  1c:	0000001f 	0x1f

Disassembly of section .comment:

00000000 <.comment>:
   0:	3a434347 	xori	v1,s2,0x4347
   4:	4e472820 	c3	0x472820
   8:	31202955 	andi	zero,t1,0x2955
   c:	2e322e30 	sltiu	s2,s1,11824
  10:	Address 0x0000000000000010 is out of bounds.


Disassembly of section .gnu.attributes:

00000000 <.gnu.attributes>:
   0:	00000f41 	0xf41
   4:	756e6700 	jalx	5b99c00 <_gp+0x5b81be0>
   8:	00070100 	sll	zero,a3,0x4
   c:	01040000 	0x1040000
