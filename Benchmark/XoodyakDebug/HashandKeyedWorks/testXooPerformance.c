/*
The eXtended Keccak Code Package (XKCP)
https://github.com/XKCP/XKCP

Implementation by Ronny Van Keer, hereby denoted as "the implementer".

For more information, feedback or questions, please refer to the Keccak Team website:
https://keccak.team/

To the extent possible under law, the implementer has waived all copyright
and related or neighboring rights to the source code in this file.
http://creativecommons.org/publicdomain/zero/1.0/
*/

#include <assert.h>
#include <inttypes.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include "config.h"
#ifdef XKCP_has_Xoodyak
#include "Xoodyak.h"
#endif
#include "timing.h"
#include "testPerformance.h"
#include "testXooPerformance.h"

typedef cycles_t (* measurePerf)(cycles_t, unsigned int);

void displayMeasurements1101001000(cycles_t *measurements, uint32_t *laneCounts, unsigned int numberOfColumns, unsigned int laneLengthInBytes);

#define xstr(s) str(s)
#define str(s) #s


#ifdef XKCP_has_Xoodoo
#include "Xoodoo-SnP.h"

    #define prefix Xoodoo
    #define SnP Xoodoo
    #define SnP_width 384
    #define SnP_Permute_6rounds  Xoodoo_Permute_6rounds
    #define SnP_Permute_12rounds Xoodoo_Permute_12rounds
        #include "timingXooSnP.inc"
    #undef prefix
    #undef SnP
    #undef SnP_width
    #undef SnP_Permute
    #undef SnP_Permute_12rounds
#endif


/* Xoodyak ------------------------------------------- */

#ifdef XKCP_has_Xoodyak

#define	Xoodyak_TagLength	16

static cycles_t measureXoodyak_MAC(cycles_t dtMin, unsigned int ADLen)
{
    ALIGN(64) uint8_t key[16];
    ALIGN(64) uint8_t AD[32*Xoodyak_Rkin];
    ALIGN(64) uint8_t tag[Xoodyak_TagLength];
    Xoodyak_Instance xd;

    assert(ADLen <= sizeof(AD));

    memset(key, 0xA5, sizeof(key));
    memset(AD, 0x5A, ADLen/8);
    Xoodyak_Initialize(&xd, key, sizeof(key), NULL, 0, NULL, 0);
    {
        measureTimingBegin
		Xoodyak_Absorb(&xd, AD, (size_t)ADLen);
	    Xoodyak_Squeeze(&xd, tag, Xoodyak_TagLength);
        printf("%02x",*((unsigned char*) &tag));
        measureTimingEnd
    }
}

static cycles_t measureXoodyak_Wrap(cycles_t dtMin, unsigned int inputLen)
{
    ALIGN(64) uint8_t input[32*Xoodyak_Rkout];
    ALIGN(64) uint8_t output[32*Xoodyak_Rkout];
    ALIGN(64) uint8_t key[16];
    ALIGN(64) uint8_t AD[16];
    ALIGN(64) uint8_t tag[Xoodyak_TagLength];
    Xoodyak_Instance xd;

    assert(inputLen <= sizeof(input));

    memset(key, 0xA5, sizeof(key));
    memset(input, 0xA5, sizeof(input));
    memset(AD, 0x5A, sizeof(AD));
    Xoodyak_Initialize(&xd, key, sizeof(key), NULL, 0, NULL, 0);
    {
        measureTimingBegin
		Xoodyak_Absorb(&xd, AD, sizeof(AD));
	    Xoodyak_Encrypt(&xd, input, output, (size_t)inputLen);
	    Xoodyak_Squeeze(&xd, tag, Xoodyak_TagLength);
        printf("%02x",*((unsigned char*) &tag));
        measureTimingEnd
    }
}

static cycles_t measureXoodyak_Hash(cycles_t dtMin, unsigned int messageLen)
{
    ALIGN(64) uint8_t message[32*Xoodyak_Rhash];
    ALIGN(64) uint8_t hash[32];
    Xoodyak_Instance xd;

    assert(messageLen <= sizeof(message));

    memset(message, 0xA5, sizeof(message));
    Xoodyak_Initialize(&xd, NULL, 0, NULL, 0, NULL, 0);
    {
        measureTimingBegin
		Xoodyak_Absorb(&xd, message, messageLen);
	    Xoodyak_Squeeze(&xd, hash, sizeof(hash));
        printf("%02x",*((unsigned char*) &hash));
        measureTimingEnd
    }
}

uint32_t testXoodyakNextLen(uint32_t len, uint32_t rateInBytes)
{
    if (len < rateInBytes) {
        len <<= 1;
        if (len > rateInBytes)
            len = rateInBytes;
    }
    else
        len <<= 1;
    return len;
}

uint32_t testXoodyakAdaptLen(uint32_t len, uint32_t rateInBytes)
{
    return (len < rateInBytes) ? len : (len-8);
}

static void testXoodyakPerfSlope( measurePerf pFunc, cycles_t calibration, uint32_t rateInBytes )
{
    uint32_t len;
    uint32_t count;
    cycles_t time;
    cycles_t time16;
    cycles_t time32;
    const uint32_t stabilityCount = 10;

    time16 = CYCLES_MAX;
    len = 16*rateInBytes;
    count = stabilityCount;
    do {
        time = pFunc(calibration, len);
        if (time < time16) {
            time16 = time;
            count = stabilityCount;
        }
    } while( --count != 0);
    time32 = CYCLES_MAX;
    len = 32*rateInBytes;
    count = stabilityCount;
    do {
        time = pFunc(calibration, len);
        if (time < time32) {
            time32 = time;
            count = stabilityCount;
        }
    } while( --count != 0);

    time = time32-time16;
    len = 16*rateInBytes;
    printf("Slope %8d bytes (%u blocks): %9"PRId64" %s, %6.3f %s/byte\n", len, len/rateInBytes, time, getTimerUnit(), time*1.0/len, getTimerUnit());
}

void testXoodyakPerformanceOne( void )
{
    cycles_t calibration = CalibrateTimer();
    uint32_t len;
    cycles_t time;

    /*
    printf("\nXoodyak Hash\n");
    for(len=1; len <= 32*Xoodyak_Rhash; len = testXoodyakNextLen(len, Xoodyak_Rhash)) {
        time = measureXoodyak_Hash(calibration, testXoodyakAdaptLen(len, Xoodyak_Rhash));
        printf("%8d bytes: %9"PRId64" %s, %6.3f %s/byte\n", testXoodyakAdaptLen(len, Xoodyak_Rhash), time, getTimerUnit(), time*1.0/len, getTimerUnit());
    }
    testXoodyakPerfSlope(measureXoodyak_Hash, calibration, Xoodyak_Rhash);
    */
    printf("\nXoodyak Wrap (plaintext + 16 bytes AD)\n");
        
    for(len=1; len <= 32*Xoodyak_Rkout; len = testXoodyakNextLen(len, Xoodyak_Rkout)) {
        time = measureXoodyak_Wrap(calibration, testXoodyakAdaptLen(len, Xoodyak_Rkout));
        printf("%8d bytes: %9"PRId64" %s, %6.3f %s/byte\n", testXoodyakAdaptLen(len, Xoodyak_Rkout), time, getTimerUnit(), time*1.0/len, getTimerUnit());
    }
    testXoodyakPerfSlope(measureXoodyak_Wrap, calibration, Xoodyak_Rkout);
    /*
    printf("\nXoodyak MAC (only AD)\n");
    for(len=1; len <= 32*Xoodyak_Rkin; len = testXoodyakNextLen(len, Xoodyak_Rkin)) {
        time = measureXoodyak_MAC(calibration, testXoodyakAdaptLen(len, Xoodyak_Rkin));
        printf("%8d bytes: %9"PRId64" %s, %6.3f %s/byte\n", testXoodyakAdaptLen(len, Xoodyak_Rkin), time, getTimerUnit(), time*1.0/len, getTimerUnit());
    }
    testXoodyakPerfSlope(measureXoodyak_MAC, calibration, Xoodyak_Rkin);
    */
}

void printXoodyakPerformanceHeader( void )
{
    printf("*** Xoodyak ***\n");
    printf("Using Xoodoo implementations:\n");
    printf("- \303\227\x31: " Xoodoo_implementation "\n");
    printf("\n");
}

void testXoodyakPerformance(void)
{
    printXoodyakPerformanceHeader();
    testXoodyakPerformanceOne();
}
#endif

void testXooPerformance(void)
{

//#ifdef XKCP_has_Xoodoo
//    Xoodoo_timingSnP("Xoodoo", Xoodoo_implementation);
//#endif

#ifdef XKCP_has_Xoodyak
    testXoodyakPerformance();
#endif
}
