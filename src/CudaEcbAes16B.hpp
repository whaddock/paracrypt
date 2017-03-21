#include "AES.hpp"

namespace paracrypt {

    class CudaEcbAES16B: public CudaAES {
      private:
        int getGridSize(int n_blocks);
      public:
	int encrypt(const unsigned char in[], const unsigned char out[], int n_blocks);
	int decrypt(const unsigned char in[], const unsigned char out[], int n_blocks);
    };

}