.text

/* ----------------------------------------------------------------------------
 void Xoodoo_Initialize(void *state)
*/
    .align 8
.global Xoodoo_Initialize
.type	Xoodoo_Initialize, %function;
Xoodoo_Initialize:
    movi    v0.2d, #0x0              
	st1     {v0.2d}, [x0],#16             
	st1     {v0.2d}, [x0],#16             
	st1     {v0.2d}, [x0],#16             
    ret
    .align  8


/*----------------------------------------------------------------------------
  void Xoodoo_AddBytes(void *state, const unsigned char *data, unsigned int offset, unsigned int length)
*/

.global Xoodoo_AddBytes
.type	Xoodoo_AddBytes, %function;
Xoodoo_AddBytes:           
    stp     x29, x30, [sp,#-16]!  
	adds    x0, x0, x2          
    subs    w3, w3, #4         
    bcc     Xoodoo_AddBytes_Bytes
Xoodoo_AddBytes_LanesLoop:                         
    ldr     w2, [x0]
    ldr     w4, [x1], #4
    eor     w2, w2, w4
    str     w2, [x0], #4
    subs    w3, w3, #4
    bcs     Xoodoo_AddBytes_LanesLoop
Xoodoo_AddBytes_Bytes:
    adds    w3, w3, #3
    bcc     Xoodoo_AddBytes_Exit
Xoodoo_AddBytes_BytesLoop:
    ldrb    w2, [x0]
    ldrb    w4, [x1], #1
    eor     w2, w2, w4
    strb    w2, [x0], #1
    subs    w3, w3, #1
    bcs     Xoodoo_AddBytes_BytesLoop
Xoodoo_AddBytes_Exit:
    ldp     x29, x30, [sp],#16
    ret
    .align  8


/*----------------------------------------------------------------------------
void Xoodoo_OverwriteBytes(void *state, const unsigned char *data, unsigned int offset, unsigned int length)
*/

.global Xoodoo_OverwriteBytes
.type	Xoodoo_OverwriteBytes, %function;
Xoodoo_OverwriteBytes:
    adds    x0, x0, x2                              
    subs    w3, w3, #4                              
    bcc     Xoodoo_OverwriteBytes_Bytes
Xoodoo_OverwriteBytes_LanesLoop:                     
    ldr     w2, [x1], #4
    str     w2, [x0], #4
    subs    w3, w3, #4
    bcs     Xoodoo_OverwriteBytes_LanesLoop
Xoodoo_OverwriteBytes_Bytes:
    adds    w3, w3, #3
    bcc     Xoodoo_OverwriteBytes_Exit
Xoodoo_OverwriteBytes_BytesLoop:
    ldrb    w2, [x1], #1
    strb    w2, [x0], #1
    subs    w3, w3, #1
    bcs     Xoodoo_OverwriteBytes_BytesLoop
Xoodoo_OverwriteBytes_Exit:
    ret    
    .align  8

/* ----------------------------------------------------------------------------
void Xoodoo_OverwriteWithZeroes(void *state, unsigned int byteCount)
*/

.global Xoodoo_OverwriteWithZeroes
.type	Xoodoo_OverwriteWithZeroes, %function;
Xoodoo_OverwriteWithZeroes:
    mov     x3, #0
    lsr     x2, x1, #2
    beq     Xoodoo_OverwriteWithZeroes_Bytes
Xoodoo_OverwriteWithZeroes_LoopLanes:
    str     w3, [x0], #4
    subs    w2, w2, #1
    bne     Xoodoo_OverwriteWithZeroes_LoopLanes
Xoodoo_OverwriteWithZeroes_Bytes:
    ands    w1,w1, #3
    beq     Xoodoo_OverwriteWithZeroes_Exit
Xoodoo_OverwriteWithZeroes_LoopBytes:
    strb    w3, [x0], #1
    subs    w1, w1, #1
    bne     Xoodoo_OverwriteWithZeroes_LoopBytes
Xoodoo_OverwriteWithZeroes_Exit:
    ret    
    .align  8
	
/* ----------------------------------------------------------------------------
void Xoodoo_ExtractBytes(void *state, const unsigned char *data, unsigned int offset, unsigned int length)
*/

.global Xoodoo_ExtractBytes
.type	Xoodoo_ExtractBytes, %function;
Xoodoo_ExtractBytes:
    adds    x0, x0, x2                              
    subs    w3, w3, #4                             
    bcc     Xoodoo_ExtractBytes_Bytes
Xoodoo_ExtractBytes_LanesLoop:                       
    ldr     w2, [x0], #4
    str     w2, [x1], #4
    subs    w3, w3, #4
    bcs     Xoodoo_ExtractBytes_LanesLoop
Xoodoo_ExtractBytes_Bytes:
    adds    w3, w3, #3
    bcc     Xoodoo_ExtractBytes_Exit
Xoodoo_ExtractBytes_BytesLoop:
    ldrb    w2, [x0], #1
    strb    w2, [x1], #1
    subs    w3, w3, #1
    bcs     Xoodoo_ExtractBytes_BytesLoop
Xoodoo_ExtractBytes_Exit:
    ret    
    .align  8

/* ----------------------------------------------------------------------------
void Xoodoo_ExtractAndAddBytes(void *state, const unsigned char *input, unsigned char *output, unsigned int offset, unsigned int length) 
*/

.global Xoodoo_ExtractAndAddBytes
.type	Xoodoo_ExtractAndAddBytes, %function;
Xoodoo_ExtractAndAddBytes:
    adds    x0, x0, x3                                  
    subs    w3, w4, #4                                 
    bcc     Xoodoo_ExtractAndAddBytes_Bytes
Xoodoo_ExtractAndAddBytes_LanesLoop:                     
    ldr     w7, [x0], #4
    ldr     w6, [x1], #4
    eor     w7, w7, w6
    str     w7, [x2], #4
    subs    w3, w3, #4
    bcs     Xoodoo_ExtractAndAddBytes_LanesLoop
Xoodoo_ExtractAndAddBytes_Bytes:
    adds    w3, w3, #3
    bcc     Xoodoo_ExtractAndAddBytes_Exit
Xoodoo_ExtractAndAddBytes_BytesLoop:
    ldrb    w7, [x0], #1
    ldrb    w6, [x1], #1
    eor     w7, w7, w6
    strb    w7, [x2], #1
    subs    w3, w3, #1
    bcs     Xoodoo_ExtractAndAddBytes_BytesLoop
Xoodoo_ExtractAndAddBytes_Exit:
    ret    
    .align  8

/* ---------------------------------------------------------------------------- */
.macro    mRound

    /* Theta: Column Parity Mixer */
    eor     v4.16b, v0.16b, v1.16b        
    eor     v4.16b, v4.16b, v2.16b        
    ext     v4.16b, v4.16b, v4.16b, #12   
    shl     v3.4s, v4.4s, #5              
    sri     v3.4s, v4.4s, #32-5           
    shl     v5.4s, v4.4s, #14             
    sri     v5.4s, v4.4s, #32-14          
    eor     v3.16b, v3.16b, v5.16b         
    eor     v0.16b, v0.16b, v3.16b         
    eor     v1.16b, v1.16b, v3.16b         
    eor     v5.16b, v2.16b, v3.16b         

    /* Rho-west: Plane shift , Iota: add round constant */        
    shl     v2.4s, v5.4s, #11              
    ext     v1.16b, v1.16b, v1.16b, #12      
    ld1     {v3.2s}, [x1], #8                     
    sri     v2.4s, v5.4s, #32-11 
    ins     v7.d[1], v0.d[1]  
    eor     v0.8b, v0.8b, v3.8b                 
    ins     v0.d[1],v7.d[1]  
                

    /* Chi: non linear step, on colums */ 
    bic     v3.16b, v2.16b, v1.16b          
    bic     v4.16b, v0.16b, v2.16b         
    bic     v5.16b, v1.16b, v0.16b          
    eor     v0.16b, v0.16b, v3.16b        
    eor     v4.16b, v1.16b, v4.16b          
    eor     v2.16b, v2.16b, v5.16b          

    /* Rho-east: Plane shift */
    ext     v5.16b, v2.16b, v2.16b, #8     
    shl     v1.4s, v4.4s, #1            
    shl     v2.4s, v5.4s, #8             
    sri     v1.4s, v4.4s, #32-1          
    sri     v2.4s, v5.4s, #32-8          
    .endm

/* ----------------------------------------------------------------------------
void Xoodoo_Permute_6rounds( void *state )
*/
.global Xoodoo_Permute_6rounds
.type	Xoodoo_Permute_6rounds, %function;
Xoodoo_Permute_6rounds:
    //stp     d8,d9, [sp, #-16]!            
    ld1     {v0.16b - v2.16b}, [x0]             
    adr         x1, _rc6
    mRound
    mRound
    mRound
    mRound
    mRound
    mRound
    st1     {v0.16b - v2.16b}, [x0]
    //ldp     d8,d9, [sp],#16               
    ret                                                         
    .ltorg
    .align  8
_rc12:
    .quad          0x0000000000000058              
    .quad          0x0000000000000038              
    .quad          0x00000000000003C0              
    .quad          0x00000000000000D0              
    .quad          0x0000000000000120
    .quad          0x0000000000000014
_rc6:
    .quad          0x0000000000000060
    .quad          0x000000000000002C
    .quad          0x0000000000000380
    .quad          0x00000000000000F0
    .quad          0x00000000000001A0
    .quad          0x0000000000000012

/* ---------------------------------------------------------------------------- 
  void Xoodoo_Permute_12rounds( void *state ) 
*/
.global Xoodoo_Permute_12rounds
.type	Xoodoo_Permute_12rounds, %function;
Xoodoo_Permute_12rounds:
    //stp     d8,d9, [sp ,#-16]!            
    ld1     {v0.16b - v2.16b}, [x0]             
    adr         x1, _rc12                    
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
    st1     {v0.16b - v2.16b}, [x0]             
    //ldp     d8,d9, [sp],#16           
    ret                                                     
    .align  8

