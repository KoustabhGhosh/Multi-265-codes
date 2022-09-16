.text


    .align 8
.global Xoodoo_Initialize
.type	Xoodoo_Initialize, %function;
Xoodoo_Initialize:
    
    adds    x0,x0,#48
    ld1     {v3.2d,v4.2d,v5.2d}, [x0], #48
    ld1     {v6.2d,v7.2d,v8.2d}, [x0]
 
    eor     v0.16b, v3.16b, v6.16b
    eor     v1.16b, v4.16b, v7.16b
    eor     v2.16b, v5.16b, v8.16b
    
    subs    x0,x0,#96
	st1     {v0.2d,v1.2d,v2.2d}, [x0],#48            // if we want to move the pointer to the start of three shares we should add 3*48=144 to x0 that holds addresses for three shares
    add     x0,x0,#96
    
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
    adds    x4, x0, #48  
    adds    x5, x0, #96                            
    subs    w3, w3, #4                             
    bcc     Xoodoo_ExtractBytes_Bytes
Xoodoo_ExtractBytes_LanesLoop:                       
    ldr     w2, [x0], #4
    ldr     w6, [x4], #4
    ldr     w7, [x5], #4
    eor     w2, w2, w6
    eor     w2, w2, w7
    str     w2, [x1], #4
    subs    w3, w3, #4
    bcs     Xoodoo_ExtractBytes_LanesLoop
Xoodoo_ExtractBytes_Bytes:
    adds    w3, w3, #3
    bcc     Xoodoo_ExtractBytes_Exit
Xoodoo_ExtractBytes_BytesLoop:
    ldrb    w2, [x0], #1
    ldrb    w6, [x4], #1
    ldrb    w7, [x5], #1
    eor     w2, w2, w6
    eor     w2, w2, w7
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
    adds    x5, x0, #48  
    adds    x6, x0, #96
    subs    w3, w4, #4                                 
    bcc     Xoodoo_ExtractAndAddBytes_Bytes
Xoodoo_ExtractAndAddBytes_LanesLoop:                     
    ldr     w7, [x0], #4
    ldr     w4, [x1], #4
    eor     w7, w7, w4   //state+input
    ldr     w4, [x5], #4
    eor     w7, w7, w4
    ldr     w4, [x6], #4
    eor     w7, w7, w4
    str     w7, [x2], #4
    subs    w3, w3, #4
    bcs     Xoodoo_ExtractAndAddBytes_LanesLoop
Xoodoo_ExtractAndAddBytes_Bytes:
    adds    w3, w3, #3
    bcc     Xoodoo_ExtractAndAddBytes_Exit
Xoodoo_ExtractAndAddBytes_BytesLoop:
    ldrb    w7, [x0], #1
    ldrb    w4, [x1], #1
    eor     w7, w7, w4
    ldrb    w4, [x5], #1
    eor     w7, w7, w4
    ldrb    w4, [x6], #1
    eor     w7, w7, w4
    strb    w7, [x2], #1
    subs    w3, w3, #1
    bcs     Xoodoo_ExtractAndAddBytes_BytesLoop
Xoodoo_ExtractAndAddBytes_Exit:
    ret    
    .align  8
    
    


/* ---------------------------------------------------------------------------- */
.macro    mRound

    /* Theta: Column Parity Mixer */
    /* This is for the first share. v0 is A0, v1 is A1, and v3 is A2. */ 
    
    eor     v10.16b, v0.16b, v1.16b        
    eor     v10.16b, v10.16b, v2.16b        
    ext     v10.16b, v10.16b, v10.16b, #12   
    shl     v9.4s, v10.4s, #5              
    sri     v9.4s, v10.4s, #32-5           
    shl     v11.4s, v10.4s, #14             
    sri     v11.4s, v10.4s, #32-14          
    eor     v9.16b, v9.16b, v11.16b         
    eor     v0.16b, v0.16b, v9.16b         
    eor     v1.16b, v1.16b, v9.16b         
    eor     v11.16b, v2.16b, v9.16b 
    
    
    
    /* This is for the second share. v3 is B0, v4 is B1, and v5 is B2. */
    eor     v10.16b, v3.16b, v4.16b        
    eor     v10.16b, v10.16b, v5.16b        
    ext     v10.16b, v10.16b, v10.16b, #12   
    shl     v9.4s, v10.4s, #5              
    sri     v9.4s, v10.4s, #32-5           
    shl     v12.4s, v10.4s, #14             
    sri     v12.4s, v10.4s, #32-14          
    eor     v9.16b, v9.16b, v12.16b         
    eor     v3.16b, v3.16b, v9.16b         
    eor     v4.16b, v4.16b, v9.16b         
    eor     v12.16b, v5.16b, v9.16b 
    

    /* This is for the first share. v6 is C0, v7 is C1, and v8 is C2. */
    eor     v10.16b, v6.16b, v7.16b        
    eor     v10.16b, v10.16b, v8.16b        
    ext     v10.16b, v10.16b, v10.16b, #12   
    shl     v9.4s, v10.4s, #5              
    sri     v9.4s, v10.4s, #32-5           
    shl     v13.4s, v10.4s, #14             
    sri     v13.4s, v10.4s, #32-14          
    eor     v9.16b, v9.16b, v13.16b         
    eor     v6.16b, v6.16b, v9.16b         
    eor     v7.16b, v7.16b, v9.16b         
    eor     v13.16b, v8.16b, v9.16b 
    
    /* Rho-west: Plane shift , Iota: add round constant */        
    shl     v2.4s, v11.4s, #11              
    ext     v1.16b, v1.16b, v1.16b, #12      
    ld1     {v9.2s}, [x2], #8                         //Iota      
    sri     v2.4s, v11.4s, #32-11 
    ins     v10.d[1], v0.d[1]  			//Iota
    eor     v0.8b, v0.8b, v9.8b                       //Iota
    ins     v0.d[1],v10.d[1]  			//Iota


    /* Rho-west: Plane shift */        
    shl     v5.4s, v12.4s, #11              
    ext     v4.16b, v4.16b, v4.16b, #12      
    sri     v5.4s, v12.4s, #32-11 
    
    
    /* Rho-west: Plane shift */        
    shl     v8.4s, v13.4s, #11              
    ext     v7.16b, v7.16b, v7.16b, #12         
    sri     v8.4s, v13.4s, #32-11     



    /* Chi: non linear step, on colums */ 
    /* Part  1 */
    bic     v9.16b, v2.16b, v1.16b    		// ~a1a2
    bic     v10.16b, v5.16b, v1.16b			// ~a1b2
    bic     v11.16b, v2.16b, v4.16b			// ~b1a2
    eor     v10.16b, v10.16b, v11.16b		// ~a1b2+~b1a2
    eor     v10.16b, v10.16b, v9.16b		// ~a1b2+~b1a2+~a1a2
    eor     v0.16b, v0.16b, v10.16b			// a0= a0+~a1b2+~b1a2+~a1a2  now just v0-v8 are occupied
    
    bic     v9.16b, v5.16b, v4.16b    		// ~b1b2
    bic     v10.16b, v8.16b, v4.16b			// ~b1c2
    bic     v11.16b, v5.16b, v7.16b			// ~c1b2
    eor     v10.16b, v10.16b, v11.16b		// ~b1c2+~c1b2
    eor     v10.16b, v10.16b, v9.16b		// ~b1c2+~c1b2+~b1b2
    eor     v3.16b, v3.16b, v10.16b			// b0 = b0+~b1c2+~c1b2+~b1b2  now just v0-v8 are occupied
    
    bic     v9.16b, v8.16b, v7.16b    		// ~c1c2
    bic     v10.16b, v2.16b, v7.16b			// ~c1a2
    bic     v11.16b, v8.16b, v1.16b			// ~a1c2
    eor     v10.16b, v10.16b, v11.16b		// ~c1a2+~a1c2
    eor     v10.16b, v10.16b, v9.16b		// ~c1a2+~a1c2+~c1c2
    eor     v6.16b, v6.16b, v10.16b			// c0 = c0+~c1a2+~a1c2+~c1c2  now just v0-v8 are occupied
    
    
    /* Part  2 */
    bic     v9.16b, v0.16b, v2.16b    		// ~a2a0
    bic     v10.16b, v3.16b, v2.16b			// ~a2b0
    bic     v11.16b, v0.16b, v5.16b			// ~b2a0
    eor     v10.16b, v10.16b, v11.16b		// ~a2b0+~b2a0
    eor     v10.16b, v10.16b, v9.16b		// ~a2b0+~b2a0+~a2a0
    eor     v12.16b, v1.16b, v10.16b			// a1= a1+~a2b0+~b2a0+~a2a0  now just v0-v8 are occupied changed v1 to v12
    
    bic     v9.16b, v3.16b, v5.16b    		// ~b2b0
    bic     v10.16b, v6.16b, v5.16b			// ~b2c0
    bic     v11.16b, v3.16b, v8.16b			// ~c2b0
    eor     v10.16b, v10.16b, v11.16b		// ~b2c0+~c2b0
    eor     v10.16b, v10.16b, v9.16b		// ~b2c0+~c2b0+~b2b0
    eor     v13.16b, v4.16b, v10.16b			// b1 = b1+~b2c0+~c2b0+~b2b0  now just v0-v8 are occupied changed v4 to v13
    
    bic     v9.16b, v6.16b, v8.16b    		// ~c2c0
    bic     v10.16b, v0.16b, v8.16b			// ~c2a0
    bic     v11.16b, v6.16b, v2.16b			// ~a2c0
    eor     v10.16b, v10.16b, v11.16b		// ~c2a0+~a2c0
    eor     v10.16b, v10.16b, v9.16b		// ~c2a0+~a2c0+~c2c0
    eor     v14.16b, v7.16b, v10.16b			// c1 = c1+~c2a0+~a2c0+~c2c0  now just v0-v8 are occupied changed v7 to v14
    
    
    /* Part  3 */
    bic     v9.16b, v1.16b, v0.16b    		// ~a0a1
    bic     v10.16b, v4.16b, v0.16b			// ~a0b1
    bic     v11.16b, v1.16b, v3.16b			// ~b0a1
    eor     v10.16b, v10.16b, v11.16b		// ~a0b1+~b0a1
    eor     v10.16b, v10.16b, v9.16b		// ~a0b1+~b0a1+~a0a1
    eor     v2.16b, v2.16b, v10.16b			// a2= a2+~a0b1+~b0a1+~a0a1  now just v0-v8 are occupied
    
    bic     v9.16b, v4.16b, v3.16b    		// ~b0b1
    bic     v10.16b, v7.16b, v3.16b			// ~b0c1
    bic     v11.16b, v4.16b, v6.16b			// ~c0b1
    eor     v10.16b, v10.16b, v11.16b		// ~b0c1+~c0b1
    eor     v10.16b, v10.16b, v9.16b		// ~b0c1+~c0b1+~b0b1
    eor     v5.16b, v5.16b, v10.16b			// b2 = b2+~b0c1+~c0b1+~b0b1 now just v0-v8 are occupied
    
    bic     v9.16b, v7.16b, v6.16b    		// ~c0c1
    bic     v10.16b, v1.16b, v6.16b			// ~c0a1
    bic     v11.16b, v7.16b, v0.16b			// ~a0c1
    eor     v10.16b, v10.16b, v11.16b		// ~c0a1+~a0c1
    eor     v10.16b, v10.16b, v9.16b		// ~c0a1+~a0c1+~c0c1
    eor     v8.16b, v8.16b, v10.16b			// c2 = c2+~c0a1+~a0c1+~c0c1  now just v0-v8 are occupied
  

    /* Rho-east: Plane shift */
    ext     v11.16b, v2.16b, v2.16b, #8     
    shl     v1.4s, v12.4s, #1            
    shl     v2.4s, v11.4s, #8             
    sri     v1.4s, v12.4s, #32-1          
    sri     v2.4s, v11.4s, #32-8      
    
    ext     v11.16b, v5.16b, v5.16b, #8     
    shl     v4.4s, v13.4s, #1            
    shl     v5.4s, v11.4s, #8             
    sri     v4.4s, v13.4s, #32-1          
    sri     v5.4s, v11.4s, #32-8       
    
    ext     v11.16b, v8.16b, v8.16b, #8     
    shl     v7.4s, v14.4s, #1            
    shl     v8.4s, v11.4s, #8             
    sri     v7.4s, v14.4s, #32-1          
    sri     v8.4s, v11.4s, #32-8
      
    .endm



/* ----------------------------------------------------------------------------
void Xoodoo_Permute_6rounds( void *state )
*/
.global Xoodoo_Permute_6rounds
.type	Xoodoo_Permute_6rounds, %function;
Xoodoo_Permute_6rounds:

    ld1     {v0.16b - v2.16b}, [x0], #48  
    ld1     {v3.16b - v5.16b}, [x0], #48
    ld1     {v6.16b - v8.16b}, [x0]             
    adr         x2, _rc12  

    mRound
    mRound
    mRound
    mRound
    mRound
    mRound

    sub     x0, x0, #96
    st1     {v0.16b - v2.16b}, [x0], #48
    st1     {v3.16b - v5.16b}, [x0], #48
    st1     {v6.16b - v8.16b}, [x0]
    sub     x1, x1, #96
    
    eor     v0.16b, v3.16b, v0.16b
    eor     v0.16b, v6.16b, v0.16b
    eor     v1.16b, v4.16b, v1.16b
    eor     v1.16b, v7.16b, v1.16b
    eor     v2.16b, v5.16b, v2.16b
    eor     v2.16b, v8.16b, v2.16b
               
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
         
    ld1     {v0.16b - v2.16b}, [x0], #48  
    ld1     {v3.16b - v5.16b}, [x0], #48
    ld1     {v6.16b - v8.16b}, [x0]             
    adr         x2, _rc12  
                      
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
    
    sub     x0, x0, #96
    st1     {v0.16b - v2.16b}, [x0], #48
    st1     {v3.16b - v5.16b}, [x0], #48
    st1     {v6.16b - v8.16b}, [x0]
    sub     x0, x0, #96
    
    //eor     v0.16b, v3.16b, v0.16b
    //eor     v0.16b, v6.16b, v0.16b
    //eor     v1.16b, v4.16b, v1.16b
    //eor     v1.16b, v7.16b, v1.16b
    //eor     v2.16b, v5.16b, v2.16b
    //eor     v2.16b, v8.16b, v2.16b
           
    ret                                                     
    .align  8

