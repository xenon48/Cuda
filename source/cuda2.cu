#include "cuda2.cuh"
#include <cufft.h>
#include <cuda.h>
#include <cuda_runtime.h>
#include <string>
#include <iostream>
#include <complex>
#include "MyComplex.h"
#include "device_launch_parameters.h"
#include <cuComplex.h>
#include <math.h>
using namespace std;
#define M_PI 3.1415926535897931
void CalcFFT(cuDoubleComplex* cuArr, int powerOfTwo, bool orientation);
void Blend(cuDoubleComplex* arr, int nx){

	cuDoubleComplex t;
	int i, j, k;
	int n1 = nx >> 1;

	for (i = 0, j = 0, k = n1; i < nx - 1; i++, j = j + k)
	{
		if (i < j)
		{
			t = arr[j];
			arr[j] = arr[i];
			arr[i] = t;
		}
		k = n1;
		while (k <= j)
		{
			j = j - k;
			k = k >> 1;
		}
	}


}
__global__ void FFT(cuDoubleComplex* array, int *ll1){

	
	cuDoubleComplex w, u, t;
	int ip;
	int idx = threadIdx.x;
	u = make_cuDoubleComplex(1.0, 0.0);
	w = make_cuDoubleComplex(cos(M_PI / (*ll1)), sin(M_PI / (*ll1)));
	if (idx >= *ll1){
		int mod = idx/(*ll1);
		idx = idx + (*ll1) * mod;
		int ctrl = idx - (*ll1) * mod * 2;
		for (int i = 0; i < ctrl; i++) {
			u = cuCmul(u, w);
		}
	}

	ip = idx + (*ll1);
	t = cuCmul(array[ip], u);
	array[ip] = cuCsub(array[idx], t);
	array[idx] = cuCadd(array[idx], t);

}
__global__ void iFFT(cuDoubleComplex* array, int *ll1){


	cuDoubleComplex w, u, t;
	int ip;
	int idx = threadIdx.x;
	u = make_cuDoubleComplex(1.0, 0.0);
	w = make_cuDoubleComplex(cos(M_PI / (*ll1)), sin(-M_PI / (*ll1)));
	if (idx >= *ll1){
		int mod = idx / (*ll1);
		idx = idx + (*ll1) * mod;
		int ctrl = idx - (*ll1) * mod * 2;
		for (int i = 0; i < ctrl; i++) {
			u = cuCmul(u, w);
		}
	}

	ip = idx + (*ll1);
	t = cuCmul(array[ip], u);
	array[ip] = cuCsub(array[idx], t);
	array[idx] = cuCadd(array[idx], t);


}

__global__ void DIV(cuDoubleComplex* array, int* powerOfTwo){

	double2 n;
	n.x = sqrt(pow(2.0,(double)(*powerOfTwo)));
	n.y = 0;
	int i = threadIdx.x;
	array[i] = cuCdiv(array[i], n);
}

void beforeFFT(MyComplex *cmplx, MyComplex *revcmplx, int powerOfTwo, bool orientation){

	int nx = cmplx->width;
	int ny = cmplx->height;
	cuDoubleComplex *cuArr = new cuDoubleComplex[nx];

	//столбцы
	for (int i = 0; i < nx; i++){
		for (int j = 0; j < ny; j++){
			cuArr[j] = make_cuDoubleComplex(cmplx->cmplx[j][i].real(), cmplx->cmplx[j][i].imag());
		}

		Blend(cuArr, nx);
		CalcFFT(cuArr,powerOfTwo,orientation);

		for (int j = 0; j < ny; j++){
			revcmplx->cmplx[j][i] = complex<double>(cuArr[j].x, cuArr[j].y);
		}

	}

	//строки
	for (int i = 0; i < nx; i++){
		for (int j = 0; j < ny; j++){
			cuArr[j] = make_cuDoubleComplex(revcmplx->cmplx[i][j].real(), revcmplx->cmplx[i][j].imag());
		}

		Blend(cuArr, nx);
		CalcFFT(cuArr, powerOfTwo, orientation);

		for (int j = 0; j < ny; j++){
			revcmplx->cmplx[i][j] = complex<double>(cuArr[j].x, cuArr[j].y);
		}
	}

}


void CalcFFT(cuDoubleComplex* cuArr, int powerOfTwo, bool orientation){

	int nx = pow(2.0, powerOfTwo);
	int *devll1, *PoW;
	dim3 grids = dim3(1, 1, 1);
	dim3 blocks = dim3(nx >> 1, 1, 1);
	cuDoubleComplex *devcuArr;
	cudaMalloc((cuDoubleComplex**)&devcuArr, sizeof(cuDoubleComplex)*nx);
	cudaMalloc((int**)&PoW, sizeof(int));
	cudaMemcpy(PoW, &powerOfTwo, sizeof(int), cudaMemcpyHostToDevice);
	cudaMalloc((int**)&devll1, sizeof(int));

		cudaMemcpy(devcuArr, cuArr, sizeof(cuDoubleComplex)*nx, cudaMemcpyHostToDevice);

		for (int i = 1; i <= powerOfTwo; i++){

			int ll = (pow(2.0, i));
			int ll1 = ll >> 1;
			cudaMemcpy(devll1, &ll1, sizeof(int), cudaMemcpyHostToDevice);
			if (orientation)
				FFT << <grids, blocks >> >(devcuArr, devll1); 
			else 
				iFFT << <grids, blocks >> >(devcuArr, devll1);

			cudaEvent_t syncEvent;
			cudaEventCreate(&syncEvent);    //Создаем event 
			cudaEventRecord(syncEvent, 0);  //Записываем event 
			cudaEventSynchronize(syncEvent);  //Синхронизируем event

		}
		DIV << <1, nx >> >(devcuArr, PoW);
		cudaMemcpy(cuArr, devcuArr, sizeof(cuDoubleComplex)*nx, cudaMemcpyDeviceToHost);

	cudaFree(devcuArr);
}


void Start_Cuda(MyComplex cmplx, MyComplex revcmplx, bool or){

	int m = 1;
	int n = cmplx.width;
	int nn = 2;

	for (int i = 1;; i++) { nn = nn * 2; if (nn > n) { n = nn / 2; m = i; break; } }
	beforeFFT(&cmplx, &revcmplx, m, or);
	

}
std::string INFO(){
	std::string str;
	int devices;
	cudaDeviceProp info;
	cudaGetDeviceCount(&devices);

	str = "Количество GPU поддерживаемых CUDA: ";
	str += std::to_string(devices);
	str += ";";

	for (int i = 0; i<devices; i++)
	{
		cudaGetDeviceProperties(&info, i);
		str += "Название GPU: ";
		str += info.name;
		str += ";";
		str += "Доступная память: ";
		str += std::to_string(info.totalGlobalMem / 1048576);
		str += " MB";
		str += ";";
		str += "Доступная постоянная память память: ";
		str += std::to_string(info.totalConstMem);
		str += " B";
		str += ";";
		str += "Общая память для блоков: ";
		str += std::to_string(info.sharedMemPerBlock);
		str += " B";
		str += ";";
		str += "Общее количество 32 - битных регистров: ";
		str += std::to_string(info.regsPerBlock);
		str += ";";
		str += "Размер Warp: ";
		str += std::to_string(info.warpSize);
		str += ";";
		str += "Максимальное количество потоков в блоке: ";
		str += std::to_string(info.maxThreadsPerBlock);
		str += ";";
		str += "Максимальный размер блока: ";
		str += std::to_string(info.maxThreadsDim[0]);
		for (int i = 1; i < 3; i++){
			str += "x";
			str += std::to_string(info.maxThreadsDim[i]);

		}
		str += ";";
		str += "Максимальный размер сетки: ";
		str += std::to_string(info.maxGridSize[0]);
		for (int i = 1; i < 3; i++){
			str += "x";
			str += std::to_string(info.maxGridSize[i]);


		}
		str += ";";
		str += "Тактовая частота: ";
		str += std::to_string(info.clockRate / 1000);
		str += " MHz";
		str += ";";
		str += "Частота шины: ";
		str += std::to_string(info.memoryClockRate / 1000);
		str += " MHz";
		str += ";";
		str += "Ширина шины: ";
		str += std::to_string(info.memoryBusWidth);
		str += ";";
		str += "Кэш l2: ";
		str += std::to_string(info.l2CacheSize);
		str += " B";
		str += ";";
	}
	return str;
}