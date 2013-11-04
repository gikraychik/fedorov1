.CODE
sum proc
	add rcx, rdx
	mov rax, rcx
	ret
sum endp

GF_MulX PROC			; rcx - a
	mov r8, rcx			; ����������� rcx �� r8
	sal rcx, 1			; ��������� a �� x
						; ����� ������� ������������
	sar r8, 63			; ���������� r8 ����� ������� ��������
	xor rcx, r8			; ������������ ����������
	mov rax, rcx
	ret
GF_MulX ENDP

GF_PowX PROC			; rcx - Power
	; ���������� �������� ��������� �� ����
	push rbx
	push rbp
	mov rbp, 1			; ���������� ���������� ��������
						; ����� ������� ���� � Power ��������
						; �� rcx ��� ����� Power
	jrcxz m1			; ���� rcx == 0, �� ��������� ����
	m2:
		mov rbx, rcx	; ����������� rcx �� rbx
		mov rcx, rbp	; ������ �� rcx rbp, ����� �������� � ������� rbp
						; � �������� ��������� �������
		call GF_MulX
		mov rbp, rax	; ������ ���������� ������ ������� �� rbp
		mov rcx, rbx	; �������������� �������� �� rcx
		loop m2			; ��������� ������� �� rcx � �������� �� ����������� �����
	m1:
	mov rax, rbp		; �� rax ��������� ������������ ��������
	; �������������� ��������
	pop rbp
	pop rbx
	ret
GF_PowX ENDP

get_bit PROC			; rcx - ������� GF2_64
						; rdx - ����� ����
	mov r8, rcx			; ����������� rcx �� r8
	mov cl, dl			
	ror r8, cl			; ������ ������� ��� ��������� � ������� ����
	mov r9, r8			; ����������� r8 �� r9
	; ��������� �������� ����
	sar r8, 1
	sal r8, 1
	xor r8, r9			; � r8 �������� ���������
	mov rax, r8
	ret
get_bit ENDP

GF_Multiply PROC		; rcx - a
						; rdx - b
	; ���������� �������� � ����� ��� ������������ ��������������
	push r15
	push r14
	push r13
	push r12
	push rsi
	
	mov r15, rcx
	mov r14, rdx
	mov rcx, rdx
	mov rdx, 0
	call get_bit
	imul r15
	mov r13, rax
	mov r12, r15
	xor rsi, rsi		; rsi - ���������� �������� �����
	m1:
		cmp rsi, 63
		je m2
		inc rsi
		mov rcx, r12
		call GF_MulX
		mov r12, rax
		mov rcx, r14
		mov rdx, rsi
		call get_bit
		imul r12
		xor r13, rax
		jmp m1
	m2:
	mov rax, r13
	; �������������� ��������
	pop rsi
	pop r12
	pop r13
	pop r14
	pop r15
	ret
GF_Multiply ENDP

GF_Reciprocal PROC		; rcx - a (������� ����)
	
	ret
GF_Reciprocal ENDP

PolyMulX PROC			; rcx - ��������� �� ��������� a
						; rdx - ������� ���������� deg, ��� ������ int
	mov rax, -1			; ���� deg == -1, ������ �������� -1
	cmp edx, -1			; ��� int �������� 32-������
	je m1				; ���� deg == 1, ����� �������
	inc rdx				; ������� ���������� �� 1 ������ ������� ����������
	mov r8, rdx			; ���������� � ���������
	mov rax, 8			; ������ ���������� GF2_64 �������� 8 ����
	imul rdx			; � rax ��������� �������� ������ � �������
	mov r9, 0			; ��� ��������� �� x, ����������
						; ��� ������� ������� ���������� �����
	mov [rcx+rax], r9	; a[deg+1] = 0
	mov rax, r8			; ������������ ������� ������ ����������
	m1:
	ret
PolyMulX ENDP

PolyMulConst PROC		; rcx - ��������� �� ������ a
						; rdx - ������� ���������� deg, ����� ��� int
						; r8 - ������� ���� GF2_64
	; ���� ��������� ����� 0, ������ ������� -1
	mov rax, -1			
	cmp r8, 0			; ��������� ��������� � �����
	je m3				; ���� ��������� ����� 0, ���������� ������ �������
	cmp edx, -1			; ��������� ������� � -1
	je m3				; ���� ��� �����, ��������� ���������, ������ -1
	; ���������� �������� � �����
	push r15
	push r14
	push r13
	push rsi
	; ���������� �������� rcx, rdx, r8
	mov r15, rcx
	mov r14, rdx
	mov r13, r8
	xor rsi, rsi		; ��������� �������� ��� �����
	m2:
		cmp rsi, r14			; ��������� �������� � deg
		jg m1					; ���� rsi > deg ��������� ����
		mov rcx, [r15+8*rsi]	; ���������� ������ �������� ����������� ����������
								; � ������ ��� �� ������� rcx
		mov rdx, r13			; ������ ��������� �� rdx
		call GF_Multiply		; ���������� ������������ rcx � rdx
		mov [r15+8*rsi], rax	; ������ ������������ � ������
		inc rsi					; ���������� �������� �� �������
		jmp m2
	m1:
	; �������������� �������� �� �����
	mov rax, r14				; ������������ ��������� �������� ������� ����������
	pop rsi
	pop r13
	pop r14
	pop r15
	m3:
	ret
PolyMulConst ENDP
END