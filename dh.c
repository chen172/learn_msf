#include <stdio.h>
#include <math.h>

int main()
{
	double p = 191;
	double g = 2;
	// Alice
	double A_x = 42;
	//resultA是20
	double resultA = (unsigned long long)pow(g, A_x) % (unsigned long long)p;
	
	//Bob
	double B_x = 33;
	//resultB是103
	double resultB = (unsigned long long)pow(g, B_x) % (unsigned long long)p;
	
	//数据量太大，算不出来
	//keyA
	double keyA = (unsigned long long)pow(resultB, A_x) % (unsigned long long)p;
	printf("resultB is %f\n", keyA);
	//keyB
	double keyB = (unsigned long long)pow(resultA, B_x) % (unsigned long long)p;
	printf("keyA is %f\n", keyA);
	printf("keyB is %f\n", keyB);
	return 0;
}
	
	
