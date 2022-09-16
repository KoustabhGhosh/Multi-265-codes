.text
    .align 8
.global Nh_NHfield
.type	Nh_NHfield, %function;
Nh_NHfield:
	
	/* saving something?*/
	vmov.u64	q0, #0
	vmov.u64	q1, #0
	vmov.u64	q2, #0

	
	subs		r3, r3, #48
	
	vst1.8		{q0,q1}, [r2]
	vst1.8		{q2,q3}, [r2]
	bx		lr

.align 8
