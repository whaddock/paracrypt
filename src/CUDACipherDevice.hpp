#pragma once

#include "GPUCipherDevice.hpp"
#include "cuda.h"
#include "cuda_runtime_api.h"

namespace paracrypt {

    class CUDACipherDevice:public GPUCipherDevice<cudaStream_t> {
      private:
	int device;
	cudaDeviceProp devProp;
	int maxCudaBlocksPerSM;
	int nWarpsPerBlock;
	int nThreadsPerThreadBlock;
	int nConcurrentKernels;
#define HANDLE_ERROR( err ) (HandleError( err, __FILE__, __LINE__ ))
	static void HandleError(cudaError_t err,
				const char *file, int line);
      public:
	// 0 <= device < cudaGetDeviceCount()
	 CUDACipherDevice(int device);
	int getNWarpsPerBlock();
	int getThreadsPerThreadBlock();
	int getMaxBlocksPerSM();
	int getConcurrentKernels();
	int getGridSize(int n_blocks, int threadsPerCipherBlock);
	const cudaDeviceProp* getDeviceProperties();
	void set();
	void malloc(void** data, int size);
	void free(void* data);
	void memcpyTo(void* host, void* dev, int size, cudaStream_t stream);
	void memcpyFrom(void* dev, void* host, int size, cudaStream_t stream);
	//void waitMemCpyFrom(); // TODO esperar a evento creado.
	//void  // TODO dos metodos: cudaEventQuery (status) y
	// http://docs.nvidia.com/cuda/cuda-runtime-api/group__CUDART__EVENT.html#axzz4cLExjEKQ
	cudaStream_t getNewStream();
	// callback K20 or newer
	// cudaStreamAddCallback - The function to call once preceding stream operations are complete
	// Read more at: http://docs.nvidia.com/cuda/cuda-runtime-api/index.html#ixzz4cLGwiYHH
	void freeStream(cudaStream_t s);
    };

}
