#include <cufft.h>
#include <cuda.h>
#include <cuda_runtime.h>
#include <string>
#include <iostream>
#include <complex>
#include "MyComplex.h"


void Start_Cuda(MyComplex cmplx, MyComplex revcmplx, bool or);
std::string INFO();