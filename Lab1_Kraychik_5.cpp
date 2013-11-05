// Lab1_Kraychik_5.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <iostream>
#include <time.h>

typedef __int64 GF2_64;
using namespace std;

const int size = 8 * sizeof(GF2_64);

extern "C"
{
	int sum(int x, int y);
	//GF2_64 add_field(GF2_64 a, GF2_64 b);
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
	return a ^ b;
}

GF2_64 GF_MulX_test(GF2_64 a)
{
	return (GF2_64)((a << 1) ^ (a >> (size - 1)));
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
	GF2_64 res = 1;
	//for (int i = 0; i < size - 1; i++)
	/*for (;;)
	{
		GF2_64 tmp = GF_Multiply_test(res, a);
		if (tmp == 1) { return res; }
		else res = tmp;
	}*/
	for (int i = 0; i < size; i++)
	{
		if (res == 1)
		{
			int k = 0;
		}
		res = GF_Multiply_test(res, a);
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
	int deg_sum = (deg_a < deg_b) ? deg_b : deg_a;
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
GF2_64 random()
{
	GF2_64 res = 0;
	for (int i = 0; i < size; i++)
	{
		res += (::rand() % 2);
		res = res << 1;
	}
	return res;
}
GF2_64 get_bit(GF2_64 a, GF2_64 pos);
#define TEST_SIZE 100000
int _tmain(int argc, _TCHAR* argv[])
{
	GF2_64 a_test, b_test, c_test;
	//GF2_64 a, b, c;
	GF2_64 l = 251;
	GF2_64 a1 = GF_Reciprocal_test(l);
	GF2_64 a2 = GF_Multiply(l, a1);
	GF2_64 x, y, z;
	GF2_64 a[10] = { 2, 0, 8, -3, 2, 0, 0, 0, 0, 0 };
	GF2_64 b[10] = { 1, 3, 4, 9, 1, 0, 0, 0, 0, 0 };
	GF2_64 sum[15] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
	int deg = PolySum(sum, a, 2, b, 3);
	srand((unsigned)time(NULL));
	/*for (GF2_64 i = 0; i < 64; i++)
	{
		cout << get_bit(l, tmp-i);
	}
	cout << endl;*/
	for (int i = 0; i < TEST_SIZE; i++)
	{
		a_test = random();
		b_test = random();
		unsigned int Power = (unsigned int)random() % 70;
		GF2_64 a1 = GF_Multiply_test(a_test, b_test);
		GF2_64 a2 = GF_Multiply(a_test, b_test);
		if (a1 != a2)
		{
			cout << "Error in GF_MulX" << endl;
		}
		if (i % (TEST_SIZE / 10) == 0)
		{
			cout << i << endl;
		}
	}
	/*
	GF2_64 x, y, z;
	GF2_64 a[10] = { 2, 0, 8, -3, 0, 0, 0, 0, 0, 0 };
	GF2_64 b[10] = { 1, 3, 4, 0, 0, 0, 0, 0, 0, 0 };
	GF2_64 sum[15] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
	int deg = PolyZero_test(a, 2);
	x = 2;
	y = 20;
	cout << (int)y << endl;
	cout << (int)GF_Reciprocal_test(x) << endl;
	*/
	/*
	for (int i = 0; i <= deg; i++)
	{
		cout << sum[i] << " " << endl;
	}
	*/
	cin >> z;
	return 0;
}

