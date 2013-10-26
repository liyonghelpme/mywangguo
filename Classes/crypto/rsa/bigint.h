/**
 * Copyright (c) 2009 Koder Chen. All Rights Reserved.
 *
 * bigint.h
 * The file declares the basic operations needed to manipulate the big integer,
 * including the add, minus, multiply, and so, on
 *
 *  Author: chenfuhan
 * Created: 2009-6-1
 * Version: 1.0
 */
#ifndef __RSA_BIGINT_H__
#define __RSA_BIGINT_H__

// the big int struct
struct BIGINT{
	unsigned char* basePt;
	unsigned char* first;
	int length;
};

typedef struct BIGINT* BI;

/**
 * used to add two big integer together.
 *
 * @param a the first addend
 * @param b the augend
 * @param out the output holder
 */
void bi_add(BI a, BI b, BI out);

/**
 * used to subtract b from a, who are all bigintegters
 *
 * @param a the minuend
 * @param b the subtrahend
 * @param out the output holder
 */
void bi_sub(BI a, BI b, BI out);

/**
 * used to multiply a and b, who are all bigintegters
 *
 * @param a the faciend
 * @param b the multiplier
 * @param out the output holder
 */
void bi_mul(BI a, BI b, BI out);

/**
 * used to divide b from a, who are all bigintegters
 *
 * @param a the dividend
 * @param b the divisor
 * @param quot the quotient output holder
 * @param rema the remainder holder
 */
void bi_div(BI a, BI b, BI quot, BI rema);

/**
 * used to get the modules of a to b.
 *
 * @param a the passed in integer
 * @param b the the module basic
 * @param out the output holder
 */
void bi_mod(BI a, BI b, BI out);

/**
 * used to calculate the module of a^b to n.
 *
 * @param a the basic of the power
 * @param b the power
 * @param n the module basic
 * @param out the output holder
 */
void bi_powm(BI a, BI b, BI n, BI out);

/**
 * used to calculate the gcd of a and b
 *
 * @param a the first integer
 * @param b the second integer
 * @param out the output holder
 */
void bi_gcd(BI a, BI b, BI out);

/**
 * used to left shift n-bits of the integer
 *
 * @param a the integer to be shifted
 * @param bits the number of bits to shift the interger
 * @param bw 1 or 0
 */
void bi_lshift(BI a, int bits, int bw);

/**
 * used to compare two big integers
 *
 * @param a first integer to be compared
 * @param b second integer to be compared
 * @return 0 if the two are equal, or -1 if a<b, or 1 if a>b
 */
 int bi_comp(BI a, BI b);
 
 /**
  * used to copy all bytes from 'src' to 'dst'. IN FACT This is a "set value", operator "="
  *
  * @param dst the destination of the copy action. i.e. where do the bytes will be copied
  *            to
  * @param src the source of the bytes, i.e. where do the bytes come from
  * @param start the start point of the copy action for the source
  * @param bytes the number of bytes to be copied
  */
 void bi_copy_bytes(BI dst, BI src);
 
 /**
  * used to copy bits from "src" to "dst".
  */
 void bi_copy_bits(BI dst, BI src, int begin, int bits);

 /**
  * used to fetch the valid number of bits of big integer a
  *
  * @param a the big integer to be checked
  * @return the number of bits
  */
 int bi_bits(BI a);

 BI bi_malloc_default();

 void bi_load_data(BI a, unsigned char* data, int length);

 void bi_free(BI a);
 
#endif // __RSA_BIGINT_H__
