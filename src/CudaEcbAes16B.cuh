#include <stdint.h>
#include <stdio.h>
#include "cuda_logging.cuh"

#define BLOCK_SIZE 128

#ifdef DEBUG && DEVEL
#define aes_add_16B_round_key(\
data_u32_w1, data_u32_w2, data_u32_w3, data_u32_w4, \
key_u32_w1, key_u32_w2, key_u32_w3, key_u32_w4\
)\
{\
	uint32_t data1_prev = (data_u32_w1);\
	uint32_t data2_prev = (data_u32_w1);\
	uint32_t data3_prev = (data_u32_w1);\
	uint32_t data4_prev = (data_u32_w1);\
	(data_u32_w1) = (data_u32_w1) ^ (key_u32_w1);\
	(data_u32_w2) = (data_u32_w2) ^ (key_u32_w2);\
	(data_u32_w3) = (data_u32_w3) ^ (key_u32_w3);\
	(data_u32_w4) = (data_u32_w4) ^ (key_u32_w4);\
	__LOG_TRACE__("0x%x = 0x%x ^ 0x%x",(data_u32_w1),data1_prev,(key_u32_w1));\
	__LOG_TRACE__("0x%x = 0x%x ^ 0x%x",(data_u32_w2),data2_prev,(key_u32_w2));\
	__LOG_TRACE__("0x%x = 0x%x ^ 0x%x",(data_u32_w3),data3_prev,(key_u32_w3));\
	__LOG_TRACE__("0x%x = 0x%x ^ 0x%x",(data_u32_w4),data4_prev,(key_u32_w4));\
}
#else
#define aes_add_16B_round_key(\
data_u32_w1, data_u32_w2, data_u32_w3, data_u32_w4, \
key_u32_w1, key_u32_w2, key_u32_w3, key_u32_w4\
)\
{\
	(data_u32_w1) = (data_u32_w1) ^ (key_u32_w1);\
	(data_u32_w2) = (data_u32_w2) ^ (key_u32_w2);\
	(data_u32_w3) = (data_u32_w3) ^ (key_u32_w3);\
	(data_u32_w4) = (data_u32_w4) ^ (key_u32_w4);\
}
#endif

//__forceinline__ __device__ void aes_add_16B_round_key
//	(
//		uint32_t data1,
//		uint32_t data2,
//		uint32_t data3,
//		uint32_t data4,
//		uint32_t key1,
//		uint32_t key2,
//		uint32_t key3,
//		uint32_t key4
//	)
//{
//#ifdef DEBUG
//	uint32_t data1_prev = data1;
//	uint32_t data2_prev = data2;
//	uint32_t data3_prev = data3;
//	uint32_t data4_prev = data4;
//#endif
//	data1 = data1 ^ key1;
//	data2 = data2 ^ key2;
//	data3 = data3 ^ key3;
//	data4 = data4 ^ key4;
//	__LOG_TRACE__("0x%x = 0x%x ^ 0x%x",data1,data1_prev,key1);
//	__LOG_TRACE__("0x%x = 0x%x ^ 0x%x",data2,data2_prev,key2);
//	__LOG_TRACE__("0x%x = 0x%x ^ 0x%x",data3,data3_prev,key3);
//	__LOG_TRACE__("0x%x = 0x%x ^ 0x%x",data4,data4_prev,key4);
//}

__device__ void cuda_ecb_aes_16b__add_round_key(unsigned char data[],
						int n_blocks,
						unsigned char expanded_key[]);
__device__ void cuda_ecb_aes_16b__sub_bytes(unsigned char data[],
						int n_blocks,
						unsigned char expanded_key[]);
__device__ void cuda_ecb_aes_16b__shift_rows(unsigned char data[],
						int n_blocks,
						unsigned char expanded_key[]);
__global__ void cuda_ecb_aes_16b_encrypt_kernel(unsigned char data[],
						int n_blocks,
						unsigned char expanded_key[],
						int rounds);
__global__ void cuda_ecb_aes_16b_decrypt_kernel(unsigned char data[],
						int n_blocks,
						unsigned char expanded_key[],
						int rounds);
void cuda_ecb_aes_16b_encrypt(int gridSize, int threadsPerBlock,
			      unsigned char data[], int n_blocks,
			      unsigned char expanded_key[], int rounds);
void cuda_ecb_aes_16b_decrypt(int gridSize, int threadsPerBlock,
			      unsigned char data[], int n_blocks,
			      unsigned char expanded_key[], int rounds);
