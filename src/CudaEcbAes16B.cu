#include "CudaEcbAes16B.cuh"

__global__ void cuda_ecb_aes_16b_encrypt_kernel(unsigned char data[], int n_blocks, uint32_t* expanded_key,  int rounds)
{


}


__global__ void cuda_ecb_aes_16b_decrypt_kernel(unsigned char data[], int n_blocks, uint32_t* expanded_key,  int rounds)
{


}

void cuda_ecb_aes_16b_encrypt(int gridSize, int threadsPerBlock, unsigned char data[], int n_blocks, uint32_t* expanded_key,  int rounds)
{
	cuda_ecb_aes_16b_encrypt_kernel<<<gridSize,threadsPerBlock>>>(data,n_blocks,expanded_key,rounds);
}


void cuda_ecb_aes_16b_decrypt(int gridSize, int threadsPerBlock, unsigned char data[], int n_blocks, uint32_t* expanded_key,  int rounds)
{
	cuda_ecb_aes_16b_decrypt_kernel<<<gridSize,threadsPerBlock>>>(data,n_blocks,expanded_key,rounds);
}
