/*#ifdef XoodooReference
    #include "displayIntermediateValues.h"
#endif

#if DEBUG
#include <assert.h>
#endif
*/
#include <string.h>
#include "NhNeon.h"
#include "Nh-SnP.h"

#define SnP     Nh
#define prefix   NhNeon
    #include "Cyclist.inc"


#undef  prefix
#undef  SnP
/*
#ifdef OUTPUT
#include <stdlib.h>
#include <string.h>

static void displayByteString(FILE *f, const char* synopsis, const uint8_t *data, unsigned int length);
static void displayByteString(FILE *f, const char* synopsis, const uint8_t *data, unsigned int length)
{
    unsigned int i;

    fprintf(f, "%s:", synopsis);
    for(i=0; i<length; i++)
        fprintf(f, " %02x", (unsigned int)data[i]);
    fprintf(f, "\n");
}
#endif
*/
//#define MyMin(a,b)  (((a) < (b)) ? (a) : (b))
/*
#ifdef XKCP_has_Xoodoo
    #include "Xoodoo-SnP.h"

    #define SnP                         Xoodoo
    #define SnP_Permute                 Xoodoo_Permute_12rounds
    #define prefix                      Xoodyak
        #include "Cyclist.inc"
    #undef  prefix
    #undef  SnP
    #undef  SnP_Permute
#endif
*/
