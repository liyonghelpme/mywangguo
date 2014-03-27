
#ifndef __CC_EXTENSION_CCCRYPTO_H_
#define __CC_EXTENSION_CCCRYPTO_H_

#include "cocos2d_ext_const.h"

NS_CC_EXT_BEGIN

class CCCrypto
{
public:
    static const int MD5_BUFFER_LENGTH = 16;
	static const int SHA1_BUFFER_LENGTH = 20;

    /** @brief Calculate MD5, return MD5 string */
    static const char* encodeMd5(void* input, int inputLength);

	/** @brief Encoding data with Base64 algorithm, return encoded string */
    static const char* encodeBase64(const void* input, int inputLength);
    
    /** @brief Decoding Base64 string to data, return decoded data length */
    static int decodeBase64(const char* input, void* output, int outputLength);
    
    /** @brief Calculate SHA1 with a secret key. */
    static const char* encodeSha1(unsigned char* input, int inputLength);
	
    /** @brief Encoding data with RSA-PrivateKey to data, return encoded data length */
	static int rsa_sign_with_private(unsigned char* msg, int m_Length, unsigned char* output, int outputLength, const char* privateKey);
	
    /** @brief Decoding data with RSA-PublicKey to data, return decoded data length */
	static int rsa_verify_with_public(unsigned char* msg, int m_Length, unsigned char* sig, int siglen, const char* publicKey);

	static const char* encodeUrl(const char* input);
private:
    CCCrypto(void) {}

	static void MD5(void* input, int inputLength, unsigned char* output);

	static void sha1_encode(unsigned char* input, int inputLength, unsigned char* output);

	static char* bin2hex(unsigned char* input, int inputLength);
};

NS_CC_EXT_END

#endif // __CC_EXTENSION_CCCRYPTO_H_
