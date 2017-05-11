/*
 *  Copyright (C) 2017 Jesus Martin Berlanga. All Rights Reserved.
 *
 *  This file is part of Paracrypt.
 *
 *  Paracrypt is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  Paracrypt is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Paracrypt.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#include "CudaEcbAes16B.cuh"
#include "cuda_logging.cuh"

__global__ void __cuda_ecb_aes_16b_encrypt__(
		  int n,
		  uint32_t* d,
	  	  uint32_t* k,
	  	  int key_bits,
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
		int key_index_sum = 0;

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
			__LOG_TRACE__("p %d: (s0      ) & 0xff => 0x%04x",p,(s0      ) & 0xff);
			__LOG_TRACE__("p %d: (s1 >>  8) & 0xff => 0x%04x",p,(s1 >>  8) & 0xff);
			__LOG_TRACE__("p %d: (s2 >> 16) & 0xff => 0x%04x",p,(s2 >> 16) & 0xff);
			__LOG_TRACE__("p %d: (s3 >> 24)        => 0x%04x",p,(s3 >> 24));
			__LOG_TRACE__("p %d: T0[(s0      ) & 0xff] => 0x%04x",p,T0[(s0      ) & 0xff]);
			__LOG_TRACE__("p %d: T1[(s1 >>  8) & 0xff] => 0x%04x",p,T1[(s1 >>  8) & 0xff]);
			__LOG_TRACE__("p %d: T2[(s2 >> 16) & 0xff] => 0x%04x",p,T2[(s2 >> 16) & 0xff]);
			__LOG_TRACE__("p %d: T3[(s3 >> 24)       ] => 0x%04x",p,T3[(s3 >> 24)       ]);
			__LOG_TRACE__("p %d: k[%d] => 0x%04x",p,(r2*8)-4 , k[(r2*8)-4]);
			t0 =
				T0[(s0      ) & 0xff] ^
				T1[(s1 >>  8) & 0xff] ^
				T2[(s2 >> 16) & 0xff] ^
				T3[(s3 >> 24)       ] ^
				k[(r2*8)-4];
			t1 =
				T0[(s1      ) & 0xff] ^
				T1[(s2 >>  8) & 0xff] ^
				T2[(s3 >> 16) & 0xff] ^
				T3[(s0 >> 24)       ] ^
				k[(r2*8)-3];
			t2 =
				T0[(s2      ) & 0xff] ^
				T1[(s3 >>  8) & 0xff] ^
				T2[(s0 >> 16) & 0xff] ^
				T3[(s1 >> 24)       ] ^
				k[(r2*8)-2];
			t3 =
				T0[(s3      ) & 0xff] ^
				T1[(s0 >>  8) & 0xff] ^
				T2[(s1 >> 16) & 0xff] ^
				T3[(s2 >> 24)       ] ^
				k[(r2*8)-1];
			__LOG_TRACE__("p %d: t0 => 0x%04x",p,t0);
			__LOG_TRACE__("p %d: t1 => 0x%04x",p,t1);
			__LOG_TRACE__("p %d: t2 => 0x%04x",p,t2);
			__LOG_TRACE__("p %d: t3 => 0x%04x",p,t3);

			s0 =
				T0[(t0      ) & 0xff] ^
				T1[(t1 >>  8) & 0xff] ^
				T2[(t2 >> 16) & 0xff] ^
				T3[(t3 >> 24)       ] ^
				k[(r2*8)  ];
			s1 =
				T0[(t1      ) & 0xff] ^
				T1[(t2 >>  8) & 0xff] ^
				T2[(t3 >> 16) & 0xff] ^
				T3[(t0 >> 24)       ] ^
				k[(r2*8)+1];
			s2 =
				T0[(t2      ) & 0xff] ^
				T1[(t3 >>  8) & 0xff] ^
				T2[(t0 >> 16) & 0xff] ^
				T3[(t1 >> 24)       ] ^
				k[(r2*8)+2];
			s3 =
				T0[(t3      ) & 0xff] ^
				T1[(t0 >>  8) & 0xff] ^
				T2[(t1 >> 16) & 0xff] ^
				T3[(t2 >> 24)       ] ^
				k[(r2*8)+3];
			__LOG_TRACE__("p %d: s0 => 0x%04x",p,s0);
			__LOG_TRACE__("p %d: s1 => 0x%04x",p,s1);
			__LOG_TRACE__("p %d: s2 => 0x%04x",p,s2);
			__LOG_TRACE__("p %d: s3 => 0x%04x",p,s3);
		}

		if(key_bits >= 192) {
			key_index_sum = 8;

			t0 =
				T0[(s0      ) & 0xff] ^
				T1[(s1 >>  8) & 0xff] ^
				T2[(s2 >> 16) & 0xff] ^
				T3[(s3 >> 24)       ] ^
				k[36];
			t1 =
				T0[(s1      ) & 0xff] ^
				T1[(s2 >>  8) & 0xff] ^
				T2[(s3 >> 16) & 0xff] ^
				T3[(s0 >> 24)       ] ^
				k[37];
			t2 =
				T0[(s2      ) & 0xff] ^
				T1[(s3 >>  8) & 0xff] ^
				T2[(s0 >> 16) & 0xff] ^
				T3[(s1 >> 24)       ] ^
				k[38];
			t3 =
				T0[(s3      ) & 0xff] ^
				T1[(s0 >>  8) & 0xff] ^
				T2[(s1 >> 16) & 0xff] ^
				T3[(s2 >> 24)       ] ^
				k[39];
			__LOG_TRACE__("p %d: t0 => 0x%04x",p,t0);
			__LOG_TRACE__("p %d: t1 => 0x%04x",p,t1);
			__LOG_TRACE__("p %d: t2 => 0x%04x",p,t2);
			__LOG_TRACE__("p %d: t3 => 0x%04x",p,t3);

			s0 =
				T0[(t0      ) & 0xff] ^
				T1[(t1 >>  8) & 0xff] ^
				T2[(t2 >> 16) & 0xff] ^
				T3[(t3 >> 24)       ] ^
				k[40];
			s1 =
				T0[(t1      ) & 0xff] ^
				T1[(t2 >>  8) & 0xff] ^
				T2[(t3 >> 16) & 0xff] ^
				T3[(t0 >> 24)       ] ^
				k[41];
			s2 =
				T0[(t2      ) & 0xff] ^
				T1[(t3 >>  8) & 0xff] ^
				T2[(t0 >> 16) & 0xff] ^
				T3[(t1 >> 24)       ] ^
				k[42];
			s3 =
				T0[(t3      ) & 0xff] ^
				T1[(t0 >>  8) & 0xff] ^
				T2[(t1 >> 16) & 0xff] ^
				T3[(t2 >> 24)       ] ^
				k[43];
			__LOG_TRACE__("p %d: s0 => 0x%04x",p,s0);
			__LOG_TRACE__("p %d: s1 => 0x%04x",p,s1);
			__LOG_TRACE__("p %d: s2 => 0x%04x",p,s2);
			__LOG_TRACE__("p %d: s3 => 0x%04x",p,s3);

			if(key_bits == 256) {
				key_index_sum = 16;

				t0 =
					T0[(s0      ) & 0xff] ^
					T1[(s1 >>  8) & 0xff] ^
					T2[(s2 >> 16) & 0xff] ^
					T3[(s3 >> 24)       ] ^
					k[44];
				t1 =
					T0[(s1      ) & 0xff] ^
					T1[(s2 >>  8) & 0xff] ^
					T2[(s3 >> 16) & 0xff] ^
					T3[(s0 >> 24)       ] ^
					k[45];
				t2 =
					T0[(s2      ) & 0xff] ^
					T1[(s3 >>  8) & 0xff] ^
					T2[(s0 >> 16) & 0xff] ^
					T3[(s1 >> 24)       ] ^
					k[46];
				t3 =
					T0[(s3      ) & 0xff] ^
					T1[(s0 >>  8) & 0xff] ^
					T2[(s1 >> 16) & 0xff] ^
					T3[(s2 >> 24)       ] ^
					k[47];
				__LOG_TRACE__("p %d: t0 => 0x%04x",p,t0);
				__LOG_TRACE__("p %d: t1 => 0x%04x",p,t1);
				__LOG_TRACE__("p %d: t2 => 0x%04x",p,t2);
				__LOG_TRACE__("p %d: t3 => 0x%04x",p,t3);

				s0 =
					T0[(t0      ) & 0xff] ^
					T1[(t1 >>  8) & 0xff] ^
					T2[(t2 >> 16) & 0xff] ^
					T3[(t3 >> 24)       ] ^
					k[48];
				s1 =
					T0[(t1      ) & 0xff] ^
					T1[(t2 >>  8) & 0xff] ^
					T2[(t3 >> 16) & 0xff] ^
					T3[(t0 >> 24)       ] ^
					k[49];
				s2 =
					T0[(t2      ) & 0xff] ^
					T1[(t3 >>  8) & 0xff] ^
					T2[(t0 >> 16) & 0xff] ^
					T3[(t1 >> 24)       ] ^
					k[50];
				s3 =
					T0[(t3      ) & 0xff] ^
					T1[(t0 >>  8) & 0xff] ^
					T2[(t1 >> 16) & 0xff] ^
					T3[(t2 >> 24)       ] ^
					k[51];
				__LOG_TRACE__("p %d: s0 => 0x%04x",p,s0);
				__LOG_TRACE__("p %d: s1 => 0x%04x",p,s1);
				__LOG_TRACE__("p %d: s2 => 0x%04x",p,s2);
				__LOG_TRACE__("p %d: s3 => 0x%04x",p,s3);
			}
		}

		t0 =
			T0[(s0      ) & 0xff] ^
			T1[(s1 >>  8) & 0xff] ^
			T2[(s2 >> 16) & 0xff] ^
			T3[(s3 >> 24)       ] ^
			k[36+key_index_sum];
		t1 =
			T0[(s1      ) & 0xff] ^
			T1[(s2 >>  8) & 0xff] ^
			T2[(s3 >> 16) & 0xff] ^
			T3[(s0 >> 24)       ] ^
			k[37+key_index_sum];
		t2 =
			T0[(s2      ) & 0xff] ^
			T1[(s3 >>  8) & 0xff] ^
			T2[(s0 >> 16) & 0xff] ^
			T3[(s1 >> 24)       ] ^
			k[38+key_index_sum];
		t3 =
			T0[(s3      ) & 0xff] ^
			T1[(s0 >>  8) & 0xff] ^
			T2[(s1 >> 16) & 0xff] ^
			T3[(s2 >> 24)       ] ^
			k[39+key_index_sum];
		__LOG_TRACE__("p %d: t0 => 0x%04x",p,t0);
		__LOG_TRACE__("p %d: t1 => 0x%04x",p,t1);
		__LOG_TRACE__("p %d: t2 => 0x%04x",p,t2);
		__LOG_TRACE__("p %d: t3 => 0x%04x",p,t3);

		// last round - save result
		s0 =
			(T2[(t0      ) & 0xff] & 0x000000ff) ^
			(T3[(t1 >>  8) & 0xff] & 0x0000ff00) ^
			(T0[(t2 >> 16) & 0xff] & 0x00ff0000) ^
			(T1[(t3 >> 24)       ] & 0xff000000) ^
			k[40+key_index_sum];
		__LOG_TRACE__("p %d: s0 => 0x%04x",p,s0);
		d[p] = s0;
		s1 =
			(T2[(t1      ) & 0xff] & 0x000000ff) ^
			(T3[(t2 >>  8) & 0xff] & 0x0000ff00) ^
			(T0[(t3 >> 16) & 0xff] & 0x00ff0000) ^
			(T1[(t0 >> 24)       ] & 0xff000000) ^
			k[41+key_index_sum];
		__LOG_TRACE__("p %d: s1 => 0x%04x",p,s1);
		d[p+1] = s1;
		s2 =
			(T2[(t2      ) & 0xff] & 0x000000ff) ^
			(T3[(t3 >>  8) & 0xff] & 0x0000ff00) ^
			(T0[(t0 >> 16) & 0xff] & 0x00ff0000) ^
			(T1[(t1 >> 24)       ] & 0xff000000) ^
			k[42+key_index_sum];
		__LOG_TRACE__("p %d: s2 => 0x%04x",p,s2);
		d[p+2] = s2;
		s3 =
			(T2[(t3      ) & 0xff] & 0x000000ff) ^
			(T3[(t0 >>  8) & 0xff] & 0x0000ff00) ^
			(T0[(t1 >> 16) & 0xff] & 0x00ff0000) ^
			(T2[(t2 >> 24)       ] & 0xff000000) ^
			k[43+key_index_sum];
		__LOG_TRACE__("p %d: s3 => 0x%04x",p,s3);
		d[p+3] = s3;
	}
}

__global__ void __cuda_ecb_aes_16b_decrypt__(
		  int n,
		  uint32_t* d,
	  	  uint32_t* k,
	  	  int key_bits,
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
		int key_index_sum = 0;

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
			__LOG_TRACE__("p %d: (s0      ) & 0xff => 0x%04x",p,(s0      ) & 0xff);
			__LOG_TRACE__("p %d: (s3 >>  8) & 0xff => 0x%04x",p,(s3 >>  8) & 0xff);
			__LOG_TRACE__("p %d: (s2 >> 16) & 0xff => 0x%04x",p,(s2 >> 16) & 0xff);
			__LOG_TRACE__("p %d: (s1 >> 24)        => 0x%04x",p,(s1 >> 24));
			__LOG_TRACE__("p %d: T0[(s0      ) & 0xff] => 0x%04x",p,T0[(s0      ) & 0xff]);
			__LOG_TRACE__("p %d: T1[(s3 >>  8) & 0xff] => 0x%04x",p,T1[(s3 >>  8) & 0xff]);
			__LOG_TRACE__("p %d: T2[(s2 >> 16) & 0xff] => 0x%04x",p,T2[(s2 >> 16) & 0xff]);
			__LOG_TRACE__("p %d: T3[(s1 >> 24)       ] => 0x%04x",p,T3[(s1 >> 24)       ]);
			__LOG_TRACE__("p %d: k[%d] => 0x%04x",p,(r2*8)-4 , k[(r2*8)-4]);
			t0 =
				T0[(s0      ) & 0xff] ^
				T1[(s3 >>  8) & 0xff] ^
				T2[(s2 >> 16) & 0xff] ^
				T3[(s1 >> 24)       ] ^
				k[(r2*8)-4];
			t1 =
				T0[(s1      ) & 0xff] ^
				T1[(s0 >>  8) & 0xff] ^
				T2[(s3 >> 16) & 0xff] ^
				T3[(s2 >> 24)       ] ^
				k[(r2*8)-3];
			t2 =
				T0[(s2      ) & 0xff] ^
				T1[(s1 >>  8) & 0xff] ^
				T2[(s0 >> 16) & 0xff] ^
				T3[(s3 >> 24)       ] ^
				k[(r2*8)-2];
			t3 =
				T0[(s3      ) & 0xff] ^
				T1[(s2 >>  8) & 0xff] ^
				T2[(s1 >> 16) & 0xff] ^
				T3[(s0 >> 24)       ] ^
				k[(r2*8)-1];
			__LOG_TRACE__("p %d: t0 => 0x%04x",p,t0);
			__LOG_TRACE__("p %d: t1 => 0x%04x",p,t1);
			__LOG_TRACE__("p %d: t2 => 0x%04x",p,t2);
			__LOG_TRACE__("p %d: t3 => 0x%04x",p,t3);

			s0 =
				T0[(t0      ) & 0xff] ^
				T1[(t3 >>  8) & 0xff] ^
				T2[(t2 >> 16) & 0xff] ^
				T3[(t1 >> 24)       ] ^
				k[(r2*8)  ];
			s1 =
				T0[(t1      ) & 0xff] ^
				T1[(t0 >>  8) & 0xff] ^
				T2[(t3 >> 16) & 0xff] ^
				T3[(t2 >> 24)       ] ^
				k[(r2*8)+1];
			s2 =
				T0[(t2      ) & 0xff] ^
				T1[(t1 >>  8) & 0xff] ^
				T2[(t0 >> 16) & 0xff] ^
				T3[(t3 >> 24)       ] ^
				k[(r2*8)+2];
			s3 =
				T0[(t3      ) & 0xff] ^
				T1[(t2 >>  8) & 0xff] ^
				T2[(t1 >> 16) & 0xff] ^
				T3[(t0 >> 24)       ] ^
				k[(r2*8)+3];
			__LOG_TRACE__("p %d: s0 => 0x%04x",p,s0);
			__LOG_TRACE__("p %d: s1 => 0x%04x",p,s1);
			__LOG_TRACE__("p %d: s2 => 0x%04x",p,s2);
			__LOG_TRACE__("p %d: s3 => 0x%04x",p,s3);
		}

		if(key_bits >= 192) {
			key_index_sum = 8;

			t0 =
				T0[(s0      ) & 0xff] ^
				T1[(s3 >>  8) & 0xff] ^
				T2[(s2 >> 16) & 0xff] ^
				T3[(s1 >> 24)       ] ^
				k[36];
			t1 =
				T0[(s1      ) & 0xff] ^
				T1[(s0 >>  8) & 0xff] ^
				T2[(s3 >> 16) & 0xff] ^
				T3[(s2 >> 24)       ] ^
				k[37];
			t2 =
				T0[(s2      ) & 0xff] ^
				T1[(s1 >>  8) & 0xff] ^
				T2[(s0 >> 16) & 0xff] ^
				T3[(s3 >> 24)       ] ^
				k[38];
			t3 =
				T0[(s3      ) & 0xff] ^
				T1[(s2 >>  8) & 0xff] ^
				T2[(s1 >> 16) & 0xff] ^
				T3[(s0 >> 24)       ] ^
				k[39];
			__LOG_TRACE__("p %d: t0 => 0x%04x",p,t0);
			__LOG_TRACE__("p %d: t1 => 0x%04x",p,t1);
			__LOG_TRACE__("p %d: t2 => 0x%04x",p,t2);
			__LOG_TRACE__("p %d: t3 => 0x%04x",p,t3);

			s0 =
				T0[(t0      ) & 0xff] ^
				T1[(t3 >>  8) & 0xff] ^
				T2[(t2 >> 16) & 0xff] ^
				T3[(t1 >> 24)       ] ^
				k[40];
			s1 =
				T0[(t1      ) & 0xff] ^
				T1[(t0 >>  8) & 0xff] ^
				T2[(t3 >> 16) & 0xff] ^
				T3[(t2 >> 24)       ] ^
				k[41];
			s2 =
				T0[(t2      ) & 0xff] ^
				T1[(t1 >>  8) & 0xff] ^
				T2[(t0 >> 16) & 0xff] ^
				T3[(t3 >> 24)       ] ^
				k[42];
			s3 =
				T0[(t3      ) & 0xff] ^
				T1[(t2 >>  8) & 0xff] ^
				T2[(t1 >> 16) & 0xff] ^
				T3[(t0 >> 24)       ] ^
				k[43];
			__LOG_TRACE__("p %d: s0 => 0x%04x",p,s0);
			__LOG_TRACE__("p %d: s1 => 0x%04x",p,s1);
			__LOG_TRACE__("p %d: s2 => 0x%04x",p,s2);
			__LOG_TRACE__("p %d: s3 => 0x%04x",p,s3);


			if(key_bits >= 256) {
				key_index_sum = 16;

				t0 =
					T0[(s0      ) & 0xff] ^
					T1[(s3 >>  8) & 0xff] ^
					T2[(s2 >> 16) & 0xff] ^
					T3[(s1 >> 24)       ] ^
					k[44];
				t1 =
					T0[(s1      ) & 0xff] ^
					T1[(s0 >>  8) & 0xff] ^
					T2[(s3 >> 16) & 0xff] ^
					T3[(s2 >> 24)       ] ^
					k[45];
				t2 =
					T0[(s2      ) & 0xff] ^
					T1[(s1 >>  8) & 0xff] ^
					T2[(s0 >> 16) & 0xff] ^
					T3[(s3 >> 24)       ] ^
					k[46];
				t3 =
					T0[(s3      ) & 0xff] ^
					T1[(s2 >>  8) & 0xff] ^
					T2[(s1 >> 16) & 0xff] ^
					T3[(s0 >> 24)       ] ^
					k[47];
				__LOG_TRACE__("p %d: t0 => 0x%04x",p,t0);
				__LOG_TRACE__("p %d: t1 => 0x%04x",p,t1);
				__LOG_TRACE__("p %d: t2 => 0x%04x",p,t2);
				__LOG_TRACE__("p %d: t3 => 0x%04x",p,t3);

				s0 =
					T0[(t0      ) & 0xff] ^
					T1[(t3 >>  8) & 0xff] ^
					T2[(t2 >> 16) & 0xff] ^
					T3[(t1 >> 24)       ] ^
					k[48];
				s1 =
					T0[(t1      ) & 0xff] ^
					T1[(t0 >>  8) & 0xff] ^
					T2[(t3 >> 16) & 0xff] ^
					T3[(t2 >> 24)       ] ^
					k[49];
				s2 =
					T0[(t2      ) & 0xff] ^
					T1[(t1 >>  8) & 0xff] ^
					T2[(t0 >> 16) & 0xff] ^
					T3[(t3 >> 24)       ] ^
					k[50];
				s3 =
					T0[(t3      ) & 0xff] ^
					T1[(t2 >>  8) & 0xff] ^
					T2[(t1 >> 16) & 0xff] ^
					T3[(t0 >> 24)       ] ^
					k[51];
				__LOG_TRACE__("p %d: s0 => 0x%04x",p,s0);
				__LOG_TRACE__("p %d: s1 => 0x%04x",p,s1);
				__LOG_TRACE__("p %d: s2 => 0x%04x",p,s2);
				__LOG_TRACE__("p %d: s3 => 0x%04x",p,s3);
			}
		}

		t0 =
			T0[(s0      ) & 0xff] ^
			T1[(s3 >>  8) & 0xff] ^
			T2[(s2 >> 16) & 0xff] ^
			T3[(s1 >> 24)       ] ^
			k[36+key_index_sum];
		t1 =
			T0[(s1      ) & 0xff] ^
			T1[(s0 >>  8) & 0xff] ^
			T2[(s3 >> 16) & 0xff] ^
			T3[(s2 >> 24)       ] ^
			k[37+key_index_sum];
		t2 =
			T0[(s2      ) & 0xff] ^
			T1[(s1 >>  8) & 0xff] ^
			T2[(s0 >> 16) & 0xff] ^
			T3[(s3 >> 24)       ] ^
			k[38+key_index_sum];
		t3 =
			T0[(s3      ) & 0xff] ^
			T1[(s2 >>  8) & 0xff] ^
			T2[(s1 >> 16) & 0xff] ^
			T3[(s0 >> 24)       ] ^
			k[39+key_index_sum];
		__LOG_TRACE__("p %d: t0 => 0x%04x",p,t0);
		__LOG_TRACE__("p %d: t1 => 0x%04x",p,t1);
		__LOG_TRACE__("p %d: t2 => 0x%04x",p,t2);
		__LOG_TRACE__("p %d: t3 => 0x%04x",p,t3);

		// last round - save result
		s0 =
			((uint32_t)T4[(t0      ) & 0xff]      ) ^
			((uint32_t)T4[(t3 >>  8) & 0xff] <<  8) ^
			((uint32_t)T4[(t2 >> 16) & 0xff] << 16) ^
			((uint32_t)T4[(t1 >> 24)       ] << 24) ^
			k[40+key_index_sum];
		__LOG_TRACE__("p %d: s0 => 0x%04x",p,s0);
		d[p] = s0;
		s1 =
			((uint32_t)T4[(t1      ) & 0xff]      ) ^
			((uint32_t)T4[(t0 >>  8) & 0xff] <<  8) ^
			((uint32_t)T4[(t3 >> 16) & 0xff] << 16) ^
			((uint32_t)T4[(t2 >> 24)       ] << 24) ^
			k[41+key_index_sum];
		__LOG_TRACE__("p %d: s1 => 0x%04x",p,s1);
		d[p+1] = s1;
		s2 =
			((uint32_t)T4[(t2      ) & 0xff]      ) ^
			((uint32_t)T4[(t1 >>  8) & 0xff] <<  8) ^
			((uint32_t)T4[(t0 >> 16) & 0xff] << 16) ^
			((uint32_t)T4[(t3 >> 24)       ] << 24) ^
			k[42+key_index_sum];
		__LOG_TRACE__("p %d: s2 => 0x%04x",p,s2);
		d[p+2] = s2;
		s3 =
			((uint32_t)T4[(t3      ) & 0xff]      ) ^
			((uint32_t)T4[(t2 >>  8) & 0xff] <<  8) ^
			((uint32_t)T4[(t1 >> 16) & 0xff] << 16) ^
			((uint32_t)T4[(t0 >> 24)       ] << 24) ^
			k[43+key_index_sum];
		__LOG_TRACE__("p %d: s3 => 0x%04x",p,s3);
		d[p+3] = s3;
	}
}

void cuda_ecb_aes_16b_encrypt(
		  	  int gridSize,
		  	  int threadsPerBlock,
		  	  cudaStream_t stream,
		  	  int n_blocks,
		  	  unsigned char data[],
		  	  uint32_t* expanded_key,
		  	  int key_bits,
		  	  uint32_t* deviceTe0,
		  	  uint32_t* deviceTe1,
		  	  uint32_t* deviceTe2,
		  	  uint32_t* deviceTe3
	      )
{
	__cuda_ecb_aes_16b_encrypt__<<<gridSize,threadsPerBlock,0,stream>>>(
			n_blocks,
			(uint32_t*)data,
			expanded_key,
			key_bits,
	   		deviceTe0,
	   		deviceTe1,
	   		deviceTe2,
	   		deviceTe3
	);
}

void cuda_ecb_aes_16b_decrypt(
		  	  int gridSize,
		  	  int threadsPerBlock,
		  	  cudaStream_t stream,
		  	  int n_blocks,
		  	  unsigned char data[],
		  	  uint32_t* expanded_key,
		  	  int key_bits,
		  	  uint32_t* deviceTd0,
		  	  uint32_t* deviceTd1,
		  	  uint32_t* deviceTd2,
		  	  uint32_t* deviceTd3,
		  	  uint8_t* deviceTd4
	      )
{
	__cuda_ecb_aes_16b_decrypt__<<<gridSize,threadsPerBlock,0,stream>>>(
			n_blocks,
			(uint32_t*)data,
			expanded_key,
			key_bits,
	   		deviceTd0,
	   		deviceTd1,
	   		deviceTd2,
	   		deviceTd3,
	   		deviceTd4
	);
}