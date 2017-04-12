#define BOOST_TEST_MODULE paracrypt
#include <boost/test/included/unit_test.hpp>
#include <stdint.h>
#include "../logging.hpp"
#include "../openssl/AES_key_schedule.h"
#include "../device/CUDACipherDevice.hpp"
#include "../AES/CudaEcbAes16B.hpp"
#include "../AES/CudaEcbAes16BPtr.hpp"
#include "../endianess.h"
#include "../Timer.hpp"
#include "cuda_test_kernels.cuh"

//bool init_unit_test()
//{
//	boost::log::core::get()->set_filter
//    (
//    		boost::log::trivial::severity >= boost::log::trivial::trace
//    );
//    return true;
//}

const unsigned char k[128] = {
    0x2bU, 0x7eU, 0x15U, 0x16U,
    0x28U, 0xaeU, 0xd2U, 0xa6U,
    0xabU, 0xf7U, 0x15U, 0x88U,
    0x09U, 0xcfU, 0x4fU, 0x3cU
};

const unsigned char k2[192] = {
    0x00U, 0x01U, 0x02U, 0x03U,
    0x04U, 0x05U, 0x06U, 0x07U,
    0x08U, 0x09U, 0x0aU, 0x0bU,
    0x0cU, 0x0dU, 0x0eU, 0x0fU,
    0x10U, 0x11U, 0x12U, 0x13U,
    0x14U, 0x15U, 0x16U, 0x17U
};

	BOOST_AUTO_TEST_SUITE(key_expansion)
#include "key_schedule_test.cpp"
    BOOST_AUTO_TEST_SUITE_END()

    // how to run a specific test: ./paracrypt_tests --run_test=cuda_aes/cuda_ecb_aes192_16b_singleblock
    BOOST_AUTO_TEST_SUITE(cuda_aes)
#include "cuda_aes_test.cpp"
    BOOST_AUTO_TEST_SUITE_END()
