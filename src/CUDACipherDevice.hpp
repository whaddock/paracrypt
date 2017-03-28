#pragma once

#include "GPUCipherDevice.hpp"
#include "cuda.h"
#include "cuda_runtime_api.h"

namespace paracrypt {

	template<typename S,typename F> class CUDACipherDevice:public GPUCipherDevice<S,F>{};

	template<>
    class CUDACipherDevice<cudaStream_t,cudaStreamCallback_t>:public GPUCipherDevice<cudaStream_t,cudaStreamCallback_t> {
      private:
	int device;
	cudaDeviceProp devProp;
	int maxCudaBlocksPerSM;
	int nWarpsPerBlock;
	int nThreadsPerThreadBlock;
	int nConcurrentKernels;
//	boost::unordered_map<int,cudaEvent_t> cpyFromEvents;
//	boost::unordered_map<int,cudaStreamCallback_t> cpyFromCallbacks;
#ifdef DEBUG
	#define HANDLE_ERROR( err ) (HandleError( err, __FILE__, __LINE__ ))
#else
	#define HANDLE_ERROR( err ) (err)
#endif
	static void HandleError(cudaError_t err,
				const char *file, int line);
      protected:
	cudaStream_t newStream();
	void freeStream(cudaStream_t s);
      public:
	// 0 <= device < cudaGetDeviceCount()
	 CUDACipherDevice(int device);
	int getNWarpsPerBlock();
	int getThreadsPerThreadBlock();
	int getMaxBlocksPerSM();
	int getConcurrentKernels();
	const cudaDeviceProp* getDeviceProperties();
	void set();
	void malloc(void** data, int size);
	void free(void* data);
	void memcpyTo(void* host, void* dev, int size, int stream_id);
	void memcpyFrom(void* dev, void* host, int size, int stream_id);
	void waitMemcpyFrom(int stream_id);
	int checkMemcpyFrom(int stream_id);
	void setMemCpyFromCallback(int stream_id, cudaStreamCallback_t func);
	int addStream(); // thread-safe
	void delStream(int stream_id); // thread-safe
    };
}
