#ifndef _NhNeon_h_
#define _NhNeon_h_

#include "config.h"
#ifdef XKCP_has_NhNeon

#include <stddef.h>
#include "Cyclist.h"
#include "Nh-SnP.h"

KCP_DeclareCyclistFunctions(NhNeon)


#else
#error This requires an implementation of Xoodoo
#endif

#endif
