#include "CudaEcbAes16BPtr.cuh"

__global__ void __cuda_ecb_aes128_16b_ptr_encrypt__(
		  int n,
		  uint32_t* d,
	  	  uint32_t* k,
	  	  uint32_t* T0,
	  	  uint32_t* T1,
	  	  uint32_t* T2,
	  	  uint32_t* T3
    )
{
	int bi = ((blockIdx.x * blockDim.x) + threadIdx.x); // block index
	if(bi < n) {
		int p = bi*4;
		uint32_t s0,s1,s2,s3,t0,t1,t2,t3;
		uint8_t* s0p = (uint8_t*) &s0;
		uint8_t* s1p = (uint8_t*) &s1;
		uint8_t* s2p = (uint8_t*) &s2;
		uint8_t* s3p = (uint8_t*) &s3;
		uint8_t* t0p = (uint8_t*) &t0;
		uint8_t* t1p = (uint8_t*) &t1;
		uint8_t* t2p = (uint8_t*) &t2;
		uint8_t* t3p = (uint8_t*) &t3;

		/*
		 * map byte array block to cipher state
		 * and add initial round key:
		 */
		__LOG_TRACE__("p %d: d[0] => 0x%04x",p,d[p]);
		__LOG_TRACE__("p %d: d[1] => 0x%04x",p,d[p+1]);
		__LOG_TRACE__("p %d: d[2] => 0x%04x",p,d[p+2]);
		__LOG_TRACE__("p %d: d[3] => 0x%04x",p,d[p+3]);
		__LOG_TRACE__("p %d: k[0] => 0x%04x",p,k[0]);
		__LOG_TRACE__("p %d: k[1] => 0x%04x",p,k[1]);
		__LOG_TRACE__("p %d: k[2] => 0x%04x",p,k[2]);
		__LOG_TRACE__("p %d: k[3] => 0x%04x",p,k[3]);
		s0 = d[p]   ^ k[0];
		s1 = d[p+1] ^ k[1];
		s2 = d[p+2] ^ k[2];
		s3 = d[p+3] ^ k[3];
		__LOG_TRACE__("p %d: s0 => 0x%04x",p,s0);
		__LOG_TRACE__("p %d: s1 => 0x%04x",p,s1);
		__LOG_TRACE__("p %d: s2 => 0x%04x",p,s2);
		__LOG_TRACE__("p %d: s3 => 0x%04x",p,s3);

		// 8 rounds - in each loop we do two rounds
		#pragma unroll
		for(int r2 = 1; r2 <= 4; r2++) {
			__LOG_TRACE__("p %d: s0p[0] => 0x%04x",p,s0p[0]);
			__LOG_TRACE__("p %d: s1p[1] => 0x%04x",p,s1p[1]);
			__LOG_TRACE__("p %d: s2p[2] => 0x%04x",p,s2p[2]);
			__LOG_TRACE__("p %d: s3p[3] => 0x%04x",p,(s3 >> 24));
			__LOG_TRACE__("p %d: T0[s0p[0]] => 0x%04x",p,T0[s0p[0]]);
			__LOG_TRACE__("p %d: T1[s1p[1]] => 0x%04x",p,T1[s1p[1]]);
			__LOG_TRACE__("p %d: T2[s2p[2]] => 0x%04x",p,T2[s2p[2]]);
			__LOG_TRACE__("p %d: T3[s3p[3]] => 0x%04x",p,T3[s3p[3]]);
			__LOG_TRACE__("p %d: k[%d] => 0x%04x",p,(r2*8)-4 , k[(r2*8)-4]);
			t0 = T0[s0p[0]] ^ T1[s1p[1]] ^ T2[s2p[2]] ^ T3[s3p[3]] ^ k[(r2*8)-4];
			t1 = T0[s1p[0]] ^ T1[s2p[1]] ^ T2[s3p[2]] ^ T3[s0p[3]] ^ k[(r2*8)-3];
			t2 = T0[s2p[0]] ^ T1[s3p[1]] ^ T2[s0p[2]] ^ T3[s1p[3]] ^ k[(r2*8)-2];
			t3 = T0[s3p[0]] ^ T1[s0p[1]] ^ T2[s1p[2]] ^ T3[s2p[3]] ^ k[(r2*8)-1];
			__LOG_TRACE__("p %d: t0 => 0x%04x",p,t0);
			__LOG_TRACE__("p %d: t1 => 0x%04x",p,t1);
			__LOG_TRACE__("p %d: t2 => 0x%04x",p,t2);
			__LOG_TRACE__("p %d: t3 => 0x%04x",p,t3);

			s0 = T0[t0p[0]] ^ T1[t1p[1]] ^ T2[t2p[2]] ^ T3[t3p[3]] ^ k[(r2*8)  ];
			s1 = T0[t1p[0]] ^ T1[t2p[1]] ^ T2[t3p[2]] ^ T3[t0p[3]] ^ k[(r2*8)+1];
			s2 = T0[t2p[0]] ^ T1[t3p[1]] ^ T2[t0p[2]] ^ T3[t1p[3]] ^ k[(r2*8)+2];
			s3 = T0[t3p[0]] ^ T1[t0p[1]] ^ T2[t1p[2]] ^ T3[t2p[3]] ^ k[(r2*8)+3];
			__LOG_TRACE__("p %d: s0 => 0x%04x",p,s0);
			__LOG_TRACE__("p %d: s1 => 0x%04x",p,s1);
			__LOG_TRACE__("p %d: s2 => 0x%04x",p,s2);
			__LOG_TRACE__("p %d: s3 => 0x%04x",p,s3);
		}

		t0 = T0[s0p[0]] ^ T1[s1p[1]] ^ T2[s2p[2]] ^ T3[s3p[3]] ^ k[36];
		t1 = T0[s1p[0]] ^ T1[s2p[1]] ^ T2[s3p[2]] ^ T3[s0p[3]] ^ k[37];
		t2 = T0[s2p[0]] ^ T1[s3p[1]] ^ T2[s0p[2]] ^ T3[s1p[3]] ^ k[38];
		t3 = T0[s3p[0]] ^ T1[s0p[1]] ^ T2[s1p[2]] ^ T3[s2p[3]] ^ k[39];
		__LOG_TRACE__("p %d: t0 => 0x%04x",p,t0);
		__LOG_TRACE__("p %d: t1 => 0x%04x",p,t1);
		__LOG_TRACE__("p %d: t2 => 0x%04x",p,t2);
		__LOG_TRACE__("p %d: t3 => 0x%04x",p,t3);

		// last round - save result
		s0 =
			(T2[t0p[0]] & 0x000000ff) ^
			(T3[t1p[1]] & 0x0000ff00) ^
			(T0[t2p[2]] & 0x00ff0000) ^
			(T1[t3p[3]] & 0xff000000) ^
			k[40];
		__LOG_TRACE__("p %d: s0 => 0x%04x",p,s0);
		d[p] = s0;
		s1 =
			(T2[t1p[0]] & 0x000000ff) ^
			(T3[t2p[1]] & 0x0000ff00) ^
			(T0[t3p[2]] & 0x00ff0000) ^
			(T1[t0p[3]] & 0xff000000) ^
			k[41];
		__LOG_TRACE__("p %d: s1 => 0x%04x",p,s1);
		d[p+1] = s1;
		s2 =
			(T2[t2p[0]] & 0x000000ff) ^
			(T3[t3p[1]] & 0x0000ff00) ^
			(T0[t0p[2]] & 0x00ff0000) ^
			(T1[t1p[3]] & 0xff000000) ^
			k[42];
		__LOG_TRACE__("p %d: s2 => 0x%04x",p,s2);
		d[p+2] = s2;
		s3 =
			(T2[t3p[0]] & 0x000000ff) ^
			(T3[t0p[1]] & 0x0000ff00) ^
			(T0[t1p[2]] & 0x00ff0000) ^
			(T2[t2p[3]] & 0xff000000) ^
			k[43];
		__LOG_TRACE__("p %d: s3 => 0x%04x",p,s3);
		d[p+3] = s3;
	}
}

__global__ void __cuda_ecb_aes192_16b_ptr_encrypt__(
		  int n,
		  uint32_t* d,
	  	  uint32_t* k,
	  	  uint32_t* T0,
	  	  uint32_t* T1,
	  	  uint32_t* T2,
	  	  uint32_t* T3
    )
{
	int bi = ((blockIdx.x * blockDim.x) + threadIdx.x); // block index
	if(bi < n) {
		int p = bi*4;
		uint32_t s0,s1,s2,s3,t0,t1,t2,t3;
		uint8_t* s0p = (uint8_t*) &s0;
		uint8_t* s1p = (uint8_t*) &s1;
		uint8_t* s2p = (uint8_t*) &s2;
		uint8_t* s3p = (uint8_t*) &s3;
		uint8_t* t0p = (uint8_t*) &t0;
		uint8_t* t1p = (uint8_t*) &t1;
		uint8_t* t2p = (uint8_t*) &t2;
		uint8_t* t3p = (uint8_t*) &t3;

		/*
		 * map byte array block to cipher state
		 * and add initial round key:
		 */
		__LOG_TRACE__("p %d: d[0] => 0x%04x",p,d[p]);
		__LOG_TRACE__("p %d: d[1] => 0x%04x",p,d[p+1]);
		__LOG_TRACE__("p %d: d[2] => 0x%04x",p,d[p+2]);
		__LOG_TRACE__("p %d: d[3] => 0x%04x",p,d[p+3]);
		__LOG_TRACE__("p %d: k[0] => 0x%04x",p,k[0]);
		__LOG_TRACE__("p %d: k[1] => 0x%04x",p,k[1]);
		__LOG_TRACE__("p %d: k[2] => 0x%04x",p,k[2]);
		__LOG_TRACE__("p %d: k[3] => 0x%04x",p,k[3]);
		s0 = d[p]   ^ k[0];
		s1 = d[p+1] ^ k[1];
		s2 = d[p+2] ^ k[2];
		s3 = d[p+3] ^ k[3];
		__LOG_TRACE__("p %d: s0 => 0x%04x",p,s0);
		__LOG_TRACE__("p %d: s1 => 0x%04x",p,s1);
		__LOG_TRACE__("p %d: s2 => 0x%04x",p,s2);
		__LOG_TRACE__("p %d: s3 => 0x%04x",p,s3);

		// 8 rounds - in each loop we do two rounds
		#pragma unroll
		for(int r2 = 1; r2 <= 5; r2++) {
			__LOG_TRACE__("p %d: s0p[0] => 0x%04x",p,s0p[0]);
			__LOG_TRACE__("p %d: s1p[1] => 0x%04x",p,s1p[1]);
			__LOG_TRACE__("p %d: s2p[2] => 0x%04x",p,s2p[2]);
			__LOG_TRACE__("p %d: s3p[3] => 0x%04x",p,(s3 >> 24));
			__LOG_TRACE__("p %d: T0[s0p[0]] => 0x%04x",p,T0[s0p[0]]);
			__LOG_TRACE__("p %d: T1[s1p[1]] => 0x%04x",p,T1[s1p[1]]);
			__LOG_TRACE__("p %d: T2[s2p[2]] => 0x%04x",p,T2[s2p[2]]);
			__LOG_TRACE__("p %d: T3[s3p[3]] => 0x%04x",p,T3[s3p[3]]);
			__LOG_TRACE__("p %d: k[%d] => 0x%04x",p,(r2*8)-4 , k[(r2*8)-4]);
			t0 = T0[s0p[0]] ^ T1[s1p[1]] ^ T2[s2p[2]] ^ T3[s3p[3]] ^ k[(r2*8)-4];
			t1 = T0[s1p[0]] ^ T1[s2p[1]] ^ T2[s3p[2]] ^ T3[s0p[3]] ^ k[(r2*8)-3];
			t2 = T0[s2p[0]] ^ T1[s3p[1]] ^ T2[s0p[2]] ^ T3[s1p[3]] ^ k[(r2*8)-2];
			t3 = T0[s3p[0]] ^ T1[s0p[1]] ^ T2[s1p[2]] ^ T3[s2p[3]] ^ k[(r2*8)-1];
			__LOG_TRACE__("p %d: t0 => 0x%04x",p,t0);
			__LOG_TRACE__("p %d: t1 => 0x%04x",p,t1);
			__LOG_TRACE__("p %d: t2 => 0x%04x",p,t2);
			__LOG_TRACE__("p %d: t3 => 0x%04x",p,t3);

			s0 = T0[t0p[0]] ^ T1[t1p[1]] ^ T2[t2p[2]] ^ T3[t3p[3]] ^ k[(r2*8)  ];
			s1 = T0[t1p[0]] ^ T1[t2p[1]] ^ T2[t3p[2]] ^ T3[t0p[3]] ^ k[(r2*8)+1];
			s2 = T0[t2p[0]] ^ T1[t3p[1]] ^ T2[t0p[2]] ^ T3[t1p[3]] ^ k[(r2*8)+2];
			s3 = T0[t3p[0]] ^ T1[t0p[1]] ^ T2[t1p[2]] ^ T3[t2p[3]] ^ k[(r2*8)+3];
			__LOG_TRACE__("p %d: s0 => 0x%04x",p,s0);
			__LOG_TRACE__("p %d: s1 => 0x%04x",p,s1);
			__LOG_TRACE__("p %d: s2 => 0x%04x",p,s2);
			__LOG_TRACE__("p %d: s3 => 0x%04x",p,s3);
		}

		t0 = T0[s0p[0]] ^ T1[s1p[1]] ^ T2[s2p[2]] ^ T3[s3p[3]] ^ k[44];
		t1 = T0[s1p[0]] ^ T1[s2p[1]] ^ T2[s3p[2]] ^ T3[s0p[3]] ^ k[45];
		t2 = T0[s2p[0]] ^ T1[s3p[1]] ^ T2[s0p[2]] ^ T3[s1p[3]] ^ k[46];
		t3 = T0[s3p[0]] ^ T1[s0p[1]] ^ T2[s1p[2]] ^ T3[s2p[3]] ^ k[47];
		__LOG_TRACE__("p %d: t0 => 0x%04x",p,t0);
		__LOG_TRACE__("p %d: t1 => 0x%04x",p,t1);
		__LOG_TRACE__("p %d: t2 => 0x%04x",p,t2);
		__LOG_TRACE__("p %d: t3 => 0x%04x",p,t3);

		// last round - save result
		s0 =
			(T2[t0p[0]] & 0x000000ff) ^
			(T3[t1p[1]] & 0x0000ff00) ^
			(T0[t2p[2]] & 0x00ff0000) ^
			(T1[t3p[3]] & 0xff000000) ^
			k[48];
		__LOG_TRACE__("p %d: s0 => 0x%04x",p,s0);
		d[p] = s0;
		s1 =
			(T2[t1p[0]] & 0x000000ff) ^
			(T3[t2p[1]] & 0x0000ff00) ^
			(T0[t3p[2]] & 0x00ff0000) ^
			(T1[t0p[3]] & 0xff000000) ^
			k[49];
		__LOG_TRACE__("p %d: s1 => 0x%04x",p,s1);
		d[p+1] = s1;
		s2 =
			(T2[t2p[0]] & 0x000000ff) ^
			(T3[t3p[1]] & 0x0000ff00) ^
			(T0[t0p[2]] & 0x00ff0000) ^
			(T1[t1p[3]] & 0xff000000) ^
			k[50];
		__LOG_TRACE__("p %d: s2 => 0x%04x",p,s2);
		d[p+2] = s2;
		s3 =
			(T2[t3p[0]] & 0x000000ff) ^
			(T3[t0p[1]] & 0x0000ff00) ^
			(T0[t1p[2]] & 0x00ff0000) ^
			(T2[t2p[3]] & 0xff000000) ^
			k[51];
		__LOG_TRACE__("p %d: s3 => 0x%04x",p,s3);
		d[p+3] = s3;
	}
}

__global__ void __cuda_ecb_aes256_16b_ptr_encrypt__(
		  int n,
		  uint32_t* d,
	  	  uint32_t* k,
	  	  uint32_t* T0,
	  	  uint32_t* T1,
	  	  uint32_t* T2,
	  	  uint32_t* T3
    )
{
	int bi = ((blockIdx.x * blockDim.x) + threadIdx.x); // block index
	if(bi < n) {
		int p = bi*4;
		uint32_t s0,s1,s2,s3,t0,t1,t2,t3;
		uint8_t* s0p = (uint8_t*) &s0;
		uint8_t* s1p = (uint8_t*) &s1;
		uint8_t* s2p = (uint8_t*) &s2;
		uint8_t* s3p = (uint8_t*) &s3;
		uint8_t* t0p = (uint8_t*) &t0;
		uint8_t* t1p = (uint8_t*) &t1;
		uint8_t* t2p = (uint8_t*) &t2;
		uint8_t* t3p = (uint8_t*) &t3;

		/*
		 * map byte array block to cipher state
		 * and add initial round key:
		 */
		__LOG_TRACE__("p %d: d[0] => 0x%04x",p,d[p]);
		__LOG_TRACE__("p %d: d[1] => 0x%04x",p,d[p+1]);
		__LOG_TRACE__("p %d: d[2] => 0x%04x",p,d[p+2]);
		__LOG_TRACE__("p %d: d[3] => 0x%04x",p,d[p+3]);
		__LOG_TRACE__("p %d: k[0] => 0x%04x",p,k[0]);
		__LOG_TRACE__("p %d: k[1] => 0x%04x",p,k[1]);
		__LOG_TRACE__("p %d: k[2] => 0x%04x",p,k[2]);
		__LOG_TRACE__("p %d: k[3] => 0x%04x",p,k[3]);
		s0 = d[p]   ^ k[0];
		s1 = d[p+1] ^ k[1];
		s2 = d[p+2] ^ k[2];
		s3 = d[p+3] ^ k[3];
		__LOG_TRACE__("p %d: s0 => 0x%04x",p,s0);
		__LOG_TRACE__("p %d: s1 => 0x%04x",p,s1);
		__LOG_TRACE__("p %d: s2 => 0x%04x",p,s2);
		__LOG_TRACE__("p %d: s3 => 0x%04x",p,s3);

		// 8 rounds - in each loop we do two rounds
		#pragma unroll
		for(int r2 = 1; r2 <= 6; r2++) {
			__LOG_TRACE__("p %d: s0p[0] => 0x%04x",p,s0p[0]);
			__LOG_TRACE__("p %d: s1p[1] => 0x%04x",p,s1p[1]);
			__LOG_TRACE__("p %d: s2p[2] => 0x%04x",p,s2p[2]);
			__LOG_TRACE__("p %d: s3p[3] => 0x%04x",p,(s3 >> 24));
			__LOG_TRACE__("p %d: T0[s0p[0]] => 0x%04x",p,T0[s0p[0]]);
			__LOG_TRACE__("p %d: T1[s1p[1]] => 0x%04x",p,T1[s1p[1]]);
			__LOG_TRACE__("p %d: T2[s2p[2]] => 0x%04x",p,T2[s2p[2]]);
			__LOG_TRACE__("p %d: T3[s3p[3]] => 0x%04x",p,T3[s3p[3]]);
			__LOG_TRACE__("p %d: k[%d] => 0x%04x",p,(r2*8)-4 , k[(r2*8)-4]);
			t0 = T0[s0p[0]] ^ T1[s1p[1]] ^ T2[s2p[2]] ^ T3[s3p[3]] ^ k[(r2*8)-4];
			t1 = T0[s1p[0]] ^ T1[s2p[1]] ^ T2[s3p[2]] ^ T3[s0p[3]] ^ k[(r2*8)-3];
			t2 = T0[s2p[0]] ^ T1[s3p[1]] ^ T2[s0p[2]] ^ T3[s1p[3]] ^ k[(r2*8)-2];
			t3 = T0[s3p[0]] ^ T1[s0p[1]] ^ T2[s1p[2]] ^ T3[s2p[3]] ^ k[(r2*8)-1];
			__LOG_TRACE__("p %d: t0 => 0x%04x",p,t0);
			__LOG_TRACE__("p %d: t1 => 0x%04x",p,t1);
			__LOG_TRACE__("p %d: t2 => 0x%04x",p,t2);
			__LOG_TRACE__("p %d: t3 => 0x%04x",p,t3);

			s0 = T0[t0p[0]] ^ T1[t1p[1]] ^ T2[t2p[2]] ^ T3[t3p[3]] ^ k[(r2*8)  ];
			s1 = T0[t1p[0]] ^ T1[t2p[1]] ^ T2[t3p[2]] ^ T3[t0p[3]] ^ k[(r2*8)+1];
			s2 = T0[t2p[0]] ^ T1[t3p[1]] ^ T2[t0p[2]] ^ T3[t1p[3]] ^ k[(r2*8)+2];
			s3 = T0[t3p[0]] ^ T1[t0p[1]] ^ T2[t1p[2]] ^ T3[t2p[3]] ^ k[(r2*8)+3];
			__LOG_TRACE__("p %d: s0 => 0x%04x",p,s0);
			__LOG_TRACE__("p %d: s1 => 0x%04x",p,s1);
			__LOG_TRACE__("p %d: s2 => 0x%04x",p,s2);
			__LOG_TRACE__("p %d: s3 => 0x%04x",p,s3);
		}

		t0 = T0[s0p[0]] ^ T1[s1p[1]] ^ T2[s2p[2]] ^ T3[s3p[3]] ^ k[52];
		t1 = T0[s1p[0]] ^ T1[s2p[1]] ^ T2[s3p[2]] ^ T3[s0p[3]] ^ k[53];
		t2 = T0[s2p[0]] ^ T1[s3p[1]] ^ T2[s0p[2]] ^ T3[s1p[3]] ^ k[54];
		t3 = T0[s3p[0]] ^ T1[s0p[1]] ^ T2[s1p[2]] ^ T3[s2p[3]] ^ k[55];
		__LOG_TRACE__("p %d: t0 => 0x%04x",p,t0);
		__LOG_TRACE__("p %d: t1 => 0x%04x",p,t1);
		__LOG_TRACE__("p %d: t2 => 0x%04x",p,t2);
		__LOG_TRACE__("p %d: t3 => 0x%04x",p,t3);

		// last round - save result
		s0 =
			(T2[t0p[0]] & 0x000000ff) ^
			(T3[t1p[1]] & 0x0000ff00) ^
			(T0[t2p[2]] & 0x00ff0000) ^
			(T1[t3p[3]] & 0xff000000) ^
			k[56];
		__LOG_TRACE__("p %d: s0 => 0x%04x",p,s0);
		d[p] = s0;
		s1 =
			(T2[t1p[0]] & 0x000000ff) ^
			(T3[t2p[1]] & 0x0000ff00) ^
			(T0[t3p[2]] & 0x00ff0000) ^
			(T1[t0p[3]] & 0xff000000) ^
			k[57];
		__LOG_TRACE__("p %d: s1 => 0x%04x",p,s1);
		d[p+1] = s1;
		s2 =
			(T2[t2p[0]] & 0x000000ff) ^
			(T3[t3p[1]] & 0x0000ff00) ^
			(T0[t0p[2]] & 0x00ff0000) ^
			(T1[t1p[3]] & 0xff000000) ^
			k[58];
		__LOG_TRACE__("p %d: s2 => 0x%04x",p,s2);
		d[p+2] = s2;
		s3 =
			(T2[t3p[0]] & 0x000000ff) ^
			(T3[t0p[1]] & 0x0000ff00) ^
			(T0[t1p[2]] & 0x00ff0000) ^
			(T2[t2p[3]] & 0xff000000) ^
			k[59];
		__LOG_TRACE__("p %d: s3 => 0x%04x",p,s3);
		d[p+3] = s3;
	}
}

__global__ void __cuda_ecb_aes128_16b_ptr_decrypt__(
		  int n,
		  uint32_t* d,
	  	  uint32_t* k,
	  	  uint32_t* T0,
	  	  uint32_t* T1,
	  	  uint32_t* T2,
	  	  uint32_t* T3,
	  	  uint8_t* T4
    )
{
	int bi = ((blockIdx.x * blockDim.x) + threadIdx.x); // block index
	if(bi < n) {
		int p = bi*4;
		uint32_t s0,s1,s2,s3,t0,t1,t2,t3;
		uint8_t* s0p = (uint8_t*) &s0;
		uint8_t* s1p = (uint8_t*) &s1;
		uint8_t* s2p = (uint8_t*) &s2;
		uint8_t* s3p = (uint8_t*) &s3;
		uint8_t* t0p = (uint8_t*) &t0;
		uint8_t* t1p = (uint8_t*) &t1;
		uint8_t* t2p = (uint8_t*) &t2;
		uint8_t* t3p = (uint8_t*) &t3;

		/*
		 * map byte array block to cipher state
		 * and add initial round key:
		 */
		__LOG_TRACE__("p %d: d[0] => 0x%04x",p,d[p]);
		__LOG_TRACE__("p %d: d[1] => 0x%04x",p,d[p+1]);
		__LOG_TRACE__("p %d: d[2] => 0x%04x",p,d[p+2]);
		__LOG_TRACE__("p %d: d[3] => 0x%04x",p,d[p+3]);
		__LOG_TRACE__("p %d: k[0] => 0x%04x",p,k[0]);
		__LOG_TRACE__("p %d: k[1] => 0x%04x",p,k[1]);
		__LOG_TRACE__("p %d: k[2] => 0x%04x",p,k[2]);
		__LOG_TRACE__("p %d: k[3] => 0x%04x",p,k[3]);
		s0 = d[p]   ^ k[0];
		s1 = d[p+1] ^ k[1];
		s2 = d[p+2] ^ k[2];
		s3 = d[p+3] ^ k[3];
		__LOG_TRACE__("p %d: s0 => 0x%04x",p,s0);
		__LOG_TRACE__("p %d: s1 => 0x%04x",p,s1);
		__LOG_TRACE__("p %d: s2 => 0x%04x",p,s2);
		__LOG_TRACE__("p %d: s3 => 0x%04x",p,s3);

		// 8 rounds - in each loop we do two rounds
		#pragma unroll
		for(int r2 = 1; r2 <= 4; r2++) {
			__LOG_TRACE__("p %d: s0p[0] => 0x%04x",p,s0p[0]);
			__LOG_TRACE__("p %d: s1p[1] => 0x%04x",p,s1p[1]);
			__LOG_TRACE__("p %d: s2p[2] => 0x%04x",p,s2p[2]);
			__LOG_TRACE__("p %d: s3p[3] => 0x%04x",p,(s3 >> 24));
			__LOG_TRACE__("p %d: T0[s0p[0]] => 0x%04x",p,T0[s0p[0]]);
			__LOG_TRACE__("p %d: T1[s1p[1]] => 0x%04x",p,T1[s1p[1]]);
			__LOG_TRACE__("p %d: T2[s2p[2]] => 0x%04x",p,T2[s2p[2]]);
			__LOG_TRACE__("p %d: T3[s3p[3]] => 0x%04x",p,T3[s3p[3]]);
			__LOG_TRACE__("p %d: k[%d] => 0x%04x",p,(r2*8)-4 , k[(r2*8)-4]);
			t0 = T0[s0p[0]] ^ T1[s3p[1]] ^ T2[s2p[2]] ^ T3[s1p[3]] ^ k[(r2*8)-4];
			t1 = T0[s1p[0]] ^ T1[s0p[1]] ^ T2[s3p[2]] ^ T3[s2p[3]] ^ k[(r2*8)-3];
			t2 = T0[s2p[0]] ^ T1[s1p[1]] ^ T2[s0p[2]] ^ T3[s3p[3]] ^ k[(r2*8)-2];
			t3 = T0[s3p[0]] ^ T1[s2p[1]] ^ T2[s1p[2]] ^ T3[s0p[3]] ^ k[(r2*8)-1];
			__LOG_TRACE__("p %d: t0 => 0x%04x",p,t0);
			__LOG_TRACE__("p %d: t1 => 0x%04x",p,t1);
			__LOG_TRACE__("p %d: t2 => 0x%04x",p,t2);
			__LOG_TRACE__("p %d: t3 => 0x%04x",p,t3);

			s0 = T0[t0p[0]] ^ T1[t3p[1]] ^ T2[t2p[2]] ^ T3[t1p[3]] ^ k[(r2*8)  ];
			s1 = T0[t1p[0]] ^ T1[t0p[1]] ^ T2[t3p[2]] ^ T3[t2p[3]] ^ k[(r2*8)+1];
			s2 = T0[t2p[0]] ^ T1[t1p[1]] ^ T2[t0p[2]] ^ T3[t3p[3]] ^ k[(r2*8)+2];
			s3 = T0[t3p[0]] ^ T1[t2p[1]] ^ T2[t1p[2]] ^ T3[t0p[3]] ^ k[(r2*8)+3];
			__LOG_TRACE__("p %d: s0 => 0x%04x",p,s0);
			__LOG_TRACE__("p %d: s1 => 0x%04x",p,s1);
			__LOG_TRACE__("p %d: s2 => 0x%04x",p,s2);
			__LOG_TRACE__("p %d: s3 => 0x%04x",p,s3);
		}

		t0 = T0[s0p[0]] ^ T1[s3p[1]] ^ T2[s2p[2]] ^ T3[s1p[3]] ^ k[36];
		t1 = T0[s1p[0]] ^ T1[s0p[1]] ^ T2[s3p[2]] ^ T3[s2p[3]] ^ k[37];
		t2 = T0[s2p[0]] ^ T1[s1p[1]] ^ T2[s0p[2]] ^ T3[s3p[3]] ^ k[38];
		t3 = T0[s3p[0]] ^ T1[s2p[1]] ^ T2[s1p[2]] ^ T3[s0p[3]] ^ k[39];
		__LOG_TRACE__("p %d: t0 => 0x%04x",p,t0);
		__LOG_TRACE__("p %d: t1 => 0x%04x",p,t1);
		__LOG_TRACE__("p %d: t2 => 0x%04x",p,t2);
		__LOG_TRACE__("p %d: t3 => 0x%04x",p,t3);

		// last round - save result
		s0 =
			((uint32_t)T4[t0p[0]]      ) ^
			((uint32_t)T4[t3p[1]] <<  8) ^
			((uint32_t)T4[t2p[2]] << 16) ^
			((uint32_t)T4[t1p[3]] << 24) ^
			k[40];
		__LOG_TRACE__("p %d: s0 => 0x%04x",p,s0);
		d[p] = s0;
		s1 =
			((uint32_t)T4[t1p[0]]      ) ^
			((uint32_t)T4[t0p[1]] <<  8) ^
			((uint32_t)T4[t3p[2]] << 16) ^
			((uint32_t)T4[t2p[3]] << 24) ^
			k[41];
		__LOG_TRACE__("p %d: s1 => 0x%04x",p,s1);
		d[p+1] = s1;
		s2 =
			((uint32_t)T4[t2p[0]]      ) ^
			((uint32_t)T4[t1p[1]] <<  8) ^
			((uint32_t)T4[t0p[2]] << 16) ^
			((uint32_t)T4[t3p[3]] << 24) ^
			k[42];
		__LOG_TRACE__("p %d: s2 => 0x%04x",p,s2);
		d[p+2] = s2;
		s3 =
			((uint32_t)T4[t3p[0]]      ) ^
			((uint32_t)T4[t2p[1]] <<  8) ^
			((uint32_t)T4[t1p[2]] << 16) ^
			((uint32_t)T4[t0p[3]] << 24) ^
			k[43];
		__LOG_TRACE__("p %d: s3 => 0x%04x",p,s3);
		d[p+3] = s3;
	}
}

__global__ void __cuda_ecb_aes192_16b_ptr_decrypt__(
		  int n,
		  uint32_t* d,
	  	  uint32_t* k,
	  	  uint32_t* T0,
	  	  uint32_t* T1,
	  	  uint32_t* T2,
	  	  uint32_t* T3,
	  	  uint8_t* T4
    )
{
	int bi = ((blockIdx.x * blockDim.x) + threadIdx.x); // block index
	if(bi < n) {
		int p = bi*4;
		uint32_t s0,s1,s2,s3,t0,t1,t2,t3;
		uint8_t* s0p = (uint8_t*) &s0;
		uint8_t* s1p = (uint8_t*) &s1;
		uint8_t* s2p = (uint8_t*) &s2;
		uint8_t* s3p = (uint8_t*) &s3;
		uint8_t* t0p = (uint8_t*) &t0;
		uint8_t* t1p = (uint8_t*) &t1;
		uint8_t* t2p = (uint8_t*) &t2;
		uint8_t* t3p = (uint8_t*) &t3;

		/*
		 * map byte array block to cipher state
		 * and add initial round key:
		 */
		__LOG_TRACE__("p %d: d[0] => 0x%04x",p,d[p]);
		__LOG_TRACE__("p %d: d[1] => 0x%04x",p,d[p+1]);
		__LOG_TRACE__("p %d: d[2] => 0x%04x",p,d[p+2]);
		__LOG_TRACE__("p %d: d[3] => 0x%04x",p,d[p+3]);
		__LOG_TRACE__("p %d: k[0] => 0x%04x",p,k[0]);
		__LOG_TRACE__("p %d: k[1] => 0x%04x",p,k[1]);
		__LOG_TRACE__("p %d: k[2] => 0x%04x",p,k[2]);
		__LOG_TRACE__("p %d: k[3] => 0x%04x",p,k[3]);
		s0 = d[p]   ^ k[0];
		s1 = d[p+1] ^ k[1];
		s2 = d[p+2] ^ k[2];
		s3 = d[p+3] ^ k[3];
		__LOG_TRACE__("p %d: s0 => 0x%04x",p,s0);
		__LOG_TRACE__("p %d: s1 => 0x%04x",p,s1);
		__LOG_TRACE__("p %d: s2 => 0x%04x",p,s2);
		__LOG_TRACE__("p %d: s3 => 0x%04x",p,s3);

		// 8 rounds - in each loop we do two rounds
		#pragma unroll
		for(int r2 = 1; r2 <= 5; r2++) {
			__LOG_TRACE__("p %d: s0p[0] => 0x%04x",p,s0p[0]);
			__LOG_TRACE__("p %d: s1p[1] => 0x%04x",p,s1p[1]);
			__LOG_TRACE__("p %d: s2p[2] => 0x%04x",p,s2p[2]);
			__LOG_TRACE__("p %d: s3p[3] => 0x%04x",p,(s3 >> 24));
			__LOG_TRACE__("p %d: T0[s0p[0]] => 0x%04x",p,T0[s0p[0]]);
			__LOG_TRACE__("p %d: T1[s1p[1]] => 0x%04x",p,T1[s1p[1]]);
			__LOG_TRACE__("p %d: T2[s2p[2]] => 0x%04x",p,T2[s2p[2]]);
			__LOG_TRACE__("p %d: T3[s3p[3]] => 0x%04x",p,T3[s3p[3]]);
			__LOG_TRACE__("p %d: k[%d] => 0x%04x",p,(r2*8)-4 , k[(r2*8)-4]);
			t0 = T0[s0p[0]] ^ T1[s3p[1]] ^ T2[s2p[2]] ^ T3[s1p[3]] ^ k[(r2*8)-4];
			t1 = T0[s1p[0]] ^ T1[s0p[1]] ^ T2[s3p[2]] ^ T3[s2p[3]] ^ k[(r2*8)-3];
			t2 = T0[s2p[0]] ^ T1[s1p[1]] ^ T2[s0p[2]] ^ T3[s3p[3]] ^ k[(r2*8)-2];
			t3 = T0[s3p[0]] ^ T1[s2p[1]] ^ T2[s1p[2]] ^ T3[s0p[3]] ^ k[(r2*8)-1];
			__LOG_TRACE__("p %d: t0 => 0x%04x",p,t0);
			__LOG_TRACE__("p %d: t1 => 0x%04x",p,t1);
			__LOG_TRACE__("p %d: t2 => 0x%04x",p,t2);
			__LOG_TRACE__("p %d: t3 => 0x%04x",p,t3);

			s0 = T0[t0p[0]] ^ T1[t3p[1]] ^ T2[t2p[2]] ^ T3[t1p[3]] ^ k[(r2*8)  ];
			s1 = T0[t1p[0]] ^ T1[t0p[1]] ^ T2[t3p[2]] ^ T3[t2p[3]] ^ k[(r2*8)+1];
			s2 = T0[t2p[0]] ^ T1[t1p[1]] ^ T2[t0p[2]] ^ T3[t3p[3]] ^ k[(r2*8)+2];
			s3 = T0[t3p[0]] ^ T1[t2p[1]] ^ T2[t1p[2]] ^ T3[t0p[3]] ^ k[(r2*8)+3];
			__LOG_TRACE__("p %d: s0 => 0x%04x",p,s0);
			__LOG_TRACE__("p %d: s1 => 0x%04x",p,s1);
			__LOG_TRACE__("p %d: s2 => 0x%04x",p,s2);
			__LOG_TRACE__("p %d: s3 => 0x%04x",p,s3);
		}

		t0 = T0[s0p[0]] ^ T1[s3p[1]] ^ T2[s2p[2]] ^ T3[s1p[3]] ^ k[44];
		t1 = T0[s1p[0]] ^ T1[s0p[1]] ^ T2[s3p[2]] ^ T3[s2p[3]] ^ k[45];
		t2 = T0[s2p[0]] ^ T1[s1p[1]] ^ T2[s0p[2]] ^ T3[s3p[3]] ^ k[46];
		t3 = T0[s3p[0]] ^ T1[s2p[1]] ^ T2[s1p[2]] ^ T3[s0p[3]] ^ k[47];
		__LOG_TRACE__("p %d: t0 => 0x%04x",p,t0);
		__LOG_TRACE__("p %d: t1 => 0x%04x",p,t1);
		__LOG_TRACE__("p %d: t2 => 0x%04x",p,t2);
		__LOG_TRACE__("p %d: t3 => 0x%04x",p,t3);

		// last round - save result
		s0 =
			((uint32_t)T4[t0p[0]]      ) ^
			((uint32_t)T4[t3p[1]] <<  8) ^
			((uint32_t)T4[t2p[2]] << 16) ^
			((uint32_t)T4[t1p[3]] << 24) ^
			k[48];
		__LOG_TRACE__("p %d: s0 => 0x%04x",p,s0);
		d[p] = s0;
		s1 =
			((uint32_t)T4[t1p[0]]      ) ^
			((uint32_t)T4[t0p[1]] <<  8) ^
			((uint32_t)T4[t3p[2]] << 16) ^
			((uint32_t)T4[t2p[3]] << 24) ^
			k[49];
		__LOG_TRACE__("p %d: s1 => 0x%04x",p,s1);
		d[p+1] = s1;
		s2 =
			((uint32_t)T4[t2p[0]]      ) ^
			((uint32_t)T4[t1p[1]] <<  8) ^
			((uint32_t)T4[t0p[2]] << 16) ^
			((uint32_t)T4[t3p[3]] << 24) ^
			k[50];
		__LOG_TRACE__("p %d: s2 => 0x%04x",p,s2);
		d[p+2] = s2;
		s3 =
			((uint32_t)T4[t3p[0]]      ) ^
			((uint32_t)T4[t2p[1]] <<  8) ^
			((uint32_t)T4[t1p[2]] << 16) ^
			((uint32_t)T4[t0p[3]] << 24) ^
			k[51];
		__LOG_TRACE__("p %d: s3 => 0x%04x",p,s3);
		d[p+3] = s3;
	}
}

__global__ void __cuda_ecb_aes256_16b_ptr_decrypt__(
		  int n,
		  uint32_t* d,
	  	  uint32_t* k,
	  	  uint32_t* T0,
	  	  uint32_t* T1,
	  	  uint32_t* T2,
	  	  uint32_t* T3,
	  	  uint8_t* T4
    )
{
	int bi = ((blockIdx.x * blockDim.x) + threadIdx.x); // block index
	if(bi < n) {
		int p = bi*4;
		uint32_t s0,s1,s2,s3,t0,t1,t2,t3;
		uint8_t* s0p = (uint8_t*) &s0;
		uint8_t* s1p = (uint8_t*) &s1;
		uint8_t* s2p = (uint8_t*) &s2;
		uint8_t* s3p = (uint8_t*) &s3;
		uint8_t* t0p = (uint8_t*) &t0;
		uint8_t* t1p = (uint8_t*) &t1;
		uint8_t* t2p = (uint8_t*) &t2;
		uint8_t* t3p = (uint8_t*) &t3;

		/*
		 * map byte array block to cipher state
		 * and add initial round key:
		 */
		__LOG_TRACE__("p %d: d[0] => 0x%04x",p,d[p]);
		__LOG_TRACE__("p %d: d[1] => 0x%04x",p,d[p+1]);
		__LOG_TRACE__("p %d: d[2] => 0x%04x",p,d[p+2]);
		__LOG_TRACE__("p %d: d[3] => 0x%04x",p,d[p+3]);
		__LOG_TRACE__("p %d: k[0] => 0x%04x",p,k[0]);
		__LOG_TRACE__("p %d: k[1] => 0x%04x",p,k[1]);
		__LOG_TRACE__("p %d: k[2] => 0x%04x",p,k[2]);
		__LOG_TRACE__("p %d: k[3] => 0x%04x",p,k[3]);
		s0 = d[p]   ^ k[0];
		s1 = d[p+1] ^ k[1];
		s2 = d[p+2] ^ k[2];
		s3 = d[p+3] ^ k[3];
		__LOG_TRACE__("p %d: s0 => 0x%04x",p,s0);
		__LOG_TRACE__("p %d: s1 => 0x%04x",p,s1);
		__LOG_TRACE__("p %d: s2 => 0x%04x",p,s2);
		__LOG_TRACE__("p %d: s3 => 0x%04x",p,s3);

		// 8 rounds - in each loop we do two rounds
		#pragma unroll
		for(int r2 = 1; r2 <= 6; r2++) {
			__LOG_TRACE__("p %d: s0p[0] => 0x%04x",p,s0p[0]);
			__LOG_TRACE__("p %d: s1p[1] => 0x%04x",p,s1p[1]);
			__LOG_TRACE__("p %d: s2p[2] => 0x%04x",p,s2p[2]);
			__LOG_TRACE__("p %d: s3p[3] => 0x%04x",p,(s3 >> 24));
			__LOG_TRACE__("p %d: T0[s0p[0]] => 0x%04x",p,T0[s0p[0]]);
			__LOG_TRACE__("p %d: T1[s1p[1]] => 0x%04x",p,T1[s1p[1]]);
			__LOG_TRACE__("p %d: T2[s2p[2]] => 0x%04x",p,T2[s2p[2]]);
			__LOG_TRACE__("p %d: T3[s3p[3]] => 0x%04x",p,T3[s3p[3]]);
			__LOG_TRACE__("p %d: k[%d] => 0x%04x",p,(r2*8)-4 , k[(r2*8)-4]);
			t0 = T0[s0p[0]] ^ T1[s3p[1]] ^ T2[s2p[2]] ^ T3[s1p[3]] ^ k[(r2*8)-4];
			t1 = T0[s1p[0]] ^ T1[s0p[1]] ^ T2[s3p[2]] ^ T3[s2p[3]] ^ k[(r2*8)-3];
			t2 = T0[s2p[0]] ^ T1[s1p[1]] ^ T2[s0p[2]] ^ T3[s3p[3]] ^ k[(r2*8)-2];
			t3 = T0[s3p[0]] ^ T1[s2p[1]] ^ T2[s1p[2]] ^ T3[s0p[3]] ^ k[(r2*8)-1];
			__LOG_TRACE__("p %d: t0 => 0x%04x",p,t0);
			__LOG_TRACE__("p %d: t1 => 0x%04x",p,t1);
			__LOG_TRACE__("p %d: t2 => 0x%04x",p,t2);
			__LOG_TRACE__("p %d: t3 => 0x%04x",p,t3);

			s0 = T0[t0p[0]] ^ T1[t3p[1]] ^ T2[t2p[2]] ^ T3[t1p[3]] ^ k[(r2*8)  ];
			s1 = T0[t1p[0]] ^ T1[t0p[1]] ^ T2[t3p[2]] ^ T3[t2p[3]] ^ k[(r2*8)+1];
			s2 = T0[t2p[0]] ^ T1[t1p[1]] ^ T2[t0p[2]] ^ T3[t3p[3]] ^ k[(r2*8)+2];
			s3 = T0[t3p[0]] ^ T1[t2p[1]] ^ T2[t1p[2]] ^ T3[t0p[3]] ^ k[(r2*8)+3];
			__LOG_TRACE__("p %d: s0 => 0x%04x",p,s0);
			__LOG_TRACE__("p %d: s1 => 0x%04x",p,s1);
			__LOG_TRACE__("p %d: s2 => 0x%04x",p,s2);
			__LOG_TRACE__("p %d: s3 => 0x%04x",p,s3);
		}

		t0 = T0[s0p[0]] ^ T1[s3p[1]] ^ T2[s2p[2]] ^ T3[s1p[3]] ^ k[52];
		t1 = T0[s1p[0]] ^ T1[s0p[1]] ^ T2[s3p[2]] ^ T3[s2p[3]] ^ k[53];
		t2 = T0[s2p[0]] ^ T1[s1p[1]] ^ T2[s0p[2]] ^ T3[s3p[3]] ^ k[54];
		t3 = T0[s3p[0]] ^ T1[s2p[1]] ^ T2[s1p[2]] ^ T3[s0p[3]] ^ k[55];
		__LOG_TRACE__("p %d: t0 => 0x%04x",p,t0);
		__LOG_TRACE__("p %d: t1 => 0x%04x",p,t1);
		__LOG_TRACE__("p %d: t2 => 0x%04x",p,t2);
		__LOG_TRACE__("p %d: t3 => 0x%04x",p,t3);

		// last round - save result
		s0 =
			((uint32_t)T4[t0p[0]]      ) ^
			((uint32_t)T4[t3p[1]] <<  8) ^
			((uint32_t)T4[t2p[2]] << 16) ^
			((uint32_t)T4[t1p[3]] << 24) ^
			k[56];
		__LOG_TRACE__("p %d: s0 => 0x%04x",p,s0);
		d[p] = s0;
		s1 =
			((uint32_t)T4[t1p[0]]      ) ^
			((uint32_t)T4[t0p[1]] <<  8) ^
			((uint32_t)T4[t3p[2]] << 16) ^
			((uint32_t)T4[t2p[3]] << 24) ^
			k[57];
		__LOG_TRACE__("p %d: s1 => 0x%04x",p,s1);
		d[p+1] = s1;
		s2 =
			((uint32_t)T4[t2p[0]]      ) ^
			((uint32_t)T4[t1p[1]] <<  8) ^
			((uint32_t)T4[t0p[2]] << 16) ^
			((uint32_t)T4[t3p[3]] << 24) ^
			k[58];
		__LOG_TRACE__("p %d: s2 => 0x%04x",p,s2);
		d[p+2] = s2;
		s3 =
			((uint32_t)T4[t3p[0]]      ) ^
			((uint32_t)T4[t2p[1]] <<  8) ^
			((uint32_t)T4[t1p[2]] << 16) ^
			((uint32_t)T4[t0p[3]] << 24) ^
			k[59];
		__LOG_TRACE__("p %d: s3 => 0x%04x",p,s3);
		d[p+3] = s3;
	}
}

void cuda_ecb_aes128_16b_ptr_encrypt(
		  	  int gridSize,
		  	  int threadsPerBlock,
		  	  int n_blocks,
		  	  unsigned char data[],
		  	  uint32_t* expanded_key,
		  	  uint32_t* deviceTe0,
		  	  uint32_t* deviceTe1,
		  	  uint32_t* deviceTe2,
		  	  uint32_t* deviceTe3
	      )
{
	__cuda_ecb_aes128_16b_ptr_encrypt__<<<gridSize,threadsPerBlock>>>(
			n_blocks,
			(uint32_t*)data,
			expanded_key,
	   		deviceTe0,
	   		deviceTe1,
	   		deviceTe2,
	   		deviceTe3
	);
}

void cuda_ecb_aes192_16b_ptr_encrypt(
		  	  int gridSize,
		  	  int threadsPerBlock,
		  	  int n_blocks,
		  	  unsigned char data[],
		  	  uint32_t* expanded_key,
		  	  uint32_t* deviceTe0,
		  	  uint32_t* deviceTe1,
		  	  uint32_t* deviceTe2,
		  	  uint32_t* deviceTe3
	      )
{
	__cuda_ecb_aes192_16b_ptr_encrypt__<<<gridSize,threadsPerBlock>>>(
			n_blocks,
			(uint32_t*)data,
			expanded_key,
	   		deviceTe0,
	   		deviceTe1,
	   		deviceTe2,
	   		deviceTe3
	);
}

void cuda_ecb_aes256_16b_ptr_encrypt(
		  	  int gridSize,
		  	  int threadsPerBlock,
		  	  int n_blocks,
		  	  unsigned char data[],
		  	  uint32_t* expanded_key,
		  	  uint32_t* deviceTe0,
		  	  uint32_t* deviceTe1,
		  	  uint32_t* deviceTe2,
		  	  uint32_t* deviceTe3
	      )
{
	__cuda_ecb_aes256_16b_ptr_encrypt__<<<gridSize,threadsPerBlock>>>(
			n_blocks,
			(uint32_t*)data,
			expanded_key,
	   		deviceTe0,
	   		deviceTe1,
	   		deviceTe2,
	   		deviceTe3
	);
}

void cuda_ecb_aes128_16b_ptr_decrypt(
		  	  int gridSize,
		  	  int threadsPerBlock,
		  	  int n_blocks,
		  	  unsigned char data[],
		  	  uint32_t* expanded_key,
		  	  uint32_t* deviceTd0,
		  	  uint32_t* deviceTd1,
		  	  uint32_t* deviceTd2,
		  	  uint32_t* deviceTd3,
		  	  uint8_t* deviceTd4
	      )
{
	__cuda_ecb_aes128_16b_ptr_decrypt__<<<gridSize,threadsPerBlock>>>(
			n_blocks,
			(uint32_t*)data,
			expanded_key,
	   		deviceTd0,
	   		deviceTd1,
	   		deviceTd2,
	   		deviceTd3,
	   		deviceTd4
	);
}

void cuda_ecb_aes192_16b_ptr_decrypt(
		  	  int gridSize,
		  	  int threadsPerBlock,
		  	  int n_blocks,
		  	  unsigned char data[],
		  	  uint32_t* expanded_key,
		  	  uint32_t* deviceTd0,
		  	  uint32_t* deviceTd1,
		  	  uint32_t* deviceTd2,
		  	  uint32_t* deviceTd3,
		  	  uint8_t* deviceTd4
	      )
{
	__cuda_ecb_aes192_16b_ptr_decrypt__<<<gridSize,threadsPerBlock>>>(
			n_blocks,
			(uint32_t*)data,
			expanded_key,
	   		deviceTd0,
	   		deviceTd1,
	   		deviceTd2,
	   		deviceTd3,
	   		deviceTd4
	);
}

void cuda_ecb_aes256_16b_ptr_decrypt(
		  	  int gridSize,
		  	  int threadsPerBlock,
		  	  int n_blocks,
		  	  unsigned char data[],
		  	  uint32_t* expanded_key,
		  	  uint32_t* deviceTd0,
		  	  uint32_t* deviceTd1,
		  	  uint32_t* deviceTd2,
		  	  uint32_t* deviceTd3,
		  	  uint8_t* deviceTd4
	      )
{
	__cuda_ecb_aes256_16b_ptr_decrypt__<<<gridSize,threadsPerBlock>>>(
			n_blocks,
			(uint32_t*)data,
			expanded_key,
	   		deviceTd0,
	   		deviceTd1,
	   		deviceTd2,
	   		deviceTd3,
	   		deviceTd4
	);
}
