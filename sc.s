[BITS 64]
default rel
;global	_start
section .text
_start:
	push rdx
	push rdi
	push rbp
	push rbx
	mov rbp, rsp


	lea	rdi, [.string]
	call	.strlen
	mov	rsi, rax
	lea	rdi, [.string]	
	call	.printrgbstring


	call	.printansireset
	call	.printnl
	mov	rsp, rbp
	pop 	rbx
	pop 	rbp
	pop	rdi
	pop	rdx
	ret
.strlen:	; rdi str, rax ret
	push	rbx
	push	rcx
	xor	rax, rax
	xor	rbx, rbx
	lea	rcx, [rdi]
	._strlenloop:
		mov	bl, [rcx]		
		add	rcx, 1
		add	rax, 1
		cmp	bl, 0
		jne	._strlenloop
	sub	rax, 1
	pop	rcx		
	pop	rbx
	ret
.printrgbstring: ; rdi str, rsi len
	push	rcx
	push	rax
	push	r8
	push	r9
	push	r10	
	push	r11
	push	r12
	push	r13
	push	r14
	
	mov	r8, rdi
	mov	r9, rsi
	xor	rcx, rcx
	xor	r10, r10
	xor	r13, r13
	xor	r12, r12
	mov	r14, 80
	cmp	rsi, r14 
	jge	._loop; rsi >= 80
._setmaxtostrlen:
	mov	r14, rsi		
._loop:	; r9 string len, r13 color step count			
	mov	rsi, r13; step
	mov	rdi, r14 ; max_steps	
	call	.hsv_to_rgb	
	
	mov	r10, rax ; red
	and	r10, 255
	mov	r11, rax ; green
	shr	r11, 8
	and	r11, 255
	mov	rbx, rax ; blue
	shr	rbx, 16
	and	rbx, 255

	lea	rax, [r8]
	add	rax, r12
	xor	rdi, rdi
	mov	dil, byte [rax]
	mov	rsi, r10
	mov	rdx, r11
	mov	rcx, rbx
	call	.printcolorchar	
	
	add	r12, 1
	cmp	r12, r9
	jge	._loopend

	add	r13, 1
	cmp	r13, 81
	jl	._loop
	xor	ecx, ecx
	jmp	._loop
._loopend:
	pop	r14
	pop	r13
	pop	r12
	pop	r11
	pop	r10
	pop	r9
	pop	r8
	pop	rax
	pop	rcx
	ret

.printansireset:
	push	rdi
	push	rsi

	lea	rdi, [.ansireset]
	mov	rsi, 4
	call	.printstr		
	
	pop	rsi
	pop	rdi
	ret
.printcolorchar: ; rdi - char, rsi r, rdx g, rcx b
	push	rax
	push	rbx
	push	rcx
	push	r8 ; char
	push	r9 ; red
	push	r10 ; green
	push	r11 ; blue
	push	r12
	push	r13
	push	rbp
	mov	rbp, rsp
	
	mov	r8, rdi
	mov	r9, rsi
	mov	r10, rdx
	mov	r11, rcx
 
	mov	rsi, 07h
	lea	rdi, [.ansicode1]
	call	.printstr

	mov	rdi, r9 ; red
	call	.printnum	
	
	mov	rsi, 1
	lea	rdi, [.ansicode34]
	call	.printstr

	mov	rdi, r10 ; green
	call	.printnum
	
	mov	rsi, 1
	lea	rdi, [.ansicode34]
	call	.printstr

	mov	rdi, r11 ; blue 
	call	.printnum
	
	mov	rsi, 1
	lea	rdi, [.ansicode5]
	call	.printstr

	mov	rdi, r8
	call	.printchar
	mov	rsp, rbp
	pop	rbp
	pop	r13
	pop	r12
	pop	r11
	pop	r10
	pop	r9
	pop	r8
	pop	rcx
	pop	rbx
	pop	rax
	ret

.printnum: ; rdi num
	push	r11
	push	rax
	push	rsi
	push	rbx
	push	rbp
	mov	rbp, rsp
	sub	rsp, 32
	
	lea	rsi, [rbp - 1]
	call	.itoa
	lea	rsi, [rbp]
	sub	rsi, rax
	mov	rdi, rax
	call	.printstr

	mov	rsp, rbp
	pop	rbp
	pop	rbx
	pop	rsi
	pop	rax
	pop	r11
	ret
.printchar:; rdi	char
	push	rsi
	push	rbp
	mov	rbp, rsp
	sub	rsp, 8

	mov	[rbp - 8], dil
	lea	rdi, [rbp - 8]
	mov	rsi, 1
	call	.printstr

	mov	rsp, rbp
	pop	rbp
	pop	rsi
	ret
.printstr: ; rdi str, rsi len
	push	r11
	push	rdx
	push	rax
	push	rbp
	mov	rbp, rsp
	
	mov	rdx, rsi 
	mov	rsi, rdi
	mov	rax, 1
	mov	rdi, 1
	syscall

	mov	rsp, rbp
	pop	rbp
	pop	rax
	pop	rdx	
	pop	r11
	ret
.printnl:
	push 	rdi
	push	rdx
	push	rsi
	push	rbp
	mov	rbp, rsp
	sub	rsp, 8

	mov rax, 1
	mov rdi, 1
	mov rdx, 1
	mov [rbp - 8], byte 0ah
	lea rsi, [rbp - 8]
	syscall
	mov	rsp, rbp
	pop	rbp
	pop	rsi	
	pop	rdx
	pop	rdi
	ret	
.flmod:
	movaps	xmm2, xmm0
	divss	xmm2, xmm1
	cvttss2si	eax, xmm2
	pxor	xmm2, xmm2
	cvtsi2ss	xmm2, eax
	mulss	xmm1, xmm2
	subss	xmm0, xmm1
	ret
.hsvf:	; xmm0 return, xmm0 n, xmm1 h
	addss	xmm0, xmm1
	mov	eax, 40c00000h
	movd	xmm1, eax
	call	.flmod
	
	mov	eax, 40800000h
	movd	xmm1, eax
	movaps	xmm2, xmm0		

	subss	xmm1, xmm0
	mov	eax, 3f800000h
	movd	xmm0, eax
	
	comiss	xmm1, xmm2
	jbe	._label1
	comiss	xmm0, xmm2 ; xmm0 = n, xmm1 = h
	ja	._label2
._label3:
	minss	xmm2, xmm0
	subss	xmm0, xmm2
	mov	eax, 437f0000h
	movd	xmm3, eax
	mulss	xmm0, xmm3
	ret
._label1:
	comiss	xmm0, xmm1
	ja	._label4
._label5:
	movaps	xmm2, xmm1
	jmp	._label3
._label4:
	pxor	xmm2, xmm2
	comiss	xmm1, xmm2
	ja	._label5
._label6:
	mov	eax, 437f0000h
	movd	xmm0, eax
	ret
._label2:
	pxor	xmm1, xmm1
	comiss	xmm2, xmm1
	ja	._label3
	jmp	._label6

.hsv_to_rgb: ; eax return, edi max_steps, esi step
	push	rbp
	mov	rbp, rsp
	sub	rsp, 18h
	mov	[rbp - 1ch], edi ; max_steps_local, max_steps
	mov	[rbp - 20h], esi ;step_local, step

	pxor	xmm0, xmm0
	cvtsi2ss	xmm0, [rbp - 20h]

	pxor	xmm2, xmm2
	cvtsi2ss	xmm2, [rbp - 1ch]
	
	movaps	xmm1, xmm0
	divss	xmm1, xmm2

	mov	eax, 43b40000h
	movd	xmm0, eax

	mulss	xmm0, xmm1
	movss	[rbp - 14h], xmm0 ; angle
	mov	eax, 42700000h
	movd	xmm1, eax

	divss	xmm0, xmm1
	movss	[rbp - 10h], xmm0 ; h
	mov	[rbp - 0ch], 0	; v 

	movss	xmm0, [rbp - 10h]
	movaps	xmm1, xmm0
	mov	eax, 40a00000h

	movd	xmm0, eax
	call	.hsvf

	cvttss2si	eax, xmm0
	movzx	eax, al

	or	[rbp - 0ch], eax ; first or
	
	movss	xmm0, [rbp - 10h]
	
	movaps	xmm1, xmm0
	mov	eax, 40400000h
	
	movd	xmm0, eax
	call	.hsvf
	
	cvttss2si	eax, xmm0
	movzx	eax, al
	
	shl	eax, 8 
	or	[rbp - 0ch], eax ; second or

	movss	xmm0, [rbp - 10h]
	movaps	xmm1, xmm0
	mov	eax, 3f800000h
	movd	xmm0, eax
	call	.hsvf
	
	cvttss2si	eax, xmm0
	movzx	eax, al

	shl	eax, 16 
	or	[rbp - 0ch], eax ; third or
	mov	eax, [rbp - 0ch]
	leave
	ret

.itoa:;	ret rax, num edi, rsi poutbuf
	push	rcx
	push	rdx
	push	rbx
	push	rdi

	mov	ebx, 10
	mov	eax, edi ;eax is now the number
._itoaloop:
	; eax = eax / src
	; edx = eax % src
	xor	edx, edx
	div	ebx
	mov	ecx, eax
	add	edx, 48
	mov	[rsi], byte dl
	sub	rsi, 1
	test	eax, eax	
	jnz	._itoaloop
	
	mov	rax, rsi
	add	rax, 1h
	
	pop	rdi
	pop	rbx
	pop	rdx
	pop	rcx
	ret
; 5ch 78h 31h 62h 5Bh 33h 38h 3Bh 32h 3Bh _ 3Bh _ 3Bh _ 6dh
.ansicode1: db 1bh, 5bh, 33h, 38h, 3bh, 32h, 3bh
.ansicode34: db 3bh
.ansicode5: db 6dh
.ansireset: db 1bh, 5bh, 30h, 6dh
.string: db "Rust provides a complete memory safety guarantee, except in",0ah,"unsafe. This program has no unsafe_code, therefore this is not possible:", 0Ah, 0
.endstring:
nop
