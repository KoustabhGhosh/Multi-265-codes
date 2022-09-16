.text

.equ Xoodyak_Rkin   , 44
.equ Xoodyak_Rkout  , 24
.equ Xoodyak_Rhash  , 16

.macro    mRound

    // Theta: Column Parity Mixer
    eor     v4.16b, v0.16b, v1.16b
    eor     v4.16b, v4.16b, v2.16b
    ext     v4.16b, v4.16b, v4.16b, #3
    shl     v3.4s, v4.4s, #5 
    sri      v3.4s, v4.4s, #32-5
    shl     v5.4s, v4.4s, #14
    sri      v5.4s, v4.4s, #32-14 
    eor     v3.16b, v3.16b, v5.16b
    eor     v0.16b, v0.16b, v3.16b
    eor     v1.16b, v1.16b, v3.16b 
    eor     v5.16b, v2.16b, v3.16b         // q2 resides in q5

    /* Rho-west: Plane shift
     Iota: add round constant */ 
    shl    v2.4s, v5.4s, #11
    ext    v1.16b, v1.16b, v1.16b, #3
    ldr     d6, [x1], #32             
    sri     v2.4s, v5.4s, #32-11
    eor    v0.8b, v0.8b, v6.8b       

    /* Chi: non linear step, on colums */ 
    bic     v3.16b, v2.16b, v1.16b          
    bic     v4.16b, v0.16b, v2.16b          
    bic     v5.16b, v1.16b, v0.16b          
    eor     v0.16b, v0.16b, v3.16b         
    eor     v4.16b, v1.16b, v4.16b          
    eor     v2.16b, v2.16b, v5.16b          

    /* Rho-east: Plane shift */
    ext     v5.16b, v2.16b, v2.16b, #2
    shl     v1.4s, v4.4s, #1 
    shl     v2.4s, v5.4s, #8 
    sri     v1.4s, v4.4s, #32-1 
    sri     v2.4s, v5.4s, #32-8 
    .endm

/* ---------------------------------------------------------------------------- */
/*  void Xoodoo_Permute_12rounds( void *state ) */

.global Xoodoo_Permute_12rounds
.type	Xoodoo_Permute_12rounds, %function;
Xoodoo_Permute_12rounds:
    st1     {v4.16b - v5.16b}, [sp]             /*vpush       {q4-q5}*/
    ld1     {v0.16b - v2.16b}, [X0]             /*vldmia      r0, {q0-q2}*/
    adr         x1, _rc12                     /* put address of _rc12 to r1*/
    mRound
    mRound 	
    mRound
    mRound
    mRound
    mRound
    mRound
    mRound
    mRound
    mRound
    mRound
    mRound
    st1     {v0.16b - v2.16b}, [x0]             /*vstmia      r0, {q0-q2}*/
    ld1     {v4.16b-v5.16b}, [sp]               /*vpop        {q4-q5}*/
    bx          lr
    .align  8




/* ----------------------------------------------------------------------------*/
/*
 size_t Xoodyak_AbsorbKeyedFullBlocks(void *state, const uint8_t *X, size_t XLen)
 {
     size_t  initialLength = XLen@

     do {
         SnP_Permute(state )@                      /* Xoodyak_Up(instance, NULL, 0, 0)@ */
         SnP_AddBytes(state, X, 0, Xoodyak_Rkin)@  /* Xoodyak_Down(instance, X, Xoodyak_Rkin, 0)@ */
         SnP_AddByte(state, 0x01, Xoodyak_Rkin)@
         X       += Xoodyak_Rkin@
         XLen    -= Xoodyak_Rkin@
     } while (XLen >= Xoodyak_Rkin)@

     return initialLength - XLen@
 }
*/

.global Xoodyak_AbsorbKeyedFullBlocks
Xoodyak_AbsorbKeyedFullBlocks:
    stp  x4, x30, [sp]           /*x30 is LR and this is equvalent to push    {r4,lr} */
    ld1           {v4.2d-v7.2d}[sp]
    movi        v13.1s, #1
    mov         w3, w1                      // r3 X
    mov         w4, w1                      // r4 initial X
    ld1           {v0.4s-v2.4s} [w0]   // get state  .... vldmia      r0, {q0-q2} 
    subs        w2, w2, #Xoodyak_Rkin
Xoodyak_AbsorbKeyedFullBlocks_Loop:
    bl          Xoodoo_Permute_12roundsAsm
    ld1     {v3.16b,v4.16b}, [w3], #64            // get X Xoodyak_Rkin bytes   vld1.32     {q3,q4}, [r3]!
    ld1    {v12.2s}, [w3],#8           //vld1.32     {d12}, [r3]!
    vld1     {d13[0]}, [r3]!
    eor     v0.16b, v0.16b, v3.16b                       //veor.32     q0, q0, q3
    eor     v1.16b, v1.16b, v4.16b
    eor     v2.16b, v2.16b, v6.16b               //X + pad
    subs        w2, w2, #Xoodyak_Rkin
    bcs         Xoodyak_AbsorbKeyedFullBlocks_Loop
    st1     {v0.16b - v2.16b}, [x0]               // save state vstmia      r0, {q0-q2}
    sub         w0, w3, w4
    ld1     {v4.16b-v7.16b}, [sp]                 //vpop        {q4-q7}
    ldp     x4,pc,[sp]                                    //pop         {r4,pc}
    .align  8


/* ----------------------------------------------------------------------------*/
/*
 size_t Xoodyak_AbsorbHashFullBlocks(void *state, const uint8_t *X, size_t XLen)
 {
     size_t  initialLength = XLen@

     do {
         SnP_Permute(state )@                      /* Xoodyak_Up(instance, NULL, 0, 0)@ */
         SnP_AddBytes(state, X, 0, Xoodyak_Rhash)@ /* Xoodyak_Down(instance, X, Xoodyak_Rhash, 0)@ */
         SnP_AddByte(state, 0x01, Xoodyak_Rhash)@
         X       += Xoodyak_Rhash@
         XLen    -= Xoodyak_Rhash@
     } while (XLen >= Xoodyak_Rhash)@

     return initialLength - XLen@
}
*/
.global Xoodyak_AbsorbHashFullBlocks
Xoodyak_AbsorbHashFullBlocks:
    stp  x4, x30, [sp]           /*x30 is LR and this is equvalent to push    {r4,lr} */
    ld1           {v4.2d-v7.2d}[sp]                   //vpush       {q4-q7}   
    mov         w3, r1                                      // r3 X
    mov        v12.b[1], #1                   //vmov.i32    d12, #1
    shr           v12.1d, v12.1d, #8   //vshr.u64    d12, d12, #32
    mov         w4, w1                                    // r4 initial X
    ld1     {v0.16b - v2.16b}, [x0]               //  get state vldmia      r0, {q0-q2}
    subs        w2, w2, #Xoodyak_Rhash
Xoodyak_AbsorbHashFullBlocks_Loop:
    bl          Xoodoo_Permute_12roundsAsm
    ld1     {v3.16b}, [w3], #16                     //vld1.32     {q3}, [r3]!    get X Xoodyak_Rhash bytes
    eor     v2.1d, v2.1d, v12.1d
    eor     v0.16b, v0.16b, v3.16b
    subs        w2, w2, #Xoodyak_Rhash
    bcs         Xoodyak_AbsorbHashFullBlocks_Loop
    st1     {v0.16b - v2.16b}, [x0]   //vstmia      r0, {q0-q2}    save state
    sub         w0, w3, w4
    ld1     {v4.16b-v7.16b}, [sp]                 //vpop        {q4-q7}
    ldp     x4,pc,[sp]                                    //pop         {r4,pc}
    .align  8


/* ----------------------------------------------------------------------------*/
/*
 size_t Xoodyak_SqueezeKeyedFullBlocks(void *state, uint8_t *Y, size_t YLen)
 {
     size_t  initialLength = YLen@

     do {
         SnP_AddByte(state, 0x01, 0)@  /* Xoodyak_Down(instance, NULL, 0, 0)@ */
         SnP_Permute(state )@          /* Xoodyak_Up(instance, Y, Xoodyak_Rkout, 0)@ */
         SnP_ExtractBytes(state, Y, 0, Xoodyak_Rkout)@
         Y    += Xoodyak_Rkout@
         YLen -= Xoodyak_Rkout@
     } while (YLen >= Xoodyak_Rkout)@

     return initialLength - YLen@
 }
*/
.global Xoodyak_SqueezeKeyedFullBlocks
Xoodyak_SqueezeKeyedFullBlocks:
    stp  x4, x30, [sp]           /*x30 is LR and this is equvalent to push    {r4,lr} */
    ld1           {v4.2d-v7.2d}[sp]
    movi        v12.8b, 0x00000001                   //vmov.i32    d12, #1
    shr           v12.1d, v12.1d, #8    //vshr.u64    d12, d12, #32
    mov         w3, w1                        // r3 Y
    mov         w4, w1                        // r4 initial Y
    ld1     {v0.4s - v2.4s}, [x0]           /*vldmia      r0, {q0-q2}*/
    subs        w2, w2, #Xoodyak_Rkout
Xoodyak_SqueezeKeyedFullBlocks_Loop:
    eor           v0.8b, v0.8b, d12.8b                        // veor.32     d0, d0, d12
    bl          Xoodoo_Permute_12roundsAsm
    st1        v0.16b, [w3], #16                 //vst1.32     {q0}, [r3]!                   // save Y Xoodyak_Rkout bytes
    st1        v2.1d, [w3], #8                    //vst1.32     {d2}, [r3]!
    subs        w2, w2, #Xoodyak_Rkout
    bcs         Xoodyak_SqueezeKeyedFullBlocks_Loop
    st1     {v0.16b - v2.16b}, [x0]   //vstmia      r0, {q0-q2}    save state
    sub         w0, w3, w4
    ld1     {v4.16b-v7.16b}, [sp]                 //vpop        {q4-q7}
    ldp     x4,pc,[sp]                                    //pop         {r4,pc}
    .align  8


/* ----------------------------------------------------------------------------*/
/*
 size_t Xoodyak_SqueezeHashFullBlocks(void *state, uint8_t *Y, size_t YLen)
 {
     size_t  initialLength = YLen@

     do {
         SnP_AddByte(state, 0x01, 0)@  /* Xoodyak_Down(instance, NULL, 0, 0)@ */
         SnP_Permute(state)@           /* Xoodyak_Up(instance, Y, Xoodyak_Rhash, 0)@ */
         SnP_ExtractBytes(state, Y, 0, Xoodyak_Rhash)@
         Y    += Xoodyak_Rhash@
         YLen -= Xoodyak_Rhash@
     } while (YLen >= Xoodyak_Rhash)@

     return initialLength - YLen@
 }
*/
.global Xoodyak_SqueezeHashFullBlocks
Xoodyak_SqueezeHashFullBlocks:
    stp  x4, x30, [sp]                         /*x30 is LR and this is equvalent to push    {r4,lr} */
    ld1           {v4.2d-v7.2d}[sp]        //vpush       {q4-q7}
    movi        v12.8b, #1                   //vmov.i32    d12, #1
    shr           v12.1d, v12.1d, #8    //vshr.u64    d12, d12, #32
    mov         w3, w1                      // r3 Y
    mov         w4, w1                      // r4 initial Y
    ld1     {v0.4s - v2.4s}, [x0]           /*vldmia      r0, {q0-q2}*/
    subs        w2, w2, #Xoodyak_Rhash
Xoodyak_SqueezeHashFullBlocks_Loop:
    eor           v0.8b, v0.8b, d12.8b                        // veor.32     d0, d0, d12
    bl          Xoodoo_Permute_12roundsAsm
    st1        v0.16b, [w3], #16          // vst1.32     {q0}, [r3]!                @ save Y Xoodyak_Rhash bytes
    subs        w2, w2, #Xoodyak_Rhash
    bcs         Xoodyak_SqueezeHashFullBlocks_Loop
    st1     {v0.16b - v2.16b}, [x0]   //vstmia      r0, {q0-q2}    save state
    sub         w0, w3, w4
    ld1     {v4.16b-v7.16b}, [sp]                 //vpop        {q4-q7}
    ldp     x4,pc,[sp]                                    //pop         {r4,pc}
    .align  8


/* ----------------------------------------------------------------------------*/
/*
 size_t Xoodyak_EncryptFullBlocks(void *state, const uint8_t *I, uint8_t *O, size_t IOLen)
 {
     size_t  initialLength = IOLen@

     do {
         SnP_Permute(state)@
         SnP_ExtractAndAddBytes(state, I, O, 0, Xoodyak_Rkout)@
         SnP_OverwriteBytes(state, O, 0, Xoodyak_Rkout)@
         SnP_AddByte(state, 0x01, Xoodyak_Rkout)@
         I       += Xoodyak_Rkout@
         O       += Xoodyak_Rkout@
         IOLen   -= Xoodyak_Rkout@
     } while (IOLen >= Xoodyak_Rkout)@

     return initialLength - IOLen@
 }
*/
.global Xoodyak_EncryptFullBlocks
Xoodyak_EncryptFullBlocks:
    stp           {x4-x6}, x30, [sp]  //stp  x4, x30, [sp] : push {r4,lr} so maybe stp  {x4-x6}, x30, [sp] : push {r4-r6,lr}
    ld1           {v4.2d-v7.2d}[sp]        //vpush       {q4-q7}
    mov         w4, w1                        // r4 I
    movi        v13.8b, #1                   //vmov.i32    d13, #1
    shr           v13.1d, v13.1d, #32     //vshr.u64    d13, d13, #32
    mov         w5, w1                        // r5 initial I
    ld1     {v0.4s - v2.4s}, [x0]           //vldmia      r0, {q0-q2}  get state
    subs        w3, w3, #Xoodyak_Rkout
Xoodyak_EncryptFullBlocks_Loop:
    bl          Xoodoo_Permute_12roundsAsm
    ld1     {v3.16b}, [w4], #16                 // get input  ld1.32     {q3}, [r4]!                // get input
    ld1     {v12.8b}, [w4]!
    eor     v0.16b, v0.16b, v3.16b
    eor     v1.16b, v1.16b, v6.16b
    st1     {v0.16b}, [w2], #16                //vst1.32     {q0}, [r2]!
    subs        w3, w3, #Xoodyak_Rkout
    st1     {v2.8b}, [w2],#8                              //vst1.32     {d2}, [r2]!
    bcs         Xoodyak_EncryptFullBlocks_Loop
    vstmia      r0, {q0-q2}               // save state
    sub         w0, w4, w5
    ld1     {v4.16b-v7.16b}, [sp]                 //vpop        {q4-q7}
    ret                                                      //ldp     {x4-x6}, x30, [sp]//pop         {r4-r6,pc} or ret?
    //.align  8


/* ----------------------------------------------------------------------------*/
/*
 size_t Xoodyak_DecryptFullBlocks(void *state, const uint8_t *I, uint8_t *O, size_t IOLen)
 {
     size_t  initialLength = IOLen@

     do {
         SnP_Permute(state)@
         SnP_ExtractAndAddBytes(state, I, O, 0, Xoodyak_Rkout)@
         SnP_AddBytes(state, O, 0, Xoodyak_Rkout)@
         SnP_AddByte(state, 0x01, Xoodyak_Rkout)@
         I       += Xoodyak_Rkout@
         O       += Xoodyak_Rkout@
         IOLen   -= Xoodyak_Rkout@
     } while (IOLen >= Xoodyak_Rkout)@

     return initialLength - IOLen@
 }
*/
.global Xoodyak_DecryptFullBlocks
Xoodyak_DecryptFullBlocks:
    stp           {x4-x6}, x30, [sp]  //stp  x4, x30, [sp] : push {r4,lr} so maybe stp  {x4-x6}, x30, [sp] : push {r4-r6,lr}
    ld1           {v4.2d-v7.2d}[sp]        //vpush       {q4-q7}
    mov         w4, w1                      // r4 I
    movi        v13.8b, #1                   //vmov.i32    d13, #1
    mov         w5, w1                      // r5 initial I
    shr           v13.1d, v13.1d, #32     //vshr.u64    d13, d13, #32
    subs        w3, w3, #Xoodyak_Rkout
    ld1     {v0.4s - v2.4s}, [x0]           //vldmia      r0, {q0-q2}  get state
Xoodyak_DecryptFullBlocks_Loop:
    bl          Xoodoo_Permute_12roundsAsm
    ld1        {v3.16b},[w4],#16                       //vld1.32     {q3}, [r4]!                // get input
    ld1        {v12.8b},[w4],#8                    //vld1.32     {d12}, [r4]!
    eor     v0.16b, v0.16b, v3.16b
    eor     v1.16b, v1.16b, v6.16b
    st1      {v0.16b},[w2],#16         //vst1.32     {q0}, [r2]!
    st1      {v0.16b},[w2],#16        //vst1.32     {d2}, [r2]!
    mov        v0.16b, v3.16b
    subs        w3, w3, #Xoodyak_Rkout
    mov        v2.8b, v12.8b //vmov        d2, d12
    bcs         Xoodyak_DecryptFullBlocks_Loop
    ld1     {v0.4s - v2.4s}, [x0]           //vldmia      r0, {q0-q2}  get state
    sub         w0, w4, w5
    ld1     {v4.16b-v7.16b}, [sp]                 //vpop        {q4-q7}
    ret     //pop         {r4-r6,pc}
    .align  8


