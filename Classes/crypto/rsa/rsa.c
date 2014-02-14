#include <string.h>
#include <malloc.h>

#include "rsa.h"

RSA* rsa_malloc(int isPub, unsigned char* data)
{
	RSA* ret = (RSA*)malloc(sizeof(RSA));
	if(isPub==1){
		ret->modulus = bi_malloc_default();
		bi_load_data(ret->modulus, data + 28, 129);
		ret->E = bi_malloc_default();
		bi_load_data(ret->E, data + 159, 3);
		ret->D = NULL;
	}
	else{
		ret->modulus = bi_malloc_default();
		bi_load_data(ret->modulus, data + 36, 129);
		ret->D = bi_malloc_default();
		bi_load_data(ret->D, data + 173, 128);
		ret->E = NULL;
	}
	return ret;
}

void rsa_free(RSA* rsa)
{
	bi_free(rsa->modulus);
	if(rsa->D!=NULL){
		bi_free(rsa->D);
	}
	if(rsa->E!=NULL){
		bi_free(rsa->E);
	}
	free(rsa);
}

int rsa_sign(unsigned char* m_data, int m_length, unsigned char* sigret, int siglen, RSA* rsa)
{
	BI m = bi_malloc_default();
	BI r = bi_malloc_default();
	int cp;
	bi_load_data(m, m_data, m_length);
	bi_powm(m, rsa->D, rsa->modulus, r);
	bi_free(m);

	cp = r->length>siglen?siglen:r->length;
	memcpy(sigret, r->first - cp+1, cp);
	bi_free(r);
	return cp;
}

int rsa_verify(unsigned char* m, int m_length, unsigned char* sig, int siglen, RSA* rsa)
{
	int verify = 1, i;
	BI s = bi_malloc_default();
	BI r = bi_malloc_default();
	bi_load_data(s, sig, siglen);
	bi_powm(s, rsa->E, rsa->modulus, r);
	bi_free(s);

	if(r->length!=m_length){
		verify=0;
	}
	else{
		for(i=0; i<m_length; i++){
			if(m[i]!=r->first[i-m_length+1]){
				verify=0;
				break;
			}
		}
	}
	bi_free(r);
	return verify;
}
