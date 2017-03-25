#include "CUDACipherDevice.hpp"
#include "logging.hpp"

paracrypt::CUDACipherDevice::CUDACipherDevice(int device)
{
	this->nConcurrentKernels = 1;
    this->device = device;
    cudaGetDeviceProperties(&(this->devProp), device);

    // There is no CUDA API function for retreiving blocks per SM.
    // Manually set as described to fit CUDA documentation at table
    // 13 (Maximum number of resident blocks per multiprocessor):
    //  http://docs.nvidia.com/cuda/cuda-c-programming-guide/index.html#features-and-technical-specifications
    //
    int M = this->devProp.major;
    int m = this->devProp.minor;
    if (M <= 2) {
	this->maxCudaBlocksPerSM = 8;
    } else if (M <= 3 && m <= 7) {
	this->maxCudaBlocksPerSM = 16;
    } else { // cuda capability 5.0
	this->maxCudaBlocksPerSM = 32;
    }

    this->nWarpsPerBlock =
	this->devProp.maxThreadsPerBlock / this->devProp.warpSize;
    this->nThreadsPerThreadBlock =
	this->devProp.warpSize * this->nWarpsPerBlock /
	this->maxCudaBlocksPerSM;

	if(this->devProp.concurrentKernels) {
		// From Table 13. Technical Specifications per Compute Capability
		// Maximum number of resident grids per device (Concurrent Kernel Execution)
	    if (M <= 3) {
		this->nConcurrentKernels = 16;
	    } else if (M == 3 && m == 2) {
	    this->nConcurrentKernels = 4;
	    } else if (M <=5 && m <= 2) {
		this->maxCudaBlocksPerSM = 32;
	    }
	    else if (M == 5 && m == 3) {
	    	this->maxCudaBlocksPerSM = 16;
	    }
	    else if (M == 6 && m == 0) {
	    	this->maxCudaBlocksPerSM = 128;
	    }
	    else if (M == 6 && m == 1) {
	    	this->maxCudaBlocksPerSM = 32;
	    }
	    else {//if (M == 6 && m == 2) {
	    	this->maxCudaBlocksPerSM = 16;
	    }
	}
}

void paracrypt::CUDACipherDevice::HandleError(cudaError_t err,
					    const char *file, int line){
    if (err != cudaSuccess) {
    LOG_ERR(boost::format("%s in %s at line %d\n")
    % cudaGetErrorString(err) % file % line);
	exit(EXIT_FAILURE);
    }
}

// cudaStreamAddCallback(stream, MyCallback, (void*)i, 0);

int paracrypt::CUDACipherDevice::getNWarpsPerBlock()
{
    return this->nWarpsPerBlock;
}

int paracrypt::CUDACipherDevice::getThreadsPerThreadBlock()
{
    return this->nThreadsPerThreadBlock;
}

int paracrypt::CUDACipherDevice::getMaxBlocksPerSM()
{
    return this->maxCudaBlocksPerSM;
}

int paracrypt::CUDACipherDevice::getGridSize(int n_blocks, int threadsPerCipherBlock)
{
	int gridSize = n_blocks * threadsPerCipherBlock / this->getThreadsPerThreadBlock();
	return gridSize;
}

const cudaDeviceProp* paracrypt::CUDACipherDevice::getDeviceProperties()
{
    return &(this->devProp);
}

int paracrypt::CUDACipherDevice::getConcurrentKernels()
{
	return this->nConcurrentKernels;
}

void paracrypt::CUDACipherDevice::set()
{
	HANDLE_ERROR(cudaSetDevice(this->device));
}

void paracrypt::CUDACipherDevice::malloc(void** data, int size)
{
	HANDLE_ERROR(cudaMalloc(data,size));
}

void paracrypt::CUDACipherDevice::free(void* data)
{
	HANDLE_ERROR(cudaFree(data));
}

void paracrypt::CUDACipherDevice::memcpyTo(void* host, void* dev, int size, cudaStream_t stream)
{
	HANDLE_ERROR(cudaMemcpyAsync(dev, host, size, cudaMemcpyHostToDevice, stream));
}

void paracrypt::CUDACipherDevice::memcpyFrom(void* dev, void* host, int size, cudaStream_t stream)
{
	HANDLE_ERROR(cudaMemcpy(host, dev, size, cudaMemcpyDeviceToHost, stream));
}

cudaStream_t paracrypt::CUDACipherDevice::getNewStream()
{
	cudaStream_t s;
	HANDLE_ERROR(cudaStreamCreate(&s));
	return s;
}

void paracrypt::CUDACipherDevice::freeStream(cudaStream_t s)
{
	HANDLE_ERROR(cudaStreamDestroy(s));
}
