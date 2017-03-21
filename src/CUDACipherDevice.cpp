#include "CUDACipherDevice.hpp"

paracrypt::CudaAES::CUDACipherDevice(int device)
{
	this->device = device;
	cudaGetDeviceProperties(&(this->devProp),device);

  	// There is no CUDA API function for retreiving blocks per SM.
  	// Manually set as described to fit CUDA documentation at table
  	// 13 (Maximum number of resident blocks per multiprocessor):
  	//  http://docs.nvidia.com/cuda/cuda-c-programming-guide/index.html#features-and-technical-specifications
  	//
	int M = this->devProp.major;
	int m = this->devProp.minor;
	if(M <= 2) {
		this->maxCudaBlocksPerSM = 8;
	}
	else if(M <= 3 && m <= 7) {
		this->maxCudaBlocksPerSM = 16;
	}
	else { // From cuda capability 5.0
		this->maxCudaBlocksPerSM = 32;
	} 

	this->nWarpsPerBlock = this->devProp.maxThreadsPerBlock/this->devProp.warpSize;
	this->nThreadsPerThreadBlock = this->devProp.warpSize * this->nWarpsPerBlock / this->maxCudaBlocksPerSM;
}

int paracrypt::CudaAES::CUDACipherDevice::getNWarpsPerBlock()
{
	return this->nWarpsPerBlock;
}

int paracrypt::CudaAES::CUDACipherDevice::getThreadsPerThreadBlock()
{
	return this->nThreadsPerThreadBlock;
}

int paracrypt::CudaAES::CUDACipherDevice::getMaxBlocksPerSM()
{
	return this->maxCudaBlocksPerSM;
}

const cudaDeviceProp* paracrypt::CudaAES::getDeviceProperties()
{
	return &(this->devProp);
}