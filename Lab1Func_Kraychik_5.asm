.CODE
sum proc
	add rcx, rdx
	mov rax, rcx
	ret
sum endp

GF_MulX PROC			; rcx - a
	mov r8, rcx			; копирование rcx на r8
	sal rcx, 1			; умножение a на x
						; далее процесс факторизации
	sar r8, 63			; заполнение r8 своим старшим разрядом
	xor rcx, r8			; факторизация многочлена
	mov rax, rcx
	ret
GF_MulX ENDP

GF_PowX PROC			; rcx - Power
	; сохранение значений регистров на стек
	push rbx
	push rbp
	mov rbp, 1			; присвоение начального значения
						; далее следует цикл с Power итераций
						; на rcx уже лежит Power
	jrcxz m1			; если rcx == 0, не выполнять цикл
	m2:
		mov rbx, rcx	; копирование rcx на rbx
		mov rcx, rbp	; запись на rcx rbp, чтобы передать в функцию rbp
						; в качестве параметра функции
		call GF_MulX
		mov rbp, rax	; запись результата работы функции на rbp
		mov rcx, rbx	; восстановление счетчика на rcx
		loop m2			; вычитание единицы из rcx и проверка на продолжение цикла
	m1:
	mov rax, rbp		; на rax находится возвращаемое значение
	; восстановление значений
	pop rbp
	pop rbx
	ret
GF_PowX ENDP

get_bit PROC			; rcx - элемент GF2_64
						; rdx - номер бита
	mov r8, rcx			; копирование rcx на r8
	mov cl, dl			
	ror r8, cl			; теперь искомый бит находится в нулевом бите
	mov r9, r8			; копирование r8 на r9
	; выделение нулевого бита
	sar r8, 1
	sal r8, 1
	xor r8, r9			; в r8 хранится результат
	mov rax, r8
	ret
get_bit ENDP

GF_Multiply PROC		; rcx - a
						; rdx - b
	; сохранение значений в стеке для последующего восстановления
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
	xor rsi, rsi		; rsi - количество итераций цикла
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
	; восстановление значений
	pop rsi
	pop r12
	pop r13
	pop r14
	pop r15
	ret
GF_Multiply ENDP

GF_Reciprocal PROC		; rcx - a (элемент поля)
	
	ret
GF_Reciprocal ENDP

PolyMulX PROC			; rcx - указатель на многочлен a
						; rdx - степень многочлена deg, тип данных int
	mov rax, -1			; если deg == -1, вернем значение -1
	cmp edx, -1			; тип int является 32-битным
	je m1				; если deg == 1, конец функции
	inc rdx				; степень результата на 1 больше степени многочлена
	mov r8, rdx			; подготовка к умножению
	mov rax, 8			; каждая переменная GF2_64 занимает 8 байт
	imul rdx			; в rax находится величина сдвига в массиве
	mov r9, 0			; при умножении на x, коэффицент
						; при младшей степени становится нулем
	mov [rcx+rax], r9	; a[deg+1] = 0
	mov rax, r8			; возвращается степень нового многочлена
	m1:
	ret
PolyMulX ENDP

PolyMulConst PROC		; rcx - указатель на массив a
						; rdx - степень многочлена deg, имеет тип int
						; r8 - элемент поля GF2_64
	; если константа равна 0, вернем степень -1
	mov rax, -1			
	cmp r8, 0			; сравнение константы с нулем
	je m3				; если константа равна 0, прекращаем работу функции
	cmp edx, -1			; сравнение степени с -1
	je m3				; если они равны, завершить процедуру, вернув -1
	; сохранение значений в стеке
	push r15
	push r14
	push r13
	push rsi
	; сохранение значений rcx, rdx, r8
	mov r15, rcx
	mov r14, rdx
	mov r13, r8
	xor rsi, rsi		; обнуление счетчика для цикла
	m2:
		cmp rsi, r14			; сравнение счетчика и deg
		jg m1					; если rsi > deg прерываем цикл
		mov rcx, [r15+8*rsi]	; вычисление адреса текущего коэффицента многочлена
								; и запись его на регистр rcx
		mov rdx, r13			; запись константы на rdx
		call GF_Multiply		; нахождение произведения rcx и rdx
		mov [r15+8*rsi], rax	; запись произведения в массив
		inc rsi					; увеличение счетчика на единицу
		jmp m2
	m1:
	; восстановление значений из стека
	mov rax, r14				; возвращаемым значением является степень многочлена
	pop rsi
	pop r13
	pop r14
	pop r15
	m3:
	ret
PolyMulConst ENDP
END