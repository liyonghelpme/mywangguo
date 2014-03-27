
#include "crypto/CCCrypto.h"
#include <string>

extern "C" {
#include "crypto/base64/libb64.h"
#include "crypto/md5/md5.h"
#include "crypto/sha1/sha1.h"
#include "crypto/rsa/rsa.h"
#include <stdio.h>
#include <string.h>
}

NS_CC_EXT_BEGIN

const char* CCCrypto::encodeSha1(unsigned char* input, int inputLength)
{
	unsigned char buffer[SHA1_BUFFER_LENGTH];
    sha1_encode(input, inputLength, buffer);
	return bin2hex(buffer, SHA1_BUFFER_LENGTH);
}

/* make encoded str with MD5; need to be deleted by user */
const char* CCCrypto::encodeMd5(void* input, int inputLength)
{
    unsigned char buffer[MD5_BUFFER_LENGTH];
    MD5(input, inputLength, buffer);
	return bin2hex(buffer, MD5_BUFFER_LENGTH);
}

const char* CCCrypto::encodeBase64(const void* input, int inputLength)
{
    int bufferSize = 2 * inputLength;
    char* buffer = new char[bufferSize];
    memset(buffer, 0, bufferSize);
    
    base64_encodestate state;
    base64_init_encodestate(&state);
    int r1 = base64_encode_block(static_cast<const char*>(input), inputLength, buffer, &state);
    int r2 = base64_encode_blockend(buffer+ r1, &state);

    return buffer;
}

int CCCrypto::decodeBase64(const char* input, void* output, int outputLength)
{
    int bufferSize = strlen(input) + 1;
    char* buffer = (char *)malloc(bufferSize);
    memset(buffer, 0, bufferSize);
    base64_decodestate state;
    base64_init_decodestate(&state);
    int r1 = base64_decode_block(input, bufferSize - 1, buffer, &state);
    
    memset(output, 0, outputLength);
    int cp = r1 < outputLength ? r1 : outputLength - 1;
    memcpy(output, buffer, cp);
    free(buffer);
    return cp;
}

int CCCrypto::rsa_sign_with_private(unsigned char* msg, int m_length, unsigned char* output, int outputLength, const char* privateKey)
{
	int bufferSize = strlen(privateKey)+1;
	unsigned char* pkeyBuffer = (unsigned char*)malloc(bufferSize);
	decodeBase64(privateKey, pkeyBuffer, bufferSize);
	RSA* rsa = rsa_malloc(0, pkeyBuffer);
	free(pkeyBuffer);
	
	unsigned char buffer[SHA1_BUFFER_LENGTH];
    sha1_encode(msg, m_length, buffer);

	int cp = rsa_sign(buffer, SHA1_BUFFER_LENGTH, (unsigned char*)output, outputLength, rsa);
	rsa_free(rsa);
	return cp;
}

int CCCrypto::rsa_verify_with_public(unsigned char* msg, int m_length, unsigned char* sig, int siglen, const char* publicKey)
{
	int bufferSize = strlen(publicKey)+1;
	unsigned char* pkeyBuffer = (unsigned char*)malloc(bufferSize);
	decodeBase64(publicKey, pkeyBuffer, bufferSize);
	RSA* rsa=rsa_malloc(1, pkeyBuffer);
	free(pkeyBuffer);
	
	unsigned char buffer[SHA1_BUFFER_LENGTH];
    sha1_encode(msg, m_length, buffer);

	int verify = rsa_verify(buffer, SHA1_BUFFER_LENGTH, sig, siglen, rsa);
	rsa_free(rsa);
	return verify;
}

const char* CCCrypto::encodeUrl(const char* input)
{
	int inputLength = strlen(input);
    int bufferSize = 3 * inputLength+1;
    char* buffer = new char[bufferSize];
	int i = 0, j = 0;
    memset(buffer, 0, bufferSize);

	for(i=0;i<inputLength;i++)
	{
		char c = input[i];
		if((c>='0' && c<='9') || (c>='a' && c<='z') || (c>='A' && c<='Z')){
			buffer[j++] = c;
		}
		else{
			sprintf(buffer+j, "%%%02X", c);
			j=j+3;
		}
	}

    return buffer;
}

void CCCrypto::sha1_encode(unsigned char* input, int inputLength, unsigned char* output)
{
    SHA1 sha1;
    sha1.addBytes(input, inputLength);
    sha1.getDigest(output, SHA1_BUFFER_LENGTH);
}

void CCCrypto::MD5(void* input, int inputLength, unsigned char* output)
{
    MD5_CTX ctx;
    MD5_Init(&ctx);
    MD5_Update(&ctx, input, inputLength);
    MD5_Final(output, &ctx);
}

char* CCCrypto::bin2hex(unsigned char* input, int inputLength)
{
	char* output = new char[inputLength*2 + 1];
	int i;
	for(i=0;i<inputLength;i++){
		sprintf(output + i*2, "%02x", input[i]);
	}
	return output;
}

NS_CC_EXT_END
