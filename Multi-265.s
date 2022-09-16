.text
.align 8
.global Nh_NHfield
.type	Nh_NHfield, %function;

Nh_NHfield:
	//push    {r4,r5}
	subs		r3, r3, #36
	bcc		    .Lloop3_done
	
.Lloop3Once:

	vld1.32		{q13,q14}, [r0]!			
	vld1.32 	{d30}, [r0]
	add			r0, r0, #4
	
	vld1.32		{q10,q11}, [r1]!		
	vld1.32		{d24}, [r1]					
	add			r1, r1, #4

	vmov.i32    q0	, #0
	vmov.i32    q1  , #0
    vmov.i32    q2  , #0
    vmov.i32    q6  , #0
    vmov.i32    q7  , #0	
	
	
    vshl.u64    d12, d26, #40			
    vext.8      d0, d12, d13, #5			
        
    vshl.u64    d12, d26, #16
    vshr.u64    d12, d12, #40
    vmov		s1, s24

	vshr.u64    d13, d26, #48
	vshl.u64	d12, d27, #56
	vshr.u64	d12, d12, #40
	vorr.u64	d13, d13, d12
	vmov		s2, s26
	   
    vshl.u64    d12,d27,#32
    vshr.u64    d12,d12,#40
    vmov        s3,s24
    
    
    vshl.u64    d12,d27,#8
    vshr.u64    d12,d12,#40
    vmov        s4,s24
    
    vshr.u64    d12,d27,#56
    vshl.u64    d13,d28,#48
    vshr.u64    d13,d13,#40
    veor.32     d13,d13,d12
    vmov        s5,s26
    
    vshl.u64    d12,d28,#24
    vshr.u64    d12,d12,#40
    vmov        s6,s24
    
    
    vshr.u64    d12,d28,#40
    vmov        s7,s24
    
    vshl.u64    d12,d29,#40
    vshr.u64    d12,d12,#40
    vmov		s8, s24
    
    vshl.u64    d12,d29,#16
    vshr.u64    d12,d12,#40
    vmov		s9, s24
    
    vshr.u64    d12,d29,#48
    vshl.u64	d13,d30,#56
    vshr.u64	d13,d13,#40
    veor.32     d12,d13,d12
    vmov		s10, s24
    
    vshl.u64	d12,d30,#32
    vshr.u64	d12,d12,#40
    vmov		s11, s24						// now q0 has X0,X1,X2,X3  q1 has X4,X5,Y0,Y1  q2 has Y2,Y3,Y4,Y5

    
    vmov.i32    q3	, #0
	vmov.i32    q4  , #0
    vmov.i32    q5  , #0
    vmov.i32    q6  , #0
    vmov.i32    q7  , #0
    
    vshl.u64    d12, d20, #40			
    vext.8      d6, d12, d13, #5			
        
    vshl.u64    d12, d20, #16
    vshr.u64    d12, d12, #40
    vmov		s13, s24

	vshr.u64    d13, d20, #48
	vshl.u64	d12, d21, #56
	vshr.u64	d12, d12, #40
	vorr.u64	d13, d13, d12
	vmov		s14, s26
	   
    vshl.u64    d12,d21,#32
    vshr.u64    d12,d12,#40
    vmov        s15,s24
    

    vshl.u64    d12,d21,#8
    vshr.u64    d12,d12,#40
    vmov        s16,s24
    
    vshr.u64    d12,d21,#56
    vshl.u64    d13,d22,#48
    vshr.u64    d13,d13,#40
    veor.32     d13,d13,d12
    vmov        s17,s26
    
    vshl.u64    d12,d22,#24
    vshr.u64    d12,d12,#40
    vmov        s18,s24
    
    
    vshr.u64    d12,d22,#40
    vmov        s19,s24
    
    vshl.u64    d12,d23,#40
    vshr.u64    d12,d12,#40
    vmov		s20, s24
    
    vshl.u64    d12,d23,#16
    vshr.u64    d12,d12,#40
    vmov		s21, s24
    
    vshr.u64    d12,d23,#48
    vshl.u64	d13,d24,#56
    vshr.u64	d13,d13,#40
    veor.32     d12,d13,d12
    vmov		s22, s24
    
    vshl.u64	d12,d24,#32
    vshr.u64	d12,d12,#40
    vmov		s23, s24						// now q3 has corresponding keys for X0,X1,X2,X3  q4 has corresponding keys X4,X5,Y0,Y1  q5 has corresponding keys Y2,Y3,Y4,Y5
    
    vadd.u32	q0, q0, q3   					// q0  contains X0,X1,X2,X3  corresponding keys added
	vadd.u32	q1, q1, q4   					// q1  contains X4,X5,Y0,Y1  corresponding keys added
	vadd.u32	q2, q2, q5   					// q2  contains Y2,Y3,Y4,Y5  corresponding keys added
	
    vmov		d12, d4
	vmov		d4, d2				
	vmov		d2, d1			
	vmov		d1, d3
	vmov		d3, d12							// q0 contains X0,X1,Y0,Y1 - q1 contains X2,X3,Y2,Y3 - q2 contains X4,X5,Y4,Y5
	
	
	vadd.u32	q10, q0, q1   					// q10 contains X0+X2,X1+X3,Y0+Y2,Y1+Y3  
	vadd.u32	q11, q0, q2   					// q11 contains X0+X4,X1+X5,Y0+Y4,Y1+Y5  
	vadd.u32	q12, q1, q2   					// q12 contains X2+X4,X3+X5,Y2+Y4,Y3+Y5  
	
	vrev64.32	q6, q0							// q6 contains X1,X0,Y1,Y0
	vadd.u32	q6, q6, q0						// q6 contains X0+X1,X0+X1,Y0+Y1,Y0+Y1
	
	vrev64.32	q7, q1							// q7 contains X3,X2,Y3,Y2
	vadd.u32	q7, q7, q1						// q7 contains X2+X3,X2+X3,Y2+Y3,Y2+Y3
	vmov		s25, s29						// q6 contains X0+X1,X2+X3,Y0+Y1,Y0+Y1
	vmov		s27, s31						// q6 contains X0+X1,X2+X3,Y0+Y1,Y2+Y3
	
	vrev64.32	q7, q2							// q7 contains X5,X4,Y5,Y4
	vadd.u32	q7, q7, q2						// q7 contains X4+X5,X4+X5,Y4+Y5,Y4+Y5
	
		
	vmov.u32	q3, #3	
	vmul.u32	q3, q12, q3						// q3 contains 3(X2+X4),3(X3+X5),3(Y2+Y4),3(Y3+Y5) 
	vmov		s16, s12						// q4 contains 3(X2+X4)(3q12.s0), sth, sth, sth  
	vmov		s18, s14						// q4 contains 3(X2+X4)(3q12.s0), sth, 3(Y2+Y4)(3q12.s2), sth  
	vrev64.32	q3, q3							// q3 contains 3(X3+X5),3(X2+X4),3(Y3+Y5),3(Y2+Y4)
	vadd.u32	q3, q3, q12						// q3 contains 3(X3+X5)+X2+X4,3(X2+X4)+X3+X5,3(Y3+Y5)+Y2+Y4,3(Y2+Y4)+Y3+Y5
	vrev64.32	q0, q0							// q0 contains X1,X0,Y1,Y0
	vadd.u32	q3, q3, q0						// q3 contains 3(X3+X5)+X2+X4+X1,3(X2+X4)+X3+X5+X0,3(Y3+Y5)+Y2+Y4+Y1,3(Y2+Y4)+Y3+Y5+Y0       2, sth, 7, sth
	
	vrev64.32	q1, q1							// q1 contains X3,X2,Y3,Y2
	vadd.u32	q4, q4, q6						// q4 contains 3(X2+X4)+X0+X1, sth, 3(Y2+Y4)+Y0+Y1, sth
	vadd.u32	q4, q4, q1						// q4 contains 3(X2+X4)+X0+X1+X3, sth, 3(Y2+Y4)+Y0+Y1+Y3, sth 								1, sth, 12, sth
	vmov		s17, s12						// q4 contains 3(X2+X4)+X0+X1+X3, 3(X3+X5)+X2+X4+X1, 3(Y2+Y4)+Y0+Y1+Y3, sth  1, 2, 12, sth
	vmov		s19, s14						// q4 contains 3(X2+X4)+X0+X1+X3, 3(X3+X5)+X2+X4+X1, 3(Y2+Y4)+Y0+Y1+Y3, 3(Y3+Y5)+Y2+Y4+Y1   1, 2, 12, 7 contains P0,P1,Q5,Q0
	
	
	vmov.u32	q3, #3
	vmul.u32	q3, q11, q3						// q8 contians 3(X0+X4),3(X1+X5),3(Y0+Y4),3(Y1+Y5) 
	vmov		s21, s12						// q5 contains sth, 3(X0+X4), sth, sth
	vmov		s23, s14						// q5 constains sth, 3(X0+X4), sth, 3(Y0+Y4)
	vrev64.32	q3, q3 							// q3 contians 3(X1+X5),3(X0+X4),3(Y1+Y5),3(Y0+Y4) 
	vadd.u32	q3, q3, q11						// q3 contians 3(X1+X5)+X0+X4,3(X0+X4)+X1+X5,3(Y1+Y5)+Y0+Y4,3(Y0+Y4)+Y1+Y5
	vadd.u32	q3, q3, q1						// q3 contians 3(X1+X5)+X0+X4+X3,3(X0+X4)+X1+X5+X2,3(Y1+Y5)+Y0+Y4+Y3,3(Y0+Y4)+Y1+Y5+Y2	    4, sth, 9, sth   
	
	vadd.u32	q6, q6, q2						// q6 contains X0+X1+X4,X2+X3+X5,Y0+Y1+Y4,Y2+Y3+Y5
	vadd.u32	q5, q5, q6						// q5 contains sth, 3(X0+X4)+X2+X3+X5, sth, 3(Y0+Y4)+Y2+Y3+Y5      sth, 3, sth, 8
	vmov		s20, s12		 				// q5 contains 3(X1+X5)+X0+X4+X3, 3(X0+X4)+X2+X3+X5, sth, 3(Y0+Y4)+Y2+Y3+Y5
	vmov		s22, s14						// q5 contains 3(X1+X5)+X0+X4+X3, 3(X0+X4)+X2+X3+X5, 3(Y1+Y5)+Y0+Y4+Y3, 3(Y0+Y4)+Y2+Y3+Y5	4, 3, 9, 8 contains P3,P2,Q2,Q1
	
	vmov.u32	q3, #3
	vmul.u32	q3, q10, q3						// q3 contains 3*(X0+X2),3*(X1+X3),3*(Y0+Y2),3*(Y1+Y3)
	vmov		s24, s12						// q6 contains 3*(X0+X2), sth, sth, sth
	vmov		s26, s14						// q6 contains 3*(X0+X2),sth,3*(Y0+Y2),sth
	vrev64.32	q3, q3							// q3 contains 3*(X1+X3),3*(X0+X2),3*(Y1+Y3),3*(Y0+Y2)
	vadd.u32	q3, q3, q10						// q3 contains 3*(X1+X3)+X0+X2,3*(X0+X2)+X1+X3,3*(Y1+Y3)+Y0+Y2,3*(Y0+Y2)+Y1+Y3 	
	vrev64.32	q2, q2							// q2 contains X5,X4,Y5,Y4
	vadd.u32	q3, q2, q3						// q3 contains 3*(X1+X3)+X0+X2+X5,3*(X0+X2)+X1+X3+X4,3*(Y1+Y3)+Y0+Y2+Y5,3*(Y0+Y2)+Y1+Y3+Y4    6, sth, 11, sth
	
											
	vadd.u32	q6, q6, q7						// q6 contains 3*(X0+X2)+X4+X5,sth,3*(Y0+Y2)+Y4+Y5,sth
	vadd.u32	q6, q0, q6						// q6 contains 3*(X0+X2)+X4+X5+X1,sth,3*(Y0+Y2)+Y4+Y5+Y1,sth	5, sth, 10, sth
	vmov		s25, s12						// q6 contains 5, sth, 10, sth
	vmov		s27, s14						// q6 contains 5, 6, 10, 11	contains P4,P5,Q3,Q4
	
	
	/*
	Now we have these: 
	q0 		X1,X0,Y1,Y0
	q1 		X3,X2,Y3,Y2
	q2 		X5,X4,Y5,Y4
	q10 	X0+X2,X1+X3,Y0+Y2,Y1+Y3 
	q11 	X0+X4,X1+X5,Y0+Y4,Y1+Y5 
	q12 	X2+X4,X3+X5,Y2+Y4,Y3+Y5 
	q4		P0,P1,Q5,Q0
	q5		P3,P2,Q2,Q1
	q6		P4,P5,Q3,Q4
	*/
	
	vmov		s28, s18						// q4 contains P0, P1, sth, Q0 	
	vmov		s18, s23						// q4 contains P0, P1, Q1, Q0
	vmov		s23, s26						// q5 contains P3, P2, Q2, Q3
	vmov		s26, s28						// q6 contains P4, P5, Q5, Q4
	
	vrev64.32	d9,d9							// q4 contains P0, P1, Q0, Q1
	vrev64.32	d10,d10							// q5 contains P2, P3, Q2, Q3
	vrev64.32	d13,d13							// q6 contains P4, P5, Q4, Q5
				
	
	vmull.u32	q4, d8, d9						// q4 contains P0Q0,P1Q1 
	vmull.u32	q5, d10, d11					// q5 contains P2Q2,P3Q3
	vmull.u32	q6, d12, d13					// q6 contains P4Q4,P5Q5
	

	/* Now reduction */
	mov 		r5, #2						    // our prime number is 2^26-5 (in form of 2^ell-c)
	lsl			r5, #25						    // r5 contains 2^27 or 2^(ell+1)
	sub			r5, r5, #1					    // r6 contains 2^ell - 1
	vmov.i32    q7  , #0
	vmov.i32    q8  , #0
	
	vmov		s28 , r5						
	vmov		s30, r5
	
	vmov 		q8, q7							// q8: d16, d17 contain 2^ell - 1
					
	vmov.i32	q9, #5
	vshr.u64	q9, #32
	

	/*P0Q0 d8 P1Q1 d9*/
	vand.u64	q10, q8, q4		 				// a0 = a&(2^ell - 1)
	vshr.u64	q4, #26							// a1 = a>>ell
	vmov.i32    q11  , #0
	vmov.i32    q12  , #0
	vmlal.u32	q11, d8, d18					// d0*5 = c*a1
	vmlal.u32	q12, d9, d19
	vadd.u64	q4, q11, q10					// c*a1+a0
	vadd.u64	q11, q12, q10
	vmov		d9, d22
		
	
	vand.u64	q10, q8, q4		 				// a0 = a&(2^ell - 1)
	vshr.u64	q4, #26							// a1 = a>>ell
	vmov.i32    q11  , #0
	vmov.i32    q12  , #0
	vmlal.u32	q11, d8, d18					// d0*5 = c*a1
	vmlal.u32	q12, d9, d19
	vadd.u64	q4, q11, q10					// c*a1+a0
	vadd.u64	q11, q12, q10
	vmov		d9, d22
	
	/*reduced P0Q0 is in d8, and reduced P1Q1 is in d9 q4*/
	
	
	/*P2Q2 d10 P3Q3 d11*/
	vand.u64	q10, q8, q5		 				// a0 = a&(2^ell - 1)
	vshr.u64	q5, #26							// a1 = a>>ell
	vmov.i32    q11  , #0
	vmov.i32    q12  , #0
	vmlal.u32	q11, d10, d18					// d0*5 = c*a1
	vmlal.u32	q12, d11, d19
	vadd.u64	q5, q11, q10					// c*a1+a0
	vadd.u64	q11, q12, q10
	vmov		d11, d22
		
	
	vand.u64	q10, q8, q5		 				// a0=a&(2^ell - 1)
	vshr.u64	q5, #26							// a1=a>>ell
	vmov.i32    q11  , #0
	vmov.i32    q12  , #0
	vmlal.u32	q11, d10, d18					// d0*5 = c*a1
	vmlal.u32	q12, d11, d19
	vadd.u64	q5, q11, q10					// c*a1+a0
	vadd.u64	q11, q12, q10
	vmov		d11, d22
	
				
	/*reduced P2Q2 is in d10, and reduced P3Q3 is in d11 q5*/
	
	/*P4Q4 d12 P5Q5 d13*/
	vand.u64	q10, q8, q6		 				// a0 = a&(2^ell - 1)
	vshr.u64	q6, #26							// a1 = d6>>ell=a>>ell
	vmov.i32    q11  , #0
	vmov.i32    q12  , #0
	vmlal.u32	q11, d12, d18					// d0*5 = c*a1
	vmlal.u32	q12, d13, d19
	vadd.u64	q6, q11, q10					// c*a1+a0
	vadd.u64	q11, q12, q10
	vmov		d13, d22
		
	
	vand.u64	q10, q8, q6		 				// a0 = a&(2^ell - 1)
	vshr.u64	q6, #26							// a1 = a>>ell
	vmov.i32    q11  , #0
	vmov.i32    q12  , #0
	vmlal.u32	q11, d12, d18					// d0*5 = c*a1
	vmlal.u32	q12, d13, d19
	vadd.u64	q6, q11, q10					// c*a1+a0
	vadd.u64	q11, q12, q10
	vmov		d13, d22
				
	/*reduced P4Q4 is in d12, and reduced P5Q5 is in d13 q6*/
	
	/*
	Now we have these: 
	q0 		X1,X0,Y1,Y0
	q1 		X3,X2,Y3,Y2
	q2 		X5,X4,Y5,Y4
	q4		reduced  	P0Q0,P1Q1
	q5		reduced		P2Q2,P3Q3
	q6		reduced		P4Q4,P5Q5
	*/
	
	vmull.u32	q13, d0, d1		  				// q13 contains X0Y0,X1Y1 
	vmull.u32	q14, d2, d3						// q14 contains X2Y2,X3Y3
	vmull.u32	q15, d4, d5						// q15 contains X4Y4,X5Y5
	
	
	
	/*X0Y0 d26 X1Y1 d27*/
	vand.u64	q10, q8, q13		 			// a0 = a&(2^ell - 1)
	vshr.u64	q13, #26						// a1 = d6>>ell=a>>ell
	vmov.i32    q11  , #0
	vmov.i32    q12  , #0
	vmlal.u32	q11, d26, d18					// d0*5 = c*a1
	vmlal.u32	q12, d27, d19
	vadd.u64	q13, q11, q10					// c*a1+a0
	vadd.u64	q11, q12, q10
	vmov		d27, d22
		
		
	vand.u64	q10, q8, q13		 			// a0 = a&(2^ell - 1)
	vshr.u64	q13, #26						// a1 = d6>>ell=a>>ell
	vmov.i32    q11  , #0
	vmov.i32    q12  , #0
	vmlal.u32	q11, d26, d18					// d0*5 = c*a1
	vmlal.u32	q12, d27, d19
	vadd.u64	q13, q11, q10					// c*a1+a0
	vadd.u64	q11, q12, q10
	vmov		d27, d22
	
	/*reduced X0Y0 is in d26, and reduced X1Y1 is in d27 q13*/
	
	/*X2Y2 d28 X3Y3 d29*/
	vand.u64	q10, q8, q14		 			// a0 = a&(2^ell - 1)
	vshr.u64	q14, #26						// a1 = d6>>ell=a>>ell
	vmov.i32    q11  , #0
	vmov.i32    q12  , #0
	vmlal.u32	q11, d28, d18					// d0*5 = c*a1
	vmlal.u32	q12, d29, d19
	vadd.u64	q14, q11, q10					// c*a1+a0
	vadd.u64	q11, q12, q10
	vmov		d29, d22
	
	
	vand.u64	q10, q8, q14		 			// a0 = a&(2^ell - 1)
	vshr.u64	q14, #26						// a1 = d6>>ell=a>>ell
	vmov.i32    q11  , #0
	vmov.i32    q12  , #0
	vmlal.u32	q11, d28, d18					// d0*5 = c*a1
	vmlal.u32	q12, d29, d19
	vadd.u64	q14, q11, q10					// c*a1+a0
	vadd.u64	q11, q12, q10
	vmov		d29, d22
	

	/*reduced X2Y2 is in d28, and reduced X3Y3 is in d29 q14*/
	
	/*X4Y4 d30 X5Y5 d31*/	
	vand.u64	q10, q8, q15		 			// a0 = a&(2^ell - 1)
	vshr.u64	q15, #26						// a1 = d6>>ell=a>>ell
	vmov.i32    q11  , #0
	vmov.i32    q12  , #0
	vmlal.u32	q11, d30, d18					// d0*5 = c*a1
	vmlal.u32	q12, d31, d19
	vadd.u64	q15, q11, q10					// c*a1+a0
	vadd.u64	q11, q12, q10
	vmov		d31, d22
	
	
	vand.u64	q10, q8, q15		 			// a0 = a&(2^ell - 1)
	vshr.u64	q15, #26						// a1 = d6>>ell=a>>ell
	vmov.i32    q11  , #0
	vmov.i32    q12  , #0
	vmlal.u32	q11, d30, d18					// d0*5 = c*a1
	vmlal.u32	q12, d31, d19
	vadd.u64	q15, q11, q10					// c*a1+a0
	vadd.u64	q11, q12, q10
	vmov		d31, d22
	
	/*reduced X4Y4 is in d30, and reduced X5Y5 is in d31 q15*/
	
	/*
	Now we have these: 
	q0 		X1,X0,Y1,Y0
	q1 		X3,X2,Y3,Y2
	q2 		X5,X4,Y5,Y4
	q4		reduced  	P0Q0,P1Q1
	q5		reduced		P2Q2,P3Q3
	q6		reduced		P4Q4,P5Q5
	q13		reduced		X0Y0,X1Y1	
	q14		reduced		X2Y2,X3Y3
	q15		reduced		X4Y4,X5Y5
	*/
	vmov	q0,q13
	vmov	q1,q14
	vmov	q2,q15
	
	vmov 	s1,s2
	vmov	s2,s4
	vmov	s3,s6
	vmov	s4,s8
	vmov	s5,s10
	vmov	s6,s16
	vmov	s7,s18
	vmov	s8,s20
	vmov	s9,s22
	vmov	s10,s24
	vmov	s11,s26
		
	vst1.8		{q0,q1}, [r2]!
	vst1.8		{q2}, [r2]!	
	
	subs		r3, r3, #36
	bcc		    .Lloop3_done
	
.Lloop3:

	vld1.32		{q13,q14}, [r0]!			
	vld1.32 	{d30}, [r0]
	add			r0, r0, #4
	
	vld1.32		{q10,q11}, [r1]!		
	vld1.32		{d24}, [r1]					
	add			r1, r1, #4

	vmov.i32    q0	, #0
	vmov.i32    q1  , #0
    vmov.i32    q2  , #0
    vmov.i32    q6  , #0
    vmov.i32    q7  , #0	
	
	
    vshl.u64    d12, d26, #40			
    vext.8      d0, d12, d13, #5			
        
    vshl.u64    d12, d26, #16
    vshr.u64    d12, d12, #40
    vmov		s1, s24

	vshr.u64    d13, d26, #48
	vshl.u64	d12, d27, #56
	vshr.u64	d12, d12, #40
	vorr.u64	d13, d13, d12
	vmov		s2, s26
	   
    vshl.u64    d12,d27,#32
    vshr.u64    d12,d12,#40
    vmov        s3,s24
    
    
    vshl.u64    d12,d27,#8
    vshr.u64    d12,d12,#40
    vmov        s4,s24
    
    vshr.u64    d12,d27,#56
    vshl.u64    d13,d28,#48
    vshr.u64    d13,d13,#40
    veor.32     d13,d13,d12
    vmov        s5,s26
    
    vshl.u64    d12,d28,#24
    vshr.u64    d12,d12,#40
    vmov        s6,s24
    
    
    vshr.u64    d12,d28,#40
    vmov        s7,s24
    
    vshl.u64    d12,d29,#40
    vshr.u64    d12,d12,#40
    vmov		s8, s24
    
    vshl.u64    d12,d29,#16
    vshr.u64    d12,d12,#40
    vmov		s9, s24
    
    vshr.u64    d12,d29,#48
    vshl.u64	d13,d30,#56
    vshr.u64	d13,d13,#40
    veor.32     d12,d13,d12
    vmov		s10, s24
    
    vshl.u64	d12,d30,#32
    vshr.u64	d12,d12,#40
    vmov		s11, s24						// now q0 has X0,X1,X2,X3  q1 has X4,X5,Y0,Y1  q2 has Y2,Y3,Y4,Y5

    
    vmov.i32    q3	, #0
	vmov.i32    q4  , #0
    vmov.i32    q5  , #0
    vmov.i32    q6  , #0
    vmov.i32    q7  , #0
    
    vshl.u64    d12, d20, #40			
    vext.8      d6, d12, d13, #5			
        
    vshl.u64    d12, d20, #16
    vshr.u64    d12, d12, #40
    vmov		s13, s24

	vshr.u64    d13, d20, #48
	vshl.u64	d12, d21, #56
	vshr.u64	d12, d12, #40
	vorr.u64	d13, d13, d12
	vmov		s14, s26
	   
    vshl.u64    d12,d21,#32
    vshr.u64    d12,d12,#40
    vmov        s15,s24
    

    vshl.u64    d12,d21,#8
    vshr.u64    d12,d12,#40
    vmov        s16,s24
    
    vshr.u64    d12,d21,#56
    vshl.u64    d13,d22,#48
    vshr.u64    d13,d13,#40
    veor.32     d13,d13,d12
    vmov        s17,s26
    
    vshl.u64    d12,d22,#24
    vshr.u64    d12,d12,#40
    vmov        s18,s24
    
    
    vshr.u64    d12,d22,#40
    vmov        s19,s24
    
    vshl.u64    d12,d23,#40
    vshr.u64    d12,d12,#40
    vmov		s20, s24
    
    vshl.u64    d12,d23,#16
    vshr.u64    d12,d12,#40
    vmov		s21, s24
    
    vshr.u64    d12,d23,#48
    vshl.u64	d13,d24,#56
    vshr.u64	d13,d13,#40
    veor.32     d12,d13,d12
    vmov		s22, s24
    
    vshl.u64	d12,d24,#32
    vshr.u64	d12,d12,#40
    vmov		s23, s24						// now q3 has corresponding keys for X0,X1,X2,X3  q4 has corresponding keys X4,X5,Y0,Y1  q5 has corresponding keys Y2,Y3,Y4,Y5
    
    vadd.u32	q0, q0, q3   					// q0  contains X0,X1,X2,X3  corresponding keys added
	vadd.u32	q1, q1, q4   					// q1  contains X4,X5,Y0,Y1  corresponding keys added
	vadd.u32	q2, q2, q5   					// q2  contains Y2,Y3,Y4,Y5  corresponding keys added
	
    vmov		d12, d4
	vmov		d4, d2				
	vmov		d2, d1			
	vmov		d1, d3
	vmov		d3, d12							// q0 contains X0,X1,Y0,Y1 - q1 contains X2,X3,Y2,Y3 - q2 contains X4,X5,Y4,Y5
	
	
	vadd.u32	q10, q0, q1   					// q10 contains X0+X2,X1+X3,Y0+Y2,Y1+Y3  
	vadd.u32	q11, q0, q2   					// q11 contains X0+X4,X1+X5,Y0+Y4,Y1+Y5  
	vadd.u32	q12, q1, q2   					// q12 contains X2+X4,X3+X5,Y2+Y4,Y3+Y5  
	
	vrev64.32	q6, q0							// q6 contains X1,X0,Y1,Y0
	vadd.u32	q6, q6, q0						// q6 contains X0+X1,X0+X1,Y0+Y1,Y0+Y1
	
	vrev64.32	q7, q1							// q7 contains X3,X2,Y3,Y2
	vadd.u32	q7, q7, q1						// q7 contains X2+X3,X2+X3,Y2+Y3,Y2+Y3
	vmov		s25, s29						// q6 contains X0+X1,X2+X3,Y0+Y1,Y0+Y1
	vmov		s27, s31						// q6 contains X0+X1,X2+X3,Y0+Y1,Y2+Y3
	
	vrev64.32	q7, q2							// q7 contains X5,X4,Y5,Y4
	vadd.u32	q7, q7, q2						// q7 contains X4+X5,X4+X5,Y4+Y5,Y4+Y5
	
		
	vmov.u32	q3, #3	
	vmul.u32	q3, q12, q3						// q3 contains 3(X2+X4),3(X3+X5),3(Y2+Y4),3(Y3+Y5) 
	vmov		s16, s12						// q4 contains 3(X2+X4)(3q12.s0), sth, sth, sth  
	vmov		s18, s14						// q4 contains 3(X2+X4)(3q12.s0), sth, 3(Y2+Y4)(3q12.s2), sth  
	vrev64.32	q3, q3							// q3 contains 3(X3+X5),3(X2+X4),3(Y3+Y5),3(Y2+Y4)
	vadd.u32	q3, q3, q12						// q3 contains 3(X3+X5)+X2+X4,3(X2+X4)+X3+X5,3(Y3+Y5)+Y2+Y4,3(Y2+Y4)+Y3+Y5
	vrev64.32	q0, q0							// q0 contains X1,X0,Y1,Y0
	vadd.u32	q3, q3, q0						// q3 contains 3(X3+X5)+X2+X4+X1,3(X2+X4)+X3+X5+X0,3(Y3+Y5)+Y2+Y4+Y1,3(Y2+Y4)+Y3+Y5+Y0       2, sth, 7, sth
	
	vrev64.32	q1, q1							// q1 contains X3,X2,Y3,Y2
	vadd.u32	q4, q4, q6						// q4 contains 3(X2+X4)+X0+X1, sth, 3(Y2+Y4)+Y0+Y1, sth
	vadd.u32	q4, q4, q1						// q4 contains 3(X2+X4)+X0+X1+X3, sth, 3(Y2+Y4)+Y0+Y1+Y3, sth 								1, sth, 12, sth
	vmov		s17, s12						// q4 contains 3(X2+X4)+X0+X1+X3, 3(X3+X5)+X2+X4+X1, 3(Y2+Y4)+Y0+Y1+Y3, sth  1, 2, 12, sth
	vmov		s19, s14						// q4 contains 3(X2+X4)+X0+X1+X3, 3(X3+X5)+X2+X4+X1, 3(Y2+Y4)+Y0+Y1+Y3, 3(Y3+Y5)+Y2+Y4+Y1   1, 2, 12, 7 contains P0,P1,Q5,Q0
	
	
	vmov.u32	q3, #3
	vmul.u32	q3, q11, q3						// q8 contians 3(X0+X4),3(X1+X5),3(Y0+Y4),3(Y1+Y5) 
	vmov		s21, s12						// q5 contains sth, 3(X0+X4), sth, sth
	vmov		s23, s14						// q5 constains sth, 3(X0+X4), sth, 3(Y0+Y4)
	vrev64.32	q3, q3 							// q3 contians 3(X1+X5),3(X0+X4),3(Y1+Y5),3(Y0+Y4) 
	vadd.u32	q3, q3, q11						// q3 contians 3(X1+X5)+X0+X4,3(X0+X4)+X1+X5,3(Y1+Y5)+Y0+Y4,3(Y0+Y4)+Y1+Y5
	vadd.u32	q3, q3, q1						// q3 contians 3(X1+X5)+X0+X4+X3,3(X0+X4)+X1+X5+X2,3(Y1+Y5)+Y0+Y4+Y3,3(Y0+Y4)+Y1+Y5+Y2	    4, sth, 9, sth   
	
	vadd.u32	q6, q6, q2						// q6 contains X0+X1+X4,X2+X3+X5,Y0+Y1+Y4,Y2+Y3+Y5
	vadd.u32	q5, q5, q6						// q5 contains sth, 3(X0+X4)+X2+X3+X5, sth, 3(Y0+Y4)+Y2+Y3+Y5      sth, 3, sth, 8
	vmov		s20, s12		 				// q5 contains 3(X1+X5)+X0+X4+X3, 3(X0+X4)+X2+X3+X5, sth, 3(Y0+Y4)+Y2+Y3+Y5
	vmov		s22, s14						// q5 contains 3(X1+X5)+X0+X4+X3, 3(X0+X4)+X2+X3+X5, 3(Y1+Y5)+Y0+Y4+Y3, 3(Y0+Y4)+Y2+Y3+Y5	4, 3, 9, 8 contains P3,P2,Q2,Q1
	
	vmov.u32	q3, #3
	vmul.u32	q3, q10, q3						// q3 contains 3*(X0+X2),3*(X1+X3),3*(Y0+Y2),3*(Y1+Y3)
	vmov		s24, s12						// q6 contains 3*(X0+X2), sth, sth, sth
	vmov		s26, s14						// q6 contains 3*(X0+X2),sth,3*(Y0+Y2),sth
	vrev64.32	q3, q3							// q3 contains 3*(X1+X3),3*(X0+X2),3*(Y1+Y3),3*(Y0+Y2)
	vadd.u32	q3, q3, q10						// q3 contains 3*(X1+X3)+X0+X2,3*(X0+X2)+X1+X3,3*(Y1+Y3)+Y0+Y2,3*(Y0+Y2)+Y1+Y3 	
	vrev64.32	q2, q2							// q2 contains X5,X4,Y5,Y4
	vadd.u32	q3, q2, q3						// q3 contains 3*(X1+X3)+X0+X2+X5,3*(X0+X2)+X1+X3+X4,3*(Y1+Y3)+Y0+Y2+Y5,3*(Y0+Y2)+Y1+Y3+Y4    6, sth, 11, sth
	
											
	vadd.u32	q6, q6, q7						// q6 contains 3*(X0+X2)+X4+X5,sth,3*(Y0+Y2)+Y4+Y5,sth
	vadd.u32	q6, q0, q6						// q6 contains 3*(X0+X2)+X4+X5+X1,sth,3*(Y0+Y2)+Y4+Y5+Y1,sth	5, sth, 10, sth
	vmov		s25, s12						// q6 contains 5, sth, 10, sth
	vmov		s27, s14						// q6 contains 5, 6, 10, 11	contains P4,P5,Q3,Q4
	
	
	/*
	Now we have these: 
	q0 		X1,X0,Y1,Y0
	q1 		X3,X2,Y3,Y2
	q2 		X5,X4,Y5,Y4
	q10 	X0+X2,X1+X3,Y0+Y2,Y1+Y3 
	q11 	X0+X4,X1+X5,Y0+Y4,Y1+Y5 
	q12 	X2+X4,X3+X5,Y2+Y4,Y3+Y5 
	q4		P0,P1,Q5,Q0
	q5		P3,P2,Q2,Q1
	q6		P4,P5,Q3,Q4
	*/
	
	vmov		s28, s18						// q4 contains P0, P1, sth, Q0 	
	vmov		s18, s23						// q4 contains P0, P1, Q1, Q0
	vmov		s23, s26						// q5 contains P3, P2, Q2, Q3
	vmov		s26, s28						// q6 contains P4, P5, Q5, Q4
	
	vrev64.32	d9,d9							// q4 contains P0, P1, Q0, Q1
	vrev64.32	d10,d10							// q5 contains P2, P3, Q2, Q3
	vrev64.32	d13,d13							// q6 contains P4, P5, Q4, Q5
				
	
	vmull.u32	q4, d8, d9						// q4 contains P0Q0,P1Q1 
	vmull.u32	q5, d10, d11					// q5 contains P2Q2,P3Q3
	vmull.u32	q6, d12, d13					// q6 contains P4Q4,P5Q5
	

	/* Now reduction */
	mov 		r5, #2						    // our prime number is 2^26-5 (in form of 2^ell-c)
	lsl			r5, #25						    // r5 contains 2^27 or 2^(ell+1)
	sub			r5, r5, #1					    // r6 contains 2^ell - 1
	vmov.i32    q7  , #0
	vmov.i32    q8  , #0
	
	vmov		s28 , r5						
	vmov		s30, r5
	
	vmov 		q8, q7							// q8: d16, d17 contain 2^ell - 1
					
	vmov.i32	q9, #5
	vshr.u64	q9, #32
	

	/*P0Q0 d8 P1Q1 d9*/
	vand.u64	q10, q8, q4		 				// a0 = a&(2^ell - 1)
	vshr.u64	q4, #26							// a1 = a>>ell
	vmov.i32    q11  , #0
	vmov.i32    q12  , #0
	vmlal.u32	q11, d8, d18					// d0*5 = c*a1
	vmlal.u32	q12, d9, d19
	vadd.u64	q4, q11, q10					// c*a1+a0
	vadd.u64	q11, q12, q10
	vmov		d9, d22
		
	
	vand.u64	q10, q8, q4		 				// a0 = a&(2^ell - 1)
	vshr.u64	q4, #26							// a1 = a>>ell
	vmov.i32    q11  , #0
	vmov.i32    q12  , #0
	vmlal.u32	q11, d8, d18					// d0*5 = c*a1
	vmlal.u32	q12, d9, d19
	vadd.u64	q4, q11, q10					// c*a1+a0
	vadd.u64	q11, q12, q10
	vmov		d9, d22
	
	/*reduced P0Q0 is in d8, and reduced P1Q1 is in d9 q4*/
	
	
	/*P2Q2 d10 P3Q3 d11*/
	vand.u64	q10, q8, q5		 				// a0 = a&(2^ell - 1)
	vshr.u64	q5, #26							// a1 = a>>ell
	vmov.i32    q11  , #0
	vmov.i32    q12  , #0
	vmlal.u32	q11, d10, d18					// d0*5 = c*a1
	vmlal.u32	q12, d11, d19
	vadd.u64	q5, q11, q10					// c*a1+a0
	vadd.u64	q11, q12, q10
	vmov		d11, d22
		
	
	vand.u64	q10, q8, q5		 				// a0=a&(2^ell - 1)
	vshr.u64	q5, #26							// a1=a>>ell
	vmov.i32    q11  , #0
	vmov.i32    q12  , #0
	vmlal.u32	q11, d10, d18					// d0*5 = c*a1
	vmlal.u32	q12, d11, d19
	vadd.u64	q5, q11, q10					// c*a1+a0
	vadd.u64	q11, q12, q10
	vmov		d11, d22
	
				
	/*reduced P2Q2 is in d10, and reduced P3Q3 is in d11 q5*/
	
	/*P4Q4 d12 P5Q5 d13*/
	vand.u64	q10, q8, q6		 				// a0 = a&(2^ell - 1)
	vshr.u64	q6, #26							// a1 = d6>>ell=a>>ell
	vmov.i32    q11  , #0
	vmov.i32    q12  , #0
	vmlal.u32	q11, d12, d18					// d0*5 = c*a1
	vmlal.u32	q12, d13, d19
	vadd.u64	q6, q11, q10					// c*a1+a0
	vadd.u64	q11, q12, q10
	vmov		d13, d22
		
	
	vand.u64	q10, q8, q6		 				// a0 = a&(2^ell - 1)
	vshr.u64	q6, #26							// a1 = a>>ell
	vmov.i32    q11  , #0
	vmov.i32    q12  , #0
	vmlal.u32	q11, d12, d18					// d0*5 = c*a1
	vmlal.u32	q12, d13, d19
	vadd.u64	q6, q11, q10					// c*a1+a0
	vadd.u64	q11, q12, q10
	vmov		d13, d22
	
					
	/*reduced P4Q4 is in d12, and reduced P5Q5 is in d13 q6*/
	
	/*
	Now we have these: 
	q0 		X1,X0,Y1,Y0
	q1 		X3,X2,Y3,Y2
	q2 		X5,X4,Y5,Y4
	q4		reduced  	P0Q0,P1Q1
	q5		reduced		P2Q2,P3Q3
	q6		reduced		P4Q4,P5Q5
	*/
	
	vmull.u32	q13, d0, d1		  				// q13 contains X0Y0,X1Y1 
	vmull.u32	q14, d2, d3						// q14 contains X2Y2,X3Y3
	vmull.u32	q15, d4, d5						// q15 contains X4Y4,X5Y5
	
	
	
	/*X0Y0 d26 X1Y1 d27*/
	vand.u64	q10, q8, q13		 			// a0 = a&(2^ell - 1)
	vshr.u64	q13, #26						// a1 = d6>>ell=a>>ell
	vmov.i32    q11  , #0
	vmov.i32    q12  , #0
	vmlal.u32	q11, d26, d18					// d0*5 = c*a1
	vmlal.u32	q12, d27, d19
	vadd.u64	q13, q11, q10					// c*a1+a0
	vadd.u64	q11, q12, q10
	vmov		d27, d22

	
	vand.u64	q10, q8, q13		 			// a0 = a&(2^ell - 1)
	vshr.u64	q13, #26						// a1 = d6>>ell=a>>ell
	vmov.i32    q11  , #0
	vmov.i32    q12  , #0
	vmlal.u32	q11, d26, d18					// d0*5 = c*a1
	vmlal.u32	q12, d27, d19
	vadd.u64	q13, q11, q10					// c*a1+a0
	vadd.u64	q11, q12, q10
	vmov		d27, d22
	
	/*reduced X0Y0 is in d26, and reduced X1Y1 is in d27 q13*/
	
	/*X2Y2 d28 X3Y3 d29*/
	vand.u64	q10, q8, q14		 			// a0 = a&(2^ell - 1)
	vshr.u64	q14, #26						// a1 = d6>>ell=a>>ell
	vmov.i32    q11  , #0
	vmov.i32    q12  , #0
	vmlal.u32	q11, d28, d18					// d0*5 = c*a1
	vmlal.u32	q12, d29, d19
	vadd.u64	q14, q11, q10					// c*a1+a0
	vadd.u64	q11, q12, q10
	vmov		d29, d22
	
	
	vand.u64	q10, q8, q14		 			// a0 = a&(2^ell - 1)
	vshr.u64	q14, #26						// a1 = d6>>ell=a>>ell
	vmov.i32    q11  , #0
	vmov.i32    q12  , #0
	vmlal.u32	q11, d28, d18					// d0*5 = c*a1
	vmlal.u32	q12, d29, d19
	vadd.u64	q14, q11, q10					// c*a1+a0
	vadd.u64	q11, q12, q10
	vmov		d29, d22
	

	/*reduced X2Y2 is in d28, and reduced X3Y3 is in d29 q14*/
	
	/*X4Y4 d30 X5Y5 d31*/	
	vand.u64	q10, q8, q15		 			// a0 = a&(2^ell - 1)
	vshr.u64	q15, #26						// a1 = d6>>ell=a>>ell
	vmov.i32    q11  , #0
	vmov.i32    q12  , #0
	vmlal.u32	q11, d30, d18					// d0*5 = c*a1
	vmlal.u32	q12, d31, d19
	vadd.u64	q15, q11, q10					// c*a1+a0
	vadd.u64	q11, q12, q10
	vmov		d31, d22
	
	
	vand.u64	q10, q8, q15		 			// a0 = a&(2^ell - 1)
	vshr.u64	q15, #26						// a1 = d6>>ell=a>>ell
	vmov.i32    q11  , #0
	vmov.i32    q12  , #0
	vmlal.u32	q11, d30, d18					// d0*5 = c*a1
	vmlal.u32	q12, d31, d19
	vadd.u64	q15, q11, q10					// c*a1+a0
	vadd.u64	q11, q12, q10
	vmov		d31, d22
	
	/*reduced X4Y4 is in d30, and reduced X5Y5 is in d31 q15*/
	
	/*
	Now we have these: 
	q0 		X1,X0,Y1,Y0
	q1 		X3,X2,Y3,Y2
	q2 		X5,X4,Y5,Y4
	q4		reduced  	P0Q0,P1Q1
	q5		reduced		P2Q2,P3Q3
	q6		reduced		P4Q4,P5Q5
	q13		reduced		X0Y0,X1Y1	
	q14		reduced		X2Y2,X3Y3
	q15		reduced		X4Y4,X5Y5
	*/
	vmov	q0,q13
	vmov	q1,q14
	vmov	q2,q15
	
	vmov 	s1,s2
	vmov	s2,s4
	vmov	s3,s6
	vmov	s4,s8
	vmov	s5,s10
	vmov	s6,s16
	vmov	s7,s18
	vmov	s8,s20
	vmov	s9,s22
	vmov	s10,s24
	vmov	s11,s26
	
	sub			r2, r2, #48
	vld1.32		{q7,q8}, [r2]!			
	vld1.32 	{q9}, [r2]!
	
	vadd.u32	q0, q0, q7
	vadd.u32	q1, q1, q8
	vadd.u32	q2, q2, q9	


	/* Now Reduction */
	vmov.i32	q7, #2
	vshl.u32	q7, #25
	vmov.i32	q8, #1
	vsub.u32	q8,q7,q8
	vmov.i32	q9, #5
	
	
	/*X0Y0, X1Y1, X2Y2, X3Y3 in q0*/
	vand.u32	q10, q8, q0		 				// a0 = a&(2^ell - 1)
	vshr.u32	q0, #26							// a1 = a>>ell
	vmov.i32    q11  , #0
	vmla.u32	q11, q0, q9						// c*a1
	vadd.u32	q0, q11, q10					// c*a1+a0
	
		
	/*X4Y4, X5Y5, P0Q0, P1Q1 in q1*/
	vand.u32	q10, q8, q1		 				// a0 = a&(2^ell - 1)
	vshr.u32	q1, #26							// a1 = a>>ell
	vmov.i32    q11  , #0
	vmla.u32	q11, q1, q9						// c*a1
	vadd.u32	q1, q11, q10					// c*a1+a0
	
		
	/*P2Q2, P3Q3, P4Q4, P5Q5 in q2*/
	vand.u32	q10, q8, q2		 				// a0 = a&(2^ell - 1)
	vshr.u32	q2, #26							// a1 = a>>ell
	vmov.i32    q11  , #0
	vmla.u32	q11, q2, q9						// c*a1
	vadd.u32	q2, q11, q10					// c*a1+a0
			
	vst1.8		{q0,q1}, [r2]!
	vst1.8		{q2}, [r2]!	
	
	subs		r3, r3, #36
	bcs     	.Lloop3
	
.Lloop3_done:
	//pop    {r4,r5}
	bx		lr

.align 8
