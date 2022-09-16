#include <assert.h>
#include <inttypes.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include "config.h"
#ifdef XKCP_has_NhNeon
#include "NhNeon.h"
#endif
#include "timing.h"
#include "testNhPerformance.h"
#define Many 10
typedef cycles_t (* measurePerf)(cycles_t, unsigned int);


#define xstr(s) str(s)
#define str(s) #s



#ifdef XKCP_has_NhNeon



static cycles_t measureNhNeon(cycles_t dtMin, unsigned int inputLen)
{
    
    ALIGN(64) uint8_t input[inputLen];
    ALIGN(64) uint8_t output[inputLen];
    ALIGN(64) uint8_t key[inputLen];


    //memset(key, 0xA582, sizeof(key)/2);
    //memset(input, 0xA5C3, sizeof(input)/2);
    memset(key, 0xA5, sizeof(key));
    memset(input, 0x3B, sizeof(input));
    {
        measureTimingBegin
	    NhNeon_Per(input, key, output, (size_t)inputLen);
        measureTimingEnd
    }
}


static void testNhPerfSlope( measurePerf pFunc, cycles_t calibration, uint32_t rateInBytes )
{
    uint32_t len;
    uint32_t count;
    cycles_t time;
    cycles_t time16;
    cycles_t time32;
    const uint32_t stabilityCount = 10;

    time16 = CYCLES_MAX;
    len = 1000*rateInBytes;
    count = stabilityCount;
    do {
        time = pFunc(calibration, len);
        if (time < time16) {
            time16 = time;
            count = stabilityCount;
        }
    } while( --count != 0);
    time32 = CYCLES_MAX;
    len = 2000*rateInBytes;
    count = stabilityCount;
    do {
        time = pFunc(calibration, len);
        if (time < time32) {
            time32 = time;
            count = stabilityCount;
        }
    } while( --count != 0);

    time = time32-time16;
    len = 1000*rateInBytes;
    printf("Slope %8d bytes (%u blocks): %9"PRId64" %s, %6.3f %s/byte\n", len, len/rateInBytes, time, getTimerUnit(), time*1.0/(len), getTimerUnit());
}


void testNhPerformanceOne( void )
{
    cycles_t calibration = CalibrateTimer();
    uint32_t len;
    cycles_t time;

    for(len=900; len <= 1000; len++) {
        time = measureNhNeon(calibration, 36*len);
        printf("%8d bytes: %9"PRId64" %s, %6.3f %s/byte\n", 36*len, time, getTimerUnit(), time*1.0/(36*len), getTimerUnit());
    }
    testNhPerfSlope(measureNhNeon, calibration, 36);
}
/*
void printNhPerformanceHeader( void )
{
    printf("*** Nh Neon ***\n");
    printf("\n");
}*/

void testNhNeonPerformance(void)
{
    //printNhPerformanceHeader();
    testNhPerformanceOne();
}
#endif

void testNhPerformance(void)
{

#ifdef XKCP_has_NhNeon
    testNhNeonPerformance();
#endif
}
