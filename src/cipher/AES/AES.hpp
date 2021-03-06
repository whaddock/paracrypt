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

#pragma once

#include "cipher/BlockCipher.hpp"
#include "openssl/AES_key_schedule.h"

namespace paracrypt {

    class AES {
#define AES_STATE_SIZE 128
#define AES_BLOCK_SIZE AES_STATE_SIZE
#define AES_STATE_SIZE_B 16
#define AES_BLOCK_SIZE_B AES_STATE_SIZE_B

      private:
    unsigned char* key;
    int keyBits;
	AES_KEY * enRoundKeys;
	AES_KEY * deRoundKeys;

	bool enKeyPropietary;
	bool deKeyPropietary;
      protected:
	bool isCopy;

//    virtual int getThreadsPerCipherBlock() = 0;
      public:
	AES();
	AES(AES* aes); // Shallow copy constructor
	virtual ~AES();

// To be implemented by child when combining AES with BlockCipher
//
//	virtual int encrypt(const unsigned char in[],
//			    const unsigned char out[], std::streamsize n_blocks)
//	    = 0;
//	virtual int decrypt(const unsigned char in[],
//			    const unsigned char out[], std::streamsize n_blocks)
//	    = 0;
//
// int setKey(const unsigned char key[], int bits) {
//		return paracrypt::AES::setKey(key,bits);
// }
//
//  virtual int setBlockSize(int bits) = 0;

	int setKey(const unsigned char key[], int bits);
	int setEncryptionKey(AES_KEY * expandedKey);
	int setDecryptionKey(AES_KEY * expandedKey);
	AES_KEY *getEncryptionExpandedKey();
	AES_KEY *getDecryptionExpandedKey();
	int getKeyBits(int rounds);

    };
}
