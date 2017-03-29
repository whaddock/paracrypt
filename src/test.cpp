#include "CUDACipherDevice.hpp"
#include "CudaEcbAes16B.hpp"

int main()
{
    paracrypt::CUDACipherDevice* gpu = new paracrypt::CUDACipherDevice(0);
    paracrypt::CudaAES* aes = new paracrypt::CudaEcbAES16B();
    delete aes;
    delete gpu;

}
