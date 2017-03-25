#pragma once

namespace paracrypt {

    template<typename S>
    class GPUCipherDevice {
      public:
    virtual ~GPUCipherDevice() {}
	virtual int getThreadsPerThreadBlock() = 0;
	virtual int getNWarpsPerBlock() = 0;
	virtual int getMaxBlocksPerSM() = 0;
	virtual int getConcurrentKernels() = 0;
	int getGridSize(int n_blocks, int threadsPerCipherBlock);
	virtual void set(); // must be called to set operations to this device
	virtual void malloc(void* data, int size);
	virtual void free(void* data);
	virtual void memcpyTo(void* host, void* dev, int size, S stream) = 0; // Async
	virtual void memcpyFrom(void* dev, void* host, int size, S stream) = 0; // Sync
	virtual S getNewStream();
	virtual void freeStream(S s);
   };

}
