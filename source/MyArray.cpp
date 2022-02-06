#include "MyArray.h"

MyArray::MyArray()
{
}


void MyArray::ADD(int width1, int height1)
{
	width = width1;
	height = height1;
	array = new double*[width];

	for (int i = 0; i < width; i++)
		array[i] = new double[height];

	for (int i = 0; i < width; i++)
	{
		for (int j = 0; j < height; j++)
		{
			array[i][j] = 0.0;
		}
	}
}

void MyArray::ImageToArray(double** bmp, int width1, int height1){

	if (array == NULL){
		ADD(width1, height1);
	}
	/*if (bmp == NULL){
	return;
	}*/

	/*double max = SumClass.getMax(descriptorToCopy);
	double min = SumClass.getMin(descriptorToCopy);*/

	for (int i = 0; i < width1; i++)
	{
		for (int j = 0; j < height1; j++)
		{
			
			array[i][j] = bmp[i][j];

		}
	}

}

/*void MyArray::ArrayToImage(double** bmp, int width1, int height1){

	if (array == NULL){
		ADD(width1, height1);
	}
	/*if (bmp == NULL){
	return;
	}*/

	/*double max = SumClass.getMax(descriptorToCopy);
	double min = SumClass.getMin(descriptorToCopy);*/

	/*for (int i = 0; i < width1; i++)
	{
		for (int j = 0; j < height1; j++)
		{

			array[i][j] = bmp[i][j];

		}
	}

}*/

double MyArray::getMax(){

	double max = numeric_limits<double>::min();

	for (int i = 0; i < width; i++)
	{
		for (int j = 0; j < height; j++)
		{
			// max = Math.Max(max, newDescriptor.array[i, j]);
			if (max < array[i][j]) max = array[i][j];
		}
	}

	return max;
}
double MyArray::getMin(){

	double min = numeric_limits<double>::max();

	for (int i = 0; i < width; i++)
	{
		for (int j = 0; j < height; j++)
		{
			//min = Math.Min(min, newDescriptor.array[i, j]);
			if (min > array[i][j]) min = array[i][j];
		}
	}

	return min;
}
