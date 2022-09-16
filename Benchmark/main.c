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
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "testXooPerformance.h"

#define MEASURE_PERF

#if defined(EMBEDDED)

void assert(int condition)
{
    if (!condition)
    {
        for ( ; ; ) ;
    }
}
#endif

#if defined(EMBEDDED) && defined(__ARMCC_VERSION) && defined(MEASURE_PERF)
void CycleMeasureRestart( void );
uint32_t CycleMeasureGet( void );

struct
{
    uint32_t overhead;

    uint32_t Xoodoo_6;
    uint32_t Xoodoo_12;

} performanceInCycles;

#endif

int Xoo( void )
{
    #if !defined(EMBEDDED)
    testXooPerformance();
    #endif

    #if defined(EMBEDDED) && defined(__ARMCC_VERSION) && defined(MEASURE_PERF)
    {
        CycleMeasureRestart();
        performanceInCycles.overhead = CycleMeasureGet();

        {
            ALIGN(Xoodoo_stateAlignment)    uint8_t    state[Xoodoo_stateSizeInBytes];
            Xoodoo_StaticInitialize();
            Xoodoo_Initialize(state);

            CycleMeasureRestart();
            Xoodoo_Permute_6rounds(state);
            performanceInCycles.Xoodoo_6 = CycleMeasureGet();
            performanceInCycles.Xoodoo_6 -= performanceInCycles.overhead;

            CycleMeasureRestart();
            Xoodoo_Permute_12rounds(state);
            performanceInCycles.Xoodoo_12 = CycleMeasureGet();
            performanceInCycles.Xoodoo_12 -= performanceInCycles.overhead;
        }


    }
    #endif

    #if defined(EMBEDDED)

    for (;;);

    #else

    return ( 0 );

    #endif
}



int process(int argc, char* argv[])
{
    Xoo();
    return 0;
}

int main(int argc, char* argv[])
{
    return process(argc, argv);
}
