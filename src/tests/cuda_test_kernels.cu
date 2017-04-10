#include "cuda_test_kernels.cuh"
#include "../CudaEcbAes16B.cuh"
#include "../cuda_logging.cuh"

__global__ void aes_add_16B_round_key_kernel
(
	uint32_t* data1,
	uint32_t* data2,
	uint32_t* data3,
	uint32_t* data4,
	uint32_t key1,
	uint32_t key2,
	uint32_t key3,
	uint32_t key4
)
{
	uint32_t dd1 = *data1;
	uint32_t dd2 = *data2;
	uint32_t dd3 = *data3;
	uint32_t dd4 = *data4;
//	__LOG_TRACE__("prev_dd1 = 0x%x",dd1);
//	__LOG_TRACE__("prev_pdd2 = 0x%x",dd2);
//	__LOG_TRACE__("prev_pdd3 = 0x%x",dd3);
//	__LOG_TRACE__("prev_pdd4 = 0x%x",dd4);
	aes_add_16B_round_key(dd1,dd2,dd3,dd4,key1,key2,key3,key4);
//	__LOG_TRACE__("dd1 = 0x%x",dd1);
//	__LOG_TRACE__("dd2 = 0x%x",dd2);
//	__LOG_TRACE__("dd3 = 0x%x",dd3);
//	__LOG_TRACE__("dd4 = 0x%x",dd4);
	*data1 = dd1;
	*data2 = dd2;
	*data3 = dd3;
	*data4 = dd4;
}

_16B aes_add_16B_round_key_call(
		uint32_t data1,
		uint32_t data2,
		uint32_t data3,
		uint32_t data4,
		uint32_t key1,
		uint32_t key2,
		uint32_t key3,
		uint32_t key4)
{
	uint32_t *dd1, *dd2, *dd3, *dd4;
	cudaMalloc(&dd1,sizeof(uint32_t));
	cudaMalloc(&dd2,sizeof(uint32_t));
	cudaMalloc(&dd3,sizeof(uint32_t));
	cudaMalloc(&dd4,sizeof(uint32_t));
	cudaMemcpy((void*)dd1, (void*)&data1, sizeof(uint32_t), cudaMemcpyHostToDevice);
	cudaMemcpy((void*)dd2, (void*)&data2, sizeof(uint32_t), cudaMemcpyHostToDevice);
	cudaMemcpy((void*)dd3 ,(void*)&data3, sizeof(uint32_t), cudaMemcpyHostToDevice);
	cudaMemcpy((void*)dd4, (void*)&data4, sizeof(uint32_t), cudaMemcpyHostToDevice);

	aes_add_16B_round_key_kernel<<<1,1>>>(dd1,dd2,dd3,dd4,key1,key2,key3,key4);

	_16B result;
	cudaMemcpy((void*)&result.w1, (void*)dd1, sizeof(uint32_t), cudaMemcpyDeviceToHost);
	cudaMemcpy((void*)&result.w2, (void*)dd2, sizeof(uint32_t), cudaMemcpyDeviceToHost);
	cudaMemcpy((void*)&result.w3, (void*)dd3, sizeof(uint32_t), cudaMemcpyDeviceToHost);
	cudaMemcpy((void*)&result.w4, (void*)dd4, sizeof(uint32_t), cudaMemcpyDeviceToHost);
	return result;
}
