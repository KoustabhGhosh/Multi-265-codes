# -*- coding: utf-8 -*-

# The following part is used to generate key and message

import random

def rand_key(p):
   
    # Variable to store the string
    key1 = ""
 
    # Loop to find the string of desired length
    for i in range(p):
         
        # randint function to generate 0, 1 randomly and converting the result into str
        tem = str(random.randint(0,1))
 
        # Concatenation the random 0, 1 to the final result
        key1 += tem
         
    return(key1)
 
# This is our block function for multi-265, i.e., p =2^26-5    
 
def Multi265(M,K):
    # Define the number of blocks and then Split the message and the key into blocks of size 288
    # Store the split msg blocks and key blocks in the array Msg_blks, Key_blks respectively
    Block_num = len(M)//288
    pr=(2**(26))-5
    Msg_blks = []
    Key_blks = []
    for i in range(Block_num):
        Msg_blk = M[288*i: 288*(i+1)]
        Key_blk = K[288*i: 288*(i+1)]
        Msg_blks.append(Msg_blk)
        Key_blks.append(Key_blk)     
    
    # For each block, divide the messages and keys into 24 bit chunks to obtain the A,B,P and Q
    Blk_reslts = []
    for i in range(len(Msg_blks)):
        # X_i's are the first parts of the messages, Y_i's are the second part, similar H_i and K_i are first and second part of key. 
        
        X_0 = int(Msg_blks[i][0:24],2)
        X_1 = int(Msg_blks[i][24:48],2)
        X_2 = int(Msg_blks[i][48:72],2)
        X_3 = int(Msg_blks[i][72:96],2)
        X_4 = int(Msg_blks[i][96:120],2)
        X_5 = int(Msg_blks[i][120:144],2)
        

        Y_0 = int(Msg_blks[i][144:168],2)
        Y_1 = int(Msg_blks[i][168:192],2)
        Y_2 = int(Msg_blks[i][192:216],2)
        Y_3 = int(Msg_blks[i][216:240],2)
        Y_4 = int(Msg_blks[i][240:264],2)
        Y_5 = int(Msg_blks[i][264:288],2)
        

        H_0 = int(Key_blks[i][0:24],2)
        H_1 = int(Key_blks[i][24:48],2)
        H_2 = int(Key_blks[i][48:72],2)
        H_3 = int(Key_blks[i][72:96],2)
        H_4 = int(Key_blks[i][96:120],2)
        H_5 = int(Key_blks[i][120:144],2)
        
        K_0 = int(Key_blks[i][144:168],2)
        K_1 = int(Key_blks[i][168:192],2)
        K_2 = int(Key_blks[i][192:216],2)
        K_3 = int(Key_blks[i][216:240],2)
        K_4 = int(Key_blks[i][240:264],2)
        K_5 = int(Key_blks[i][264:288],2)
        
        #A_i and B_i are the inputs to the block function (after addition with the corresponding key bits)
        
        A_0 = (X_0+H_0)%(pr)
        A_1 = (X_1+H_1)%(pr)
        A_2 = (X_2+H_2)%(pr)
        A_3 = (X_3+H_3)%(pr)
        A_4 = (X_4+H_4)%(pr)
        A_5 = (X_5+H_5)%(pr)
        
        B_0 = (Y_0+K_0)%(pr)
        B_1 = (Y_1+K_1)%(pr)
        B_2 = (Y_2+K_2)%(pr)
        B_3 = (Y_3+K_3)%(pr)
        B_4 = (Y_4+K_4)%(pr)
        B_5 = (Y_5+K_5)%(pr)
        # Compute P_i and Q_i from A_i, B_i 
        P_0 = (A_0+A_1+(3*A_2)+A_3+(3*A_4))%(pr)
        P_1 = (A_1+A_2+(3*A_3)+A_4+(3*A_5))%(pr)
        P_2 = (A_2+A_3+(3*A_4)+A_5+(3*A_0))%(pr)
        P_3 = (A_3+A_4+(3*A_5)+A_0+(3*A_1))%(pr)
        P_4 = (A_4+A_5+(3*A_0)+A_1+(3*A_2))%(pr)
        P_5 = (A_5+A_0+(3*A_1)+A_2+(3*A_3))%(pr)
        
        Q_0 = (B_1+B_2+(3*B_3)+B_4+(3*B_5))%(pr)
        Q_1 = (B_2+B_3+(3*B_4)+B_5+(3*B_0))%(pr)
        Q_2 = (B_3+B_4+(3*B_5)+B_0+(3*B_1))%(pr)
        Q_3 = (B_4+B_5+(3*B_0)+B_1+(3*B_2))%(pr)
        Q_4 = (B_5+B_0+(3*B_1)+B_2+(3*B_3))%(pr)
        Q_5 = (B_0+B_1+(3*B_2)+B_3+(3*B_4))%(pr)
        # the block function computes the 12 multiplications
        # Results for each block are stored as 12-tuple in the array Blk_reslts
        Blk_res = ((A_0*B_0)%pr, (A_1*B_1)%pr, (A_2*B_2)%pr, (A_3*B_3)%pr, (A_4*B_4)%pr, (A_5*B_5)%pr, (P_0*Q_0)%pr, (P_1*Q_1)%pr, (P_2*Q_2)%pr, (P_3*Q_3)%pr, (P_4*Q_4)%pr, (P_5*Q_5)%pr)
        Blk_reslts.append(Blk_res)
    # res finally adds the results of each block co-ordinatewise and then converts it back to a string
    # the output of all sum of products are stored elements of F_p, p = 2^26-5
    # and are stored as 32-bit strings.
    res =""
    for j in range(12):
        temp = '{:032b}'.format(sum(i[j] for i in Blk_reslts)%(pr))
        res += temp
    
#print(Blk_reslts)

    return(res)

# 288 = block size for multi-265


l = int(input("Enter message Length:   "))            

Msg = rand_key(l*288)
Key = rand_key(l*288)


Z= Mutli265(Msg, Key)

print(Z)