#pragma once
#include <complex>
#include <limits>
#include "MyArray.h"
#define M_PI 3.1415926535897932384626433832795
using namespace std;


class MyComplex
{
public:
	MyComplex();
	void ADD(int, int);
	void ArrayToComplex(MyArray* , int);
	void MyComplex::RE(MyArray* array);
	void MyComplex::IM(MyArray* array);
	void MyComplex::PHASE(MyArray* array);
	void MyComplex::AMP(MyArray* array);
	complex<double>** cmplx;
	int width;
	int height;
};

