#include "MyComplex.h"


MyComplex::MyComplex()
{
}

void MyComplex::ADD(int width1, int height1)
{
	width = width1;
	height = height1;
	cmplx = new complex<double>* [width];

	for (int i = 0; i < width; i++)
		cmplx[i] = new complex<double>[height];

	for (int i = 0; i < width; i++)
	{
		for (int j = 0; j < height; j++)
		{
			cmplx[i][j] = complex<double>(0.0, 0.0);
		}
	}
}

void MyComplex::ArrayToComplex(MyArray* array, int am){

	if (cmplx == NULL){
		ADD(array->width, array->height);
	}
	/*if (bmp == NULL){
	return;
	}*/

	double max = array->getMax();
	double min = array->getMin();;

	for (int i = 0; i < width; i++)
	{
		for (int j = 0; j < height; j++)
		{
			double a = array->array[i][j];
			a = (a - min)*2.0*M_PI / (max - min);
			a = a - M_PI;
			cmplx[i][j] = polar((double)am, a); //Complex.FromPolarCoordinates(am, a);

		}
	}

}

void MyComplex::RE(MyArray* array){
	for (int i = 0; i < width; i++)
	for (int j = 0; j < height; j++)
		array->array[i][j] = cmplx[i][j].real();
}
void MyComplex::IM(MyArray* array){
	for (int i = 0; i < width; i++)
	for (int j = 0; j < height; j++)
		array->array[i][j] = cmplx[i][j].imag();

}
void MyComplex::PHASE(MyArray* array){
	for (int i = 0; i < width; i++)
	for (int j = 0; j < height; j++)
		array->array[i][j] = arg(cmplx[i][j]);

}
void MyComplex::AMP(MyArray* array){
	for (int i = 0; i < width; i++)
	for (int j = 0; j < height; j++)
		array->array[i][j] = norm(cmplx[i][j]);

}