// Lab1_Kraychik_5.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <iostream>

typedef __int64 GF2_64;
using namespace std;

const int size = 8 * sizeof(GF2_64);
extern "C" void add128();
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
	GF2_64 res = a;
	//for (int i = 0; i < size - 1; i++)
	for (;;)
	{
		GF2_64 tmp = GF_Multiply_test(res, a);
		if (tmp == 1) { return res; }
		else res = tmp;
	}
	return res;
}
int PolyMulX_test(GF2_64 *a, int deg)
{
	a[deg+1] = 0;
	return deg + 1;
}
int PolyMulConst_test(GF2_64 *a, int deg, GF2_64 c)
{
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
	return deg;
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
int _tmain(int argc, _TCHAR* argv[])
{
	GF2_64 x, y, z;
	GF2_64 a[10] = { 2, 0, 8, -3, 0, 0, 0, 0, 0, 0 };
	GF2_64 b[10] = { 1, 3, 4, 0, 0, 0, 0, 0, 0, 0 };
	GF2_64 sum[15] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
	int deg = PolyZero_test(a, 2);
	x = 2;
	y = 20;
	cout << (int)y << endl;
	cout << (int)GF_Reciprocal_test(x) << endl;
	/*
	for (int i = 0; i <= deg; i++)
	{
		cout << sum[i] << " " << endl;
	}
	*/
	cout << endl;
	cin >> z;
	return 0;
}

