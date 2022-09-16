/*
The eXtended Keccak Code Package (XKCP)
https://github.com/XKCP/XKCP

Implementation by Gilles Van Assche and Ronny Van Keer, hereby denoted as "the implementer".

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
#include "timing.h"
#include "testPerformance.h"

ALIGN_DEFAULT uint8_t bigBuffer1[BIG_BUFFER_SIZE];
ALIGN_DEFAULT uint8_t bigBuffer2[BIG_BUFFER_SIZE];

void displayMeasurements1101001000(cycles_t *measurements, uint32_t *laneCounts, unsigned int numberOfColumns, unsigned int laneLengthInBytes);

#define xstr(s) str(s)
#define str(s) #s


static void bubbleSort(double *list, unsigned int size)
{
    unsigned int n = size;

    do {
       unsigned int newn = 0;
       unsigned int i;

       for(i=1; i<n; i++) {
          if (list[i-1] > list[i]) {
              double temp = list[i-1];
              list[i-1] = list[i];
              list[i] = temp;
              newn = i;
          }
       }
       n = newn;
    }
    while(n > 0);
}

static double med4(double x0, double x1, double x2, double x3)
{
    double list[4];
    list[0] = x0;
    list[1] = x1;
    list[2] = x2;
    list[3] = x3;
    bubbleSort(list, 4);
    if (fabs(list[2]-list[0]) < fabs(list[3]-list[1]))
        return 0.25*list[0]+0.375*list[1]+0.25*list[2]+0.125*list[3];
    else
        return 0.125*list[0]+0.25*list[1]+0.375*list[2]+0.25*list[3];
}

void displayMeasurements1101001000(cycles_t *measurements, uint32_t *laneCounts, unsigned int numberOfColumns, unsigned int laneLengthInBytes)
{
    double cpb[4];
    unsigned int i;

    for(i=0; i<numberOfColumns; i++) {
        uint32_t bytes = laneCounts[i]*laneLengthInBytes;
        double x = med4(measurements[i*4+0]*1.0, measurements[i*4+1]/10.0, measurements[i*4+2]/100.0, measurements[i*4+3]/1000.0);
        cpb[i] = x/bytes;
    }
    if (numberOfColumns == 1) {
        printf("     laneCount:  %5u\n", laneCounts[0]);
        printf("       1 block:  %5"PRId64"\n", measurements[0]);
        printf("      10 blocks: %6"PRId64"\n", measurements[1]);
        printf("     100 blocks: %7"PRId64"\n", measurements[2]);
        printf("    1000 blocks: %8"PRId64"\n", measurements[3]);
        printf("    %s/byte: %7.2f\n", getTimerUnit(), cpb[0]);
    }
    else if (numberOfColumns == 2) {
        printf("     laneCount:  %5u       %5u\n", laneCounts[0], laneCounts[1]);
        printf("       1 block:  %5"PRId64"       %5"PRId64"\n", measurements[0], measurements[4]);
        printf("      10 blocks: %6"PRId64"      %6"PRId64"\n", measurements[1], measurements[5]);
        printf("     100 blocks: %7"PRId64"     %7"PRId64"\n", measurements[2], measurements[6]);
        printf("    1000 blocks: %8"PRId64"    %8"PRId64"\n", measurements[3], measurements[7]);
        printf("    %s/byte: %7.2f     %7.2f\n", getTimerUnit(), cpb[0], cpb[1]);
    }
    else if (numberOfColumns == 3) {
        printf("     laneCount:  %5u       %5u       %5u\n", laneCounts[0], laneCounts[1], laneCounts[2]);
        printf("       1 block:  %5"PRId64"       %5"PRId64"       %5"PRId64"\n", measurements[0], measurements[4], measurements[8]);
        printf("      10 blocks: %6"PRId64"      %6"PRId64"      %6"PRId64"\n", measurements[1], measurements[5], measurements[9]);
        printf("     100 blocks: %7"PRId64"     %7"PRId64"     %7"PRId64"\n", measurements[2], measurements[6], measurements[10]);
        printf("    1000 blocks: %8"PRId64"    %8"PRId64"    %8"PRId64"\n", measurements[3], measurements[7], measurements[11]);
        printf("    %s/byte: %7.2f     %7.2f     %7.2f\n", getTimerUnit(), cpb[0], cpb[1], cpb[2]);
    }
    else if (numberOfColumns == 4) {
        printf("     laneCount:  %5u       %5u       %5u       %5u\n", laneCounts[0], laneCounts[1], laneCounts[2], laneCounts[3]);
        printf("       1 block:  %5"PRId64"       %5"PRId64"       %5"PRId64"       %5"PRId64"\n", measurements[0], measurements[4], measurements[8], measurements[12]);
        printf("      10 blocks: %6"PRId64"      %6"PRId64"      %6"PRId64"      %6"PRId64"\n", measurements[1], measurements[5], measurements[9], measurements[13]);
        printf("     100 blocks: %7"PRId64"     %7"PRId64"     %7"PRId64"     %7"PRId64"\n", measurements[2], measurements[6], measurements[10], measurements[14]);
        printf("    1000 blocks: %8"PRId64"    %8"PRId64"    %8"PRId64"    %8"PRId64"\n", measurements[3], measurements[7], measurements[11], measurements[15]);
        printf("    %s/byte: %7.2f     %7.2f     %7.2f     %7.2f\n", getTimerUnit(), cpb[0], cpb[1], cpb[2], cpb[3]);
    }
    printf("\n");
}
