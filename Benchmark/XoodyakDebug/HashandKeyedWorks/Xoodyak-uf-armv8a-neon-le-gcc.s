.text

.equ Xoodyak_Rkin   , 44
.equ Xoodyak_Rkout  , 24
.equ Xoodyak_Rhash  , 16

/* ----------------------------------------------------------------------------*/
.text
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
    ld1     {v9.2s}, [x7], #8                         //Iota      
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


/* ---------------------------------------------------------------------------- */
/*  Xoodoo_Permute_12roundsAsm: only callable from asm*/
.align 8
.type	Xoodoo_Permute_12roundsAsm, %function;
Xoodoo_Permute_12roundsAsm:
    adr         x7, _rc12                         
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
    .quad          0x0000000000000060
    .quad          0x000000000000002C
    .quad          0x0000000000000380
    .quad          0x00000000000000F0
    .quad          0x00000000000001A0
    .quad          0x0000000000000012

/* ----------------------------------------------------------------------------
size_t Xoodyak_AbsorbKeyedFullBlocks(void *state, const uint8_t *X, size_t XLen)
*/

.global Xoodyak_AbsorbKeyedFullBlocks
.type   Xoodyak_AbsorbKeyedFullBlocks, %function;
Xoodyak_AbsorbKeyedFullBlocks:
    stp          x29, x30, [sp,#-16]!
    ins          v13.d[1], v12.d[0]  
    ins          v13.d[0], v12.d[1]
    movi         v13.2s, #1 
    ins          v12.d[1], v13.d[0]                
    ins          v12.d[0], v13.d[1]  
    mov          x3, x1                                
    mov          x4, x1                               
    ld1          {v0.16b - v2.16b}, [x0], #48  
    ld1          {v3.16b - v5.16b}, [x0], #48
    ld1          {v6.16b - v8.16b}, [x0]
    sub          x0, x0, #96                     
    subs         x2, x2, #Xoodyak_Rkin
Xoodyak_AbsorbKeyedFullBlocks_Loop:
    bl           Xoodoo_Permute_12roundsAsm
    ld1          {v14.16b,v15.16b}, [x3], #32  
    ins          v13.d[0], v12.d[1]          
    ld1          {v12.2s}, [x3],#8  
    ins          v12.d[1], v13.d[0]    
    ld1          {v12.s}[2], [x3], #4   
    eor          v0.16b, v0.16b, v14.16b                
    eor          v1.16b, v1.16b, v15.16b
    eor          v2.16b, v2.16b, v12.16b                
    subs         x2, x2, #Xoodyak_Rkin
    bcs          Xoodyak_AbsorbKeyedFullBlocks_Loop
    st1          {v0.16b - v2.16b}, [x0], #48
    st1          {v3.16b - v5.16b}, [x0], #48
    st1          {v6.16b - v8.16b}, [x0]
    sub          x0, x0, #96               
    sub          x0, x3, x4
    ldp          x29, x30, [sp],#16              
    ret                                               
    .align  8


/* ----------------------------------------------------------------------------
size_t Xoodyak_AbsorbHashFullBlocks(void *state, const uint8_t *X, size_t XLen)
*/

.global Xoodyak_AbsorbHashFullBlocks
.type   Xoodyak_AbsorbHashFullBlocks, %function;
Xoodyak_AbsorbHashFullBlocks:
    stp          x29, x30, [sp,#-16]!
    mov          x3, x1                              
    movi         v15.2s, #1                             
    ushr         d15, d15, #32                    
    mov          x4, x1                                 
    ld1          {v0.16b - v2.16b}, [x0], #48  
    ld1          {v3.16b - v5.16b}, [x0], #48
    ld1          {v6.16b - v8.16b}, [x0]
    sub          x0, x0, #96                 
    subs         x2, x2, #Xoodyak_Rhash
Xoodyak_AbsorbHashFullBlocks_Loop:
    bl           Xoodoo_Permute_12roundsAsm
    ld1          {v14.16b}, [x3], #16 
    ins          v13.d[1], v1.d[1]  
    eor          v1.8b, v1.8b, v15.8b                 
    ins          v1.d[1],v13.d[1]                   
    eor          v0.16b, v0.16b, v14.16b
    subs         x2, x2, #Xoodyak_Rhash
    bcs          Xoodyak_AbsorbHashFullBlocks_Loop
    st1          {v0.16b - v2.16b}, [x0], #48
    st1          {v3.16b - v5.16b}, [x0], #48
    st1          {v6.16b - v8.16b}, [x0]
    sub          x0, x0, #96                  
    sub          x0, x3, x4
    ldp          x29, x30, [sp],#16  
    ret                                                
    .align  8




/* ----------------------------------------------------------------------------
size_t Xoodyak_SqueezeKeyedFullBlocks(void *state, uint8_t *Y, size_t YLen)
*/

.global Xoodyak_SqueezeKeyedFullBlocks
.type   Xoodyak_SqueezeKeyedFullBlocks, %function;
Xoodyak_SqueezeKeyedFullBlocks:
    stp          x29, x30, [sp,#-16]! 
    movi         v12.2s, #1
    ushr         d12, d12, #32                    
    mov          x3, x1                                
    mov          x4, x1                                
    ld1          {v0.16b - v2.16b}, [x0], #48  
    ld1          {v3.16b - v5.16b}, [x0], #48
    ld1          {v6.16b - v8.16b}, [x0]
    sub          x0, x0, #96                  
    subs         x2, x2, #Xoodyak_Rkout
Xoodyak_SqueezeKeyedFullBlocks_Loop:
    ins          v13.d[1], v0.d[1]       
    eor          v0.8b, v0.8b, v12.8b                 
    ins          v0.d[1],v13.d[1]                
    bl           Xoodoo_Permute_12roundsAsm
    eor          v13.16b, v0.16b, v3.16b
    eor          v13.16b, v13.16b, v6.16b
    eor          v14.16b, v1.16b, v4.16b
    eor          v14.16b, v14.16b, v7.16b
    //eor          v15.16b, v2.16b, v5.16b
    //eor          v15.16b, v15.16b, v8.16b
    st1          {v13.16b}, [x3], #16
    st1          {v14.2s}, [x3], #8                     
    subs         x2, x2, #Xoodyak_Rkout
    bcs          Xoodyak_SqueezeKeyedFullBlocks_Loop
    st1          {v0.16b - v2.16b}, [x0], #48
    st1          {v3.16b - v5.16b}, [x0], #48
    st1          {v6.16b - v8.16b}, [x0]
    sub          x0, x0, #96              
    sub          x0, x3, x4
    ldp          x29, x30, [sp],#16  
    ret                                               
    .align  8



/* ----------------------------------------------------------------------------
size_t Xoodyak_SqueezeHashFullBlocks(void *state, uint8_t *Y, size_t YLen)
*/

.global Xoodyak_SqueezeHashFullBlocks
.type   Xoodyak_SqueezeHashFullBlocks, %function;
Xoodyak_SqueezeHashFullBlocks:
    stp          x29, x30, [sp,#-16]!
    movi         v12.2s, #1
    ushr         d12, d12, #32
    mov          x3, x1
    mov          x4, x1
    ld1          {v0.16b - v2.16b}, [x0], #48  
    ld1          {v3.16b - v5.16b}, [x0], #48
    ld1          {v6.16b - v8.16b}, [x0]
    sub          x0, x0, #96           
    subs         x2, x2, #Xoodyak_Rhash   //i have changed x2 to r2 but did not compile it.
Xoodyak_SqueezeHashFullBlocks_Loop:
    ins          v13.d[1],v0.d[1]
    eor          v0.8b, v0.8b, v12.8b           
    ins          v0.d[1],v13.d[1]    
    bl           Xoodoo_Permute_12roundsAsm
    eor          v13.16b, v0.16b, v3.16b
    eor          v13.16b, v13.16b, v6.16b
    //eor          v14.16b, v1.16b, v4.16b
    //eor          v14.16b, v14.16b, v7.16b
    //eor          v15.16b, v2.16b, v5.16b
    //eor          v15.16b, v15.16b, v8.16b
    st1          {v13.16b}, [x3], #16    
    subs         x2, x2, #Xoodyak_Rkout    //i have changed x2 to r2 but did not compile it.
    bcs          Xoodyak_SqueezeHashFullBlocks_Loop
    st1          {v0.16b - v2.16b}, [x0], #48
    st1          {v3.16b - v5.16b}, [x0], #48
    st1          {v6.16b - v8.16b}, [x0]
    sub          x0, x0, #96
    sub          x0, x3, x4
    ldp          x29, x30, [sp],#16    
    ret                                        
    .align  8
    
    

/* ----------------------------------------------------------------------------
size_t Xoodyak_EncryptFullBlocks(void *state, const uint8_t *I, uint8_t *O,size_t IOLen)
*/

.global Xoodyak_EncryptFullBlocks
.type   Xoodyak_EncryptFullBlocks, %function;
Xoodyak_EncryptFullBlocks:
    stp          x29, x30, [sp,#-16]! 
    mov          x4, x1                 
    movi         v15.2s, #1 
    ushr         d15, d15, #32
    ins          v13.d[1], v15.d[0] 
    movi         v15.2d, #0x0                       
    ins          v15.d[1], v13.d[1]              
    mov          x5, x1                        
    ld1          {v0.16b - v2.16b}, [x0], #48  
    ld1          {v3.16b - v5.16b}, [x0], #48
    ld1          {v6.16b - v8.16b}, [x0]
    sub          x0, x0, #96           
    subs         x3, x3, #Xoodyak_Rkout
Xoodyak_EncryptFullBlocks_Loop:
    bl           Xoodoo_Permute_12roundsAsm
    ld1          {v14.16b}, [x4], #16 
    ins          v13.d[0], v15.d[1]          
    ld1          {v15.2s}, [x4],#8  
    ins          v15.d[1], v13.d[0]
    
    eor          v0.16b, v0.16b, v14.16b
    eor          v1.16b, v1.16b, v15.16b
    
    eor          v12.16b, v0.16b, v3.16b
    eor          v12.16b, v12.16b, v6.16b
    
    st1          {v12.16b}, [x2], #16           
    subs         x3, x3, #Xoodyak_Rkout

    eor          v12.16b, v1.16b, v4.16b
    eor          v12.16b, v12.16b, v7.16b    
    
    st1          {v12.8b}, [x2],#8              
    bcs          Xoodyak_EncryptFullBlocks_Loop
    
    st1          {v0.16b - v2.16b}, [x0] , #48 
    st1          {v3.16b - v5.16b}, [x0] , #48 
    st1          {v6.16b - v8.16b}, [x0] 
    sub          x0, x0, #96      
    sub          x0, x4, x5
    ldp          x29, x30, [sp],#16        
    ret                                        
    .align  8

/* ----------------------------------------------------------------------------
size_t Xoodyak_DecryptFullBlocks(void *state, const uint8_t *I, uint8_t *O,size_t IOLen)
*/

.global Xoodyak_DecryptFullBlocks
.type   Xoodyak_DecryptFullBlocks, %function;
Xoodyak_DecryptFullBlocks:
    stp          x29, x30, [sp,#-16]!
    mov          x4, x1      
    movi         v15.2s, #1 
    ushr         d15, d15, #32
    ins          v13.d[1], v15.d[0] 
    movi         v15.2d, #0x0                       
    ins          v15.d[1], v13.d[1]  
    mov          x5,x1
    ld1          {v0.16b - v2.16b}, [x0], #48  
    ld1          {v3.16b - v5.16b}, [x0], #48
    ld1          {v6.16b - v8.16b}, [x0]
    sub          x0, x0, #96   
    subs         x3, x3, #Xoodyak_Rkout         
Xoodyak_DecryptFullBlocks_Loop:
    bl           Xoodoo_Permute_12roundsAsm
    ld1          {v14.16b},[x4],#16                             
    ins          v13.d[0], v15.d[1]          
    ld1          {v15.2s}, [x4],#8  
    ins          v15.d[1], v13.d[0]
                     
    eor          v0.16b, v0.16b, v14.16b
    eor          v1.16b, v1.16b, v15.16b

    eor          v12.16b, v0.16b, v3.16b
    eor          v12.16b, v12.16b, v6.16b    
    
    st1          {v12.16b},[x2],#16  
    subs         x3, x3, #Xoodyak_Rkout      
    
    eor          v12.16b, v1.16b, v4.16b
    eor          v12.16b, v12.16b, v7.16b 
    
    st1          {v12.8b},[x2],#8  
          
    mov          v0.16b, v14.16b
    bcs          Xoodyak_DecryptFullBlocks_Loop
    
    ins          v13.d[1],v1.d[1]
    mov          v1.8b, v15.8b 
    ins          v1.d[1],v13.d[1]
    
    st1          {v0.16b - v2.16b}, [x0] , #48 
    st1          {v3.16b - v5.16b}, [x0] , #48 
    st1          {v6.16b - v8.16b}, [x0] 
    sub          x0, x0, #96    
        
    sub          x0, x4, x5
    ldp          x29, x30, [sp],#16               
    ret           
    .align  8
