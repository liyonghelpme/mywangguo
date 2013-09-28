/* crypto/rsa/rsa.h */
#ifndef RSA_HEADER_H
#define RSA_HEADER_H

#include "bigint.h"

typedef struct RSA_STRUCT{
	BI modulus;
	BI D;
	BI E;
} RSA;

RSA* rsa_malloc(int isPub, unsigned char* data);

void rsa_free(RSA* rsa);

int rsa_sign(unsigned char* m, int m_length, unsigned char* sigret, int siglen, RSA* rsa);

int rsa_verify(unsigned char* m, int m_length, unsigned char* sigret, int siglen, RSA* rsa);

#endif //RSA_HEADER_H