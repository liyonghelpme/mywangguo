/**
 * Copyright (c) 2009 Koder Chen. All Rights Reserved.
 *
 * bigint.h
 * The file defines the basic operations needed to manipulate the big integer,
 * including the add, minus, multiply, and so, on
 *
 *  Author: chenfuhan
 * Created: 2009-6-1
 * Version: 1.0
 */
#include <stdlib.h>
#include <stdio.h>
#include <memory.h>
#include <time.h>

#include "bigint.h"

// some predifined constant
// the maximum of the bits for a big integer
const int MAX_BITS=2048;
const int MAX_BYTES=256;

// the global bits array
const unsigned char BITS[9] = {0, 1, 3, 7, 15, 31, 63, 127, 255};

BI bi_malloc_default()
{
	BI ret = (BI)malloc(sizeof(struct BIGINT));
	ret->basePt = (unsigned char*)malloc(MAX_BYTES);
	memset(ret->basePt, 0, MAX_BYTES);
	ret->first = ret->basePt + MAX_BYTES - 1;
	ret->length = 0;
	return ret;
}

void bi_load_data(BI a, unsigned char* data, int length)
{
	a->length = length;
	memcpy(a->basePt + MAX_BYTES - length, data, length);
}

void bi_free(BI b)
{
	if(b!=NULL){
		free(b->basePt);
		free(b);
	}
}

#define getMaxSize(a, b) (a->length>b->length?a->length:b->length)
#define bi_get_bit(a, i) ((a->first[-i/8]>>(i%8))&1)

void bi_add(BI a, BI b, BI out)
{
	int i=0;
	int c=0, m=0;
	int size = getMaxSize(a, b);
	for(i=0;i>=-size;i--)
	{

		m=a->first[-i] + b->first[-i] + c;
		c=(m >> 8);
		out->first[-i]=(m & 0xff);
	}
	out->length = size + (out->first[-size]==0?0:1);
}

void bi_sub(BI a, BI b, BI out)
{
	// the calculation
	int i=0, c=0, m=0;
	int size = a->length;
	unsigned char *ap=a->first, *bp=b->first, *op=out->first;
	for(i=0;i>-size;i--)
	{
		m=ap[i]-bp[i]-c;
		if(m<0)
		{
			op[i]=m+256;
			c=1;
		}
		else
		{
			c=0;
			op[i]=m;
		}
	}
	for(i=1-size; i<=0; i++)
	{
		if(op[i]>0){
			out->length = 1-i;
			break;
		}
	}
}

void bi_mul(BI a, BI b, BI out)
{
	// calculation
	int i=0, j=0, c=0, r=0, k=0;
	unsigned char *ap=a->first, *bp=b->first, *op=out->first;
	memset(out->basePt, 0, MAX_BYTES);
	for(i=0;i>-a->length;i--)
	{
		for(c=0, j=0;j>=-b->length;j--)
		{
			r=i+j;
			k=op[r]+(ap[i]*bp[j]+c);
			c=(k>>8);
			op[r]=(k & 0xff);
		}
	}
	if(op[r] != 0){
		out->length = 1-r;
	}
	else{
		out->length = -r;
	}
}

void bi_div(BI a, BI b, BI quot, BI rema)
{
	// the calculation
	int abits=0, bbits=0, i=0, c=0, tempLength=0, bitOff=0, byteBegin=0;
	unsigned char byte=0;
	BI temp;
	// check the number of realbytes, and make sure we are not
	// divided by zero
	abits=bi_bits(a);
	bbits=bi_bits(b);
	// the calculation
	memset(quot->basePt, 0, MAX_BYTES);
	quot->length = 1;
	if(bi_comp(a, b)<0)
	{
		bi_copy_bytes(rema, a);
	}
	else
	{
		// first step, move the MORE department to rema
		memset(rema->basePt, 0, MAX_BYTES);
		tempLength = (bbits-2)/8+1;
		rema->length = tempLength;
		bitOff=(abits-bbits+1)%8;
		byteBegin=-(abits-bbits+1)/8;
		for(i=0; i>-tempLength;i--)
		{
			rema->first[i] = ((a->first[byteBegin+i] >> bitOff) + (a->first[byteBegin+i-1] << (8-bitOff)))&255;
		}
		//rema->first[1-tempLength] = rema->first[1-tempLength] & BITS[((bbits%8)+7)%9];

		// now the calculation
		for(c=bbits-1, i=abits-bbits;i>=0;i--)
		{
			bi_lshift(rema, 1, bi_get_bit(a, i));
			if(c>=(bbits-1) && bi_comp(rema, b)>=0)
			{
				byte = 1+(byte<<1);
				temp = bi_malloc_default();
				bi_sub(rema, b, temp);
				bi_copy_bytes(rema, temp);
				bi_free(temp);
				c=bi_bits(rema);
			}
			else
			{
				byte = byte<<1;
				c++;
			}
			if(i%8==0){
				quot->first[-i/8] = byte;
				byte = 0;
			}
		}
		//quot->length = MAX_BYTES;
		//quot->length = (bi_bits(quot)-1)/8 + 1;
	}
}

void bi_mod(BI a, BI b, BI out)
{
	BI temp = bi_malloc_default();
	bi_div(a, b, temp, out);
	bi_free(temp);
	/*
	int abits=0, bbits=0, i=0, c=0, j=0, bitOff=0, byteBegin=0, k=0, s=0;
	bi_copy_bytes(out, a);
	if(bi_comp(a, b)>=0){
		abits=bi_bits(a);
		bbits=bi_bits(b);
		for(c=bbits, i=abits-bbits;i>=0;i--)
		{
			if(c>=bbits)
			{
				bitOff=i%8;
				byteBegin=-i/8;
				for(j=1-b->length;j<=0;j++)
				{
					k=b->first[j]-((out->first[byteBegin+j]>>bitOff)+(out->first[byteBegin+j-1] << (8-bitOff)))&255;
					if(k>0)
					{
						break;
					}
					else if(k==0){
						continue;
					}
					else{
						//for(k=1-b->length;k<j-1;k++){
						//	out->first[byteBegin+k-1] = 0;
						//}
						//out->first[byteBegin+j-1] = out->first[byteBegin+j-1] & (255>>bitOff);
						c=0;
						for(k=0;k>=1-b->length||c>0;k--){
							s = ((out->first[byteBegin+k]>>bitOff)+(out->first[byteBegin+k-1] << (8-bitOff)))&255 - b->first[k]-c;
							if(s<0){
								c=1;
								s=s+256;
							}
							else{
								c=0;
							}
							out->first[byteBegin+k] = (out->first[byteBegin+k] & (255>>(8-bitOff))) + (s<<bitOff) & 255;
							out->first[byteBegin+k-1] = ((out->first[byteBegin+k-1] >> bitOff) << bitOff) + (s>>(8-bitOff));
						}
						c = bi_bits(out)-i;
						break;
					}
				}
			}
			c++;
		}
	}*/
}

void bi_gcd(BI a, BI b, BI out)
{
	BI p = bi_malloc_default();
	BI q = bi_malloc_default();
	BI r = bi_malloc_default();
	BI t = 0;
	// initialization
	bi_copy_bytes(p, a);
	bi_copy_bytes(q, b);
	// make sure p is bigger than q
	if(bi_comp(p, q) < 0)
	{
		BI t = p;
		p = q;
		q = t;
		t = 0;
	}
	while(bi_bits(q) > 0)
	{
		t = p;
		bi_mod(p, q, r);
		p = q;
		q = r;
		r = t;
		t = 0;
	}

	bi_copy_bytes(out, p);
	bi_free(p);
	bi_free(q);
	bi_free(r);
}

void bi_powm(BI a, BI b, BI n, BI out)
{
	BI r = bi_malloc_default();
	BI m = bi_malloc_default();
	int bits = bi_bits(b)-2;
	int mt = 0;
	int dt = 0;
	int t;
	clock_t dwStart, dwEnd;
	bi_mod(a, n, r);
	
	while(bits >= 0)
	{
		dwStart=clock();
		t = bi_get_bit(b, bits);
		bi_mul(r, r, m);
		dwEnd = clock();
		mt += dwEnd-dwStart;
		dwStart = clock();
		bi_mod(m, n, r);
		dwEnd = clock();
		dt += dwEnd-dwStart;
		if (t > 0)
		{
			dwStart = clock();
			bi_mul(r, a, m);
			dwEnd = clock();
			mt += dwEnd-dwStart;
			dwStart = clock();
			bi_mod(m, n, r);
			dwEnd = clock();
			dt += dwEnd-dwStart;
		}
		bits --;
	}
	printf("%d %d\n", mt, dt);
	bi_copy_bytes(out, r);
	bi_free(m);
	bi_free(r);
}

void bi_copy_bytes(BI dst, BI src)
{
	// calculation
	if(dst != src)
	{
		memcpy(dst->basePt, src->basePt, MAX_BYTES);
		dst->length = src->length;
	}
}

int bi_bits(BI a)
{
	// calculation
	int i=1-a->length, j=0;
	while(i<=0 && a->first[i]==0){i++;}
	if(i>0)
	{
		return 0;
	}
	for(j=7;j>=0 ;j--)
	{
		if(a->first[i] & (1<<j)) break;
	}
	return ((-i)<<3)+j+1;
}
 
int bi_comp(BI a, BI b)
{
	// calculation
	int i=0;
	int length = getMaxSize(a, b);
	for(i=1-length;i<=0;i++)
	{
		if(a->first[i]>b->first[i]) return 1;
		else if(a->first[i]<b->first[i]) return -1;
	}
	return 0;
}

void bi_lshift(BI a, int bits, int bw)
{
	// shift operation
	int i=0, j=0;
	int byteOff = -bits/8, bitOff = bits%8;
	unsigned char* ap = a->first;
	ap[byteOff-a->length] = 0;
	for(i=byteOff-a->length;i<byteOff;i++)
	{
		ap[i] = (255&(ap[i-byteOff]<<bitOff)) + (ap[i-byteOff+1]>>(8-bitOff));
	}
	ap[byteOff] = 255&(ap[i-byteOff]<<bitOff);
	ap[0] |= bw;

	a->length = a->length+byteOff + (a->first[byteOff - a->length]>0?1:0);
}