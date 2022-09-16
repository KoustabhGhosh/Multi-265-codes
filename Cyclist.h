#ifndef _Cyclist_h_
#define _Cyclist_h_

#include <stdint.h>
#include "align.h"


#define KCP_DeclareCyclistFunctions(prefix) \
    void prefix##_Per(const uint8_t *input, const uint8_t *key, const uint8_t *output, size_t inputLen);
#endif
