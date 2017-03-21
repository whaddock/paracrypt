#include "AES.hpp"

namespace paracrypt {

    class CudaAES:public AES {
      private:
        CUDACipherDevice device;
	AES_KEY* deviceKey = NULL;
        char* data;
      protected:
	AES_KEY* getDeviceKey();
	#define HANDLE_ERROR( err ) (HandleError( err, __FILE__, __LINE__ ))
	static void HandleError( cudaError_t err,
                         const char *file,
                         int line );
      public:
        ~CudaAES();
	virtual int encrypt(const unsigned char in[], const unsigned char out[], int n_blocks) = 0;
	virtual int decrypt(const unsigned char in[], const unsigned char out[], int n_blocks) = 0;
	void setDevice(CUDACipherDevice device);
        void malloc(int n_blocks); // Must be called to reserve enough space before encrypt/decrypt
                                  // returns -1 if an error has ocurred
	CUDACipherDevice* getDevice();
    };

}