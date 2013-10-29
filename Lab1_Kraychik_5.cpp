// Lab1_Kraychik_5.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <iostream>

typedef __int64 GF2_64;
using namespace std;

GF2_64 add(GF2_64 a, GF2_64 b)  //складывает два элемента поля
{
	return a ^ b;
}

GF2_64 GF_MulX(GF2_64 a)
{
	return (__int64)((a << 1) ^ (a >> 63));
}
GF2_64 GF_PowX(unsigned int Power)
{
	GF2_64 result = 1;
	for (int i = 0; i < Power; i++)
	{
		result = GF_MulX(result);
	}
	return result;
}
GF2_64 GF_Multiply(GF2_64 a, GF2_64 b)
{
	GF2_64 result = 0;
	unsigned __int64 right_bit = 0;
	GF2_64 mul = 0;
	for (int i = 0; i < 64; i++)
	{
		right_bit = (b >> i) % 2;
		if (right_bit)
		{
			mul = a;
			for (int j = 0; j < i; j++)
			{
				mul = GF_MulX(mul);
			}
		}
		else { mul = 0; }
		result = add(result, mul);
	}
	return result;
}
GF2_64 GF_Reciprocal(GF2_64 a)
{
	GF2_64 x = a;
	unsigned __int64 b = (x < 0) ? x + 9223372036854775808 : x;  //2^63

	return 0;
}
int PolyMulX(GF2_64 *a, int deg)
{
	a[deg+1] = 0;
	return deg + 1;
}
int PolyMulConst(GF2_64 *a, int deg, GF2_64 c)
{
	for (int i = 0; i <= deg; i++)
	{
		a[i] = GF_Multiply(a[i], c);
	}
	return deg;
}
int PolyZero(GF2_64 *a, int deg)
{
	for (int i = 0; i <= deg; i++)
	{
		a[i] = 0;
	}
	return deg;
}
int PolySum(GF2_64 *sum, GF2_64 *a, int deg_a, GF2_64 *b, int deg_b)
{
	int deg_sum = (deg_a < deg_b) ? deg_b : deg_a;
	int i;
	int j;
	int k = deg_sum;
	for (i = deg_a, j = deg_b; i >= 0 && j >= 0; i--, j--)
	{
		sum[k] = add(a[i], b[j]);
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
int PolyCpy(GF2_64 *dest, GF2_64 *src, unsigned char deg)
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
	int deg = PolyZero(a, 2);
	for (int i = 0; i <= deg; i++)
	{
		cout << sum[i] << " " << endl;
	}
	cout << endl;
	cin >> z;
	return 0;
}

