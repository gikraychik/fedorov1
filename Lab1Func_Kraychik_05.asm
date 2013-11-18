; -------------------------------------------------------------------------------------        
;        ������������ ������ �1 �� ����� ���������������� �� ����� ����������                                
;        ������� �5.                                                                                                                                                
;        �������� ������� �������. ������ 344                                                                                                
;
;        �������� ������ Lab1Func_Kraychik_05.asm                                                           
;        �������� ������� �� ����� ����������, ������������� � ������������ � ��������                     
;		 � �������� ������������� ���������� ������ f = x^64 + x^4 + x^3 + x + 1
;		 �.�. GF2_64 = Z/2Z[x] / f
;		 ��������� ��������� �� ���������
;		 ��� ���������� ��� ����� GF2_64 �������� � ������ �� ������� ������������ � �������,
;		 �� ���� ���������� ��� ������� ������� ���������� �������� � ������� ������ �������
; -------------------------------------------------------------------------------------

.CODE

; GF2_64 GF_MulX(GF2_64 a)
; ��������� �������� ���� � �� �
GF_MulX PROC							; rcx - a (������� ����)
	cmp rcx, 0							; ��������� �������� � � 0
	mov rdx, 27							; 27 = x^4 + x^3 + x + 1
	mov r8, 0							; ���������� � ������� cmovg
	cmovg rdx, r8						; rdx = (rcx < 0) ? 27 : 0
	sal rcx, 1							; ��������� �� x
	xor rcx, rdx						; ������������
	mov rax, rcx						; ������������ ��������
	ret
GF_MulX ENDP

; GF2_64 GF_PowX(unsigned int Power);
; ���������� x � ������� Power
GF_PowX PROC							; ecx - Power (unsigned int)
	; ���������� �������� ��������� �� ����
	push rbx
	push rbp
	mov rbp, 1							; ���������� ���������� ��������
										; ����� ������� ���� � Power ��������
	m2:
		cmp rcx, 0						; ��������� rcx � 0
		je m1							; ���� rcx == 0, ������� � ����� m1
		mov rbx, rcx					; ����������� rcx �� rbx
		mov rcx, rbp					; ������ �� rcx rbp, ����� �������� � ������� rbp
										; � �������� ��������� �������
		call GF_MulX
		mov rbp, rax					; ������ ���������� ������ ������� �� rbp
		mov rcx, rbx					; �������������� �������� �� rcx
		dec rcx							; ���������� ��������
		jmp m2							; ������� � ����� m2
	m1:
	mov rax, rbp						; �� rax ��������� ������������ ��������
	; �������������� ��������
	pop rbp
	pop rbx
	ret
GF_PowX ENDP

; ��������������� ���������
; unsigned char get_bit(GF2_64 a, unsigned int b);
; ��������� ���� ����� b �� a
get_bit PROC							; rcx - ������� GF2_64
										; rdx - ����� ����
	mov r8, rcx							; ����������� rcx �� r8
	mov cl, dl			
	ror r8, cl							; ������ ������� ��� ��������� � ������� ����
	mov r9, r8							; ����������� r8 �� r9
	; ��������� �������� ����
	sar r8, 1
	sal r8, 1
	xor r8, r9							; � r8 �������� ���������
	mov rax, r8
	ret
get_bit ENDP

; GF2_64 GF_Multiply(GF2_64 a, GF2_64 b);
; ��������� ���� ��������� ����
GF_Multiply PROC						; rcx - a (������ �������)
										; rdx - b (������ �������)
	; ���������� �������� � ����� ��� ������������ ��������������
	push r15
	push r14
	push r13
	push r12
	push rsi
	; ��������� �������� ���� �������� b �� a 
	mov r15, rcx						; ����������� rcx �� r15
	mov r14, rdx						; ����������� rdx �� r14
	mov rcx, rdx						; ���������� � ������	
	mov rdx, 0							; ������� get_bit
	call get_bit
	imul r15							; ��������� ����� ����������� ������ � rax, rdx ���������
	mov r13, rax						; r13 �������� ������� ������������
	mov r12, r15						; r12 ����� ��������� a*(x^i), ��� i = 0..63
										; � ������ ������ i == 0
	xor rsi, rsi						; rsi - ���������� �������� �����, ���������
	; ���� �� ���� ����� b
	m1:
		cmp rsi, 63						; ��������� rsi � 63
		je m2							; ���� rsi == 63, ������� � ����� m2
		inc rsi							; rsi++
		mov rcx, r12					; ���������� � ������ GF_MulX
		call GF_MulX
		mov r12, rax					; ���������� �������� r12 = a*(x^rsi)
		mov rcx, r14					; ���������� � ������ get_bit
		mov rdx, rsi					; rcx = b, rsi - ����� ����
		call get_bit

		cmp rax, 1
		mov rax, r12
		mov rcx, 0
		cmovne rax, rcx
		;imul r12						; ���������� ������������ ���������� get_bit � r12
		xor r13, rax					; ���������� � ��������, ����������� ���������
		jmp m1
	m2:
	mov rax, r13						; ������������ ��������
	; �������������� ��������
	pop rsi
	pop r12
	pop r13
	pop r14
	pop r15
	ret
GF_Multiply ENDP

; GF2_64 GF_Reciprocal(GF2_64 a)
; ���������� ��������� �������� � ����
GF_Reciprocal PROC						; rcx - a (������� ����)
	; ���������� �������� ��������� ��� ������������ ��������������
	push rbx
	push rbp
	push r12
	push rsi
	; ���������� � ������ GF_Multiply
	mov rbx, rcx						; ����������� a (������ �������� ��� �� rcx)
	mov rdx, rbx						; ����������� a (������ ��������)
	call GF_Multiply					; ����� GF_Multiply
	mov rbp, rax						; rbp - ����������, ������� ����� ���������� � �������
	mov r12, rbp						; r12 - � ��� �������� ���������
	mov rcx, 62							; ������� �����
	m1:
		mov rsi, rcx					; ���������� �������� �����
		; ���������� � ������ GF_Multiply (���������� � �������)
		mov rcx, rbp					; ������ ��������
		mov rdx, rbp					; ������ ��������
		call GF_Multiply
		mov rbp, rax					; ���������� ���������� ���������� � �������
		; ���������� � ������ GF_Multiply (������� ������������)
		mov rcx, rbp					; ������ ��������
		mov rdx, r12					; ������ ��������
		call GF_Multiply
		mov r12, rax					; ���������� ����������
		mov rcx, rsi					; �������������� �������� �����
		loop m1							; ���������� rcx, �������� ������� � m1
	mov rax, r12						; ������������ ��������
	; �������������� �������� ��������� �� �����
	pop rsi
	pop r12
	pop rbp
	pop rbx
	ret
GF_Reciprocal ENDP

; int PolyMulX(GF2_64 *a, int deg)
; ��������� ���������� ��� ����� GF2_64 �� x
PolyMulX PROC							; rcx - ��������� �� ��������� a
										; edx - ������� ���������� deg, ��� ������ int
	mov rax, -1							; ���� deg == -1, ������ �������� -1
	cmp edx, -1							; ��� int �������� 32-������
	je m1								; ���� deg == 1, ����� �������
	inc rdx								; ������� ���������� �� 1 ������ ������� ����������
	mov r8, rdx							; ���������� � ���������
	mov rax, 8							; ������ ���������� GF2_64 �������� 8 ����
	imul rdx							; � rax ��������� �������� ������ � �������
	mov r9, 0							; ��� ��������� �� x, ����������
										; ��� ������� ������� ���������� �����
	mov [rcx+rax], r9					; a[deg+1] = 0
	mov rax, r8							; ������������ ������� ������ ����������
	m1:
	ret
PolyMulX ENDP

; int PolyMulConst(GF2_64 *a, int deg, GF2_64 c)
; ��������� ���������� �� ������� ���� GF2__64
PolyMulConst PROC						; rcx - ��������� �� ������ a
										; rdx - ������� ���������� deg, ����� ��� int
										; r8 - ������� ���� GF2_64
	; ���� ��������� ����� 0, ������ ������� -1
	mov rax, -1			
	cmp r8, 0							; ��������� ��������� � �����
	je m3								; ���� ��������� ����� 0, ���������� ������ �������
	cmp edx, -1							; ��������� ������� � -1 (int 32-������)
	je m3								; ���� ��� �����, ��������� ���������, ������ -1
	; ���������� �������� � �����
	push r15
	push r14
	push r13
	push rsi
	; ���������� �������� rcx, rdx, r8
	mov r15, rcx
	mov r14, rdx
	mov r13, r8
	xor rsi, rsi						; ��������� �������� ��� �����
	m2:
		cmp rsi, r14					; ��������� �������� � deg
		jg m1							; ���� rsi > deg ��������� ����
		mov rcx, [r15+8*rsi]			; ���������� ������ �������� ����������� ����������
										; � ������ ��� �� ������� rcx
		mov rdx, r13					; ������ ��������� �� rdx
		call GF_Multiply				; ���������� ������������ rcx � rdx
		mov [r15+8*rsi], rax			; ������ ������������ � ������
		inc rsi							; ���������� �������� �� �������
		jmp m2
	m1:
	; �������������� �������� �� �����
	mov rax, r14						; ������������ ��������� �������� ������� ����������
	pop rsi
	pop r13
	pop r14
	pop r15
	m3:
	ret
PolyMulConst ENDP

; int PolyZero(GF2_64 *a, int deg)
; ��������� ����������
PolyZero PROC							; rcx - ��������� �� ������ a
										; edx - ������� ���������� deg, �������� ����� int
	xor r8, r8							; ��������� r8, ������ �������� �����
	m1:
		cmp edx, 0						; ��������� ������� � 0
		jl m2							; ���� ������� ������ ����, ������� � ����� m2
		mov [rcx+8*rdx], r8				; ��������� ����������� ����������
		dec edx							; ���������� edx �� �������
		jmp m1							; ��������� � ������ �����
	m2:
	mov eax, -1							; ������������ ��������� ��������
										; 32-������ -1
										; ������������ �������� ���� int
	ret
PolyZero ENDP

; int PolyCpy(GF2_64 *dest, GF2_64 *src, unsigned char deg)
; ����������� ���������� �� src � dest
PolyCpy PROC							; rcx - ��������� �� �������� (dest)
										; rdx - ��������� �� �������� (src)
										; r8 - ������� ���������� deg, ����� ��� unsigned char
	
	; ���������� ��������� � ������
	push rsi
	push rdi

	mov r9, rcx							; ����������� rcx �� r9
	mov rax, r8							; ������������ ��������
	mov rsi, rdx						; ����� ���������
	mov rdi, r9							; ����� ���������
	mov rcx, r8							; �������
	inc rcx								; ������� �� 1 ������ ���-�� ������������
	cld									; �������� ����� �������������
	rep movsq							; ����������� �������, �� rcx �������
	; �������������� �������� ���������
	pop rdi
	pop rsi
	ret
PolyCpy ENDP

; int PolySum(GF2_64 *sum, GF2_64 *a, int deg_a, GF2_64 *b, int deg_b)
; �������� ����������� ��� ����� GF2_64
PolySum PROC							; rcx - ����� ���������� (sum)
										; rdx - ����� ������� ���������� (a)
										; r8 - ������� ������� ���������� (deg_a)
										; r9 - ����� ������� ���������� (b)
										; [rsp+40] - ������� ������� ���������� (deg_b)
	
	mov eax, [rsp+40]					; ������ �� eax ����� deg_b
	; ���������� �������� ���������
	push r12
	push r13
	push r14
	cdqe								; �������� ���������� eax �� rax
	; ���������� r8d �� r8
	xchg rax, r8
	cdqe
	xchg rax, r8
	; ������ ��� ������������ �������� 64-������
	mov r10, r8							; ������������� ������� ������� i
	mov r12, rax						; ������������� ������� ������� j
	; ������ �� r13 ��������� �� deg_a, deg_b
	mov r13, r8							; r13 - ������ � ������� sum, ��������� k
	cmp r8, rax							; ��������� deg_a � deg_b
	cmovl r13, rax						; ���� r8 < rax => r13 = rax
	mov r14, r13						; ����������� r13 � r14
	; ����� ������� �����
	m1:
		cmp r10, 0						; ��������� r10 � 0
		jl m2							; ���� r10 < 0, ������� � ����� m2
		cmp r12, 0						; ��������� r12 � 0
		jl m2							; ���� r12 < 0, ������� � ����� m2
		mov r11, [rdx+8*r10]			; r11 = a[i]
		xor r11, [r9+8*r12]				; r11 += b[j]
		mov [rcx+8*r13], r11			; sum[k] = a[i] + b[j]
		dec r10							; i--
		dec r12							; j--
		dec r13							; k--
		jmp m1
	m2:
		cmp r10, 0						; ��������� i � 0
		jl m3							; ���� i < 0, ������� � m3
		mov r11, [rdx+8*r10]			; r11 = a[i]
		mov [rcx+8*r13], r11			; sum[k] = a[i]
		dec r10							; i--
		dec r13							; k--
		jmp m2
	m3:
		cmp r12, 0						; ��������� j � 0
		jl m4							; ���� j < 0, ������� � m4
		mov r11, [r9+8*r12]				; r11 = b[j]
		mov [rcx+8*r13], r11			; sum[k] = b[j]
		dec r12							; j--
		dec r13							; k--
		jmp m3
	m4:
	mov rax, r14						; ������������ ��������� �������� max(deg_a, deg_b)
	; �������������� �������� ���������
	pop r14
	pop r13
	pop r12
	ret
PolySum ENDP

END