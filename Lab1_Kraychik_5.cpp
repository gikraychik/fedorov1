﻿/*
	Функции, написанные на языке С++, предназначенные для тестирования функций, написанных
	на языке ассемблера, имеют в своем названии префикс _test
	(например, GF_MulX_test)
*/
#include "stdafx.h"
#include <iostream>
#include <time.h>
#include <conio.h>

typedef __int64 GF2_64;
using namespace std;

const int size = 8 * sizeof(GF2_64);  // размер в битах типа данных GF2_64

extern "C" // перечисленные функции написаны на языке ассемблера
{
	GF2_64 GF_MulX(GF2_64 a);
	GF2_64 GF_PowX(unsigned int Power);
	GF2_64 GF_Multiply(GF2_64 a, GF2_64 b);
	GF2_64 GF_Reciprocal(GF2_64 a);
	int PolyMulX(GF2_64 *a, int deg);
	int PolyMulConst(GF2_64 *a, int deg, GF2_64 c);
	int PolyZero(GF2_64 *a, int deg);
	int PolyCpy(GF2_64 *dest, GF2_64 *src, unsigned char deg);
	int PolySum(GF2_64 *sum, GF2_64 *a, int deg_a, GF2_64 *b, int deg_b);
}

GF2_64 add_test(GF2_64 a, GF2_64 b)  //складывает два элемента поля
{
	return (a ^ b);
}

GF2_64 GF_MulX_test(GF2_64 a)
{
	GF2_64 b = (a < 0) ? 27 : 0;
	return (a << 1) ^ b;
}
GF2_64 GF_PowX_test(unsigned int Power)
{
	GF2_64 result = 1;
	for (int i = 0; i < Power; i++)
	{
		result = GF_MulX_test(result);
	}
	return result;
}
GF2_64 GF_Multiply_test(GF2_64 a, GF2_64 b)
{
	GF2_64 result = 0;
	unsigned __int64 right_bit = 0;
	GF2_64 mul = 0;
	for (int i = 0; i < size; i++)
	{
		right_bit = (b >> i) % 2;
		if (right_bit)
		{
			mul = a;
			for (int j = 0; j < i; j++)
			{
				mul = GF_MulX_test(mul);
			}
		}
		else { mul = 0; }
		result = add_test(result, mul);
	}
	return (GF2_64)result;
}
GF2_64 GF_Reciprocal_test(GF2_64 a)
{
	GF2_64 tmp = GF_Multiply_test(a, a);
	GF2_64 res = tmp;
	for (int i = 1; i <= 62; i++)
	{
		tmp = GF_Multiply_test(tmp, tmp);
		res = GF_Multiply_test(res, tmp);
	}
	return res;
}
int PolyMulX_test(GF2_64 *a, int deg)
{
	if (deg == -1) { return -1; }
	a[deg+1] = 0;
	return deg + 1;
}
int PolyMulConst_test(GF2_64 *a, int deg, GF2_64 c)
{
	if (c == 0) { return -1; }
	for (int i = 0; i <= deg; i++)
	{
		a[i] = GF_Multiply_test(a[i], c);
	}
	return deg;
}
int PolyZero_test(GF2_64 *a, int deg)
{
	for (int i = 0; i <= deg; i++)
	{
		a[i] = 0;
	}
	return -1;
}
int PolySum_test(GF2_64 *sum, GF2_64 *a, int deg_a, GF2_64 *b, int deg_b)
{
	int deg_sum = ::max(deg_a, deg_b);
	int i;
	int j;
	int k = deg_sum;
	for (i = deg_a, j = deg_b; i >= 0 && j >= 0; i--, j--)
	{
		sum[k] = add_test(a[i], b[j]);
		k--;
	}
	for (int itr = i; itr >= 0; itr--)
	{
		sum[k] = a[itr];
		k--;
	}
	for (int itr = j; itr >= 0; itr--)
	{
		sum[k] = b[itr];
		k--;
	}
	return deg_sum;
}
int PolyCpy_test(GF2_64 *dest, GF2_64 *src, unsigned char deg)
{
	for (int i = 0; i <= deg; i++)
	{
		dest[i] = src[i];
	}
	return deg;
}

#define TEST_SIZE 10000  // количество тестов (итераций цикла при тестировании фунцкий)
#define ARR_SIZE 100 // максимальный размер массива при тестировании полиномов

bool arrs_eq(GF2_64 *a, int deg_a, GF2_64 *b, int deg_b)  // проверяет равны ли многочлены
{
	if (deg_a != deg_b) { return false; }
	for (int i = 0; i <= deg_a; i++)
	{
		if (a[i] != b[i]) { return false; }
	}
	return true;
}
bool is_zero(GF2_64 *a, int deg_a)  // проверяет, равен ли многочлен 0 (заполнились ли его коэффиценты нулями)
{
	for (int i = 0; i <= deg_a; i++)
	{
		if (a[i] != 0) { return false; }
	}
	return true;
}
GF2_64 random()  // возвращает случайный элемент поля GF2_64
{
	GF2_64 res = 0;
	for (int i = 0; i < size; i++)
	{
		res += (::rand() % 2);
		res = res << 1;
	}
	return res;
}

int _tmain(int argc, _TCHAR* argv[])
{
	GF2_64 a_test, b_test, c_test;
	srand((unsigned)time(NULL));
	cout << "Testing field functions:" << endl;
	for (int i = 0; i < TEST_SIZE; i++)
	{
		a_test = random();
		b_test = random();
		unsigned int Power = ((unsigned int)a_test) % 100;  
		if (GF_MulX(a_test) != GF_MulX_test(a_test))
		{
			cout << "Error in GF_MulX" << endl;
		}
		if (GF_PowX_test(Power) != GF_PowX(Power))
		{
			cout << "Error in GF_PowX" << endl;
		}
		if (GF_Multiply_test(a_test, b_test) != (GF_Multiply(a_test, b_test)))
		{
			cout << "Error in GF_Multiply" << endl;
		}
		if (GF_Reciprocal_test(a_test) != GF_Reciprocal(a_test))
		{
			cout << "Error in GF_Reciprocal" << endl;
		}
		if (i % (TEST_SIZE / 10) == 0)
		{
			cout << i << endl;
		}
	}
	cout << "Testing polinoms:" << endl;
	int deg_a, deg_b;
	int deg, deg_test;
	for (int i = 0; i < TEST_SIZE; i++)
	{
		deg_a = (::rand() % ARR_SIZE) - 1;
		deg_b = deg_a;
		GF2_64 *a = new GF2_64[deg_a+2];
		GF2_64 *b = new GF2_64[deg_a+2];
		for (int j = 0; j <= deg_a; j++)
		{
			a[j] = random();
			b[j] = a[j];
		}
		deg = PolyMulX(a, deg_a);
		deg_test = PolyMulX_test(b, deg_b);
		if (!arrs_eq(a, deg, b, deg_test))
		{
			cout << "Error in PolyMulX" << endl;
		}
		for (int j = 0; j <= deg_a; j++)
			b[j] = a[j];
		GF2_64 cnst = random();
		deg = PolyMulConst(a, deg_a, cnst);
		deg_test = PolyMulConst_test(b, deg_a, cnst);
		if (!arrs_eq(a, deg, b, deg_test))
		{
			cout << "Error in PolyMulConst" << endl;
		}
		deg = PolyZero(a, deg_a);
		if ((deg != -1) || (!is_zero(a, deg_a)))
		{
			cout << "Error in PolyZero" << endl;
		}
		unsigned char pos_deg = (unsigned char)deg_a;
		delete[] a;
		delete[] b;
		a = new GF2_64[pos_deg+1];
		b = new GF2_64[pos_deg+1];
		for (int i = 0; i <= pos_deg; i++)
		{
			a[i] = random();
		}
		if (pos_deg == 255)
		{
			int p = 0;
		}
		deg = PolyCpy(b, a, pos_deg);
		if (!arrs_eq(a, pos_deg, b, deg))
		{
			cout << "Error in PolyCpy" << endl;
		}
		delete[] a;
		delete[] b;
		deg_a = (::rand() % ARR_SIZE) - 1;
		deg_b = (::rand() % ARR_SIZE) - 1;
		a = new GF2_64[deg_a+1];
		b = new GF2_64[deg_b+1];
		for (int j = 0; j <= deg_a; j++)
		{
			a[j] = random();
		}
		for (int j = 0; j <= deg_b; j++)
		{
			b[j] = random();
		}
		int deg_sum = ::max(deg_a, deg_b);
		GF2_64 *sum = new GF2_64[deg_sum+1];
		GF2_64 *sum_test = new GF2_64[deg_sum+1];
		deg_sum = PolySum(sum, a, deg_a, b, deg_b);
		int deg_sum_test = PolySum_test(sum_test, a, deg_a, b, deg_b);
		if (!arrs_eq(sum, deg_sum, sum_test, deg_sum_test))
		{
			cout << "Error in PolySum" << endl;
		}
		if (i % (TEST_SIZE / 10) == 0)
		{
			cout << i << endl;
		}
		delete[] a;
		delete[] b;
	}
	cout << "Press any key to continue..." << endl;
	_getch();
	return 0;
}

