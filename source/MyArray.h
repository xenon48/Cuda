#pragma once
#include <stdio.h>
#include <limits>



using namespace std;

class MyArray
{
public:
	MyArray();
	void ADD(int, int);
	void ImageToArray(double** , int, int);
	double getMax();
	double getMin();
	double** array;
	int width;
	int height;
};