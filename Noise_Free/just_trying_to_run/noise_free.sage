from sage.crypto.lwe import *
from sage.modules.free_module_integer import IntegerLattice
import numpy as np

def bin2decimal(string):
    string = string[::-1]
    num = 0
    factor = 1
    for i in string:
        if i == '1':
            num = num + 1*factor
        factor *= 2
    return num


def createDiagMat(n):
    D = np.identity(2*n)
    max_block_size = Integer(0)
    for i in range(n):
        if S[i][9] > max_block_size:
            max_block_size = S[i][9]

    # S = (r-0, s-1, k-2, h(m)-3, l_a-4, l_b-5, l_c-6, a -7, c-8, no of bits leaked-9)
    for i in range(n):
        l_b = S[i][5]
        l_c = S[i][6]
        l_d = Integer(160) - l_c
        D[i][i] = 2^(max_block_size - max(l_b, l_d))

    return D

def createCVP(S, n, q):
    # O
    B = np.zeros((2*n, 2*n))
    # I_n+1_x_n+1
    I = np.identity(n+1)
    B[:n+1, :n+1] = I
    # qI_n-1
    qI = q*np.identity(n-1)
    B[n+1:, n+1:] = qI

    w_1 = []; w_2 = []
    x = []; y = []
    v = []; u = []
    for i in range(n+1):
        # S = (r-0, s-1, k-2, h(m)-3, l_a-4, l_b-5, l_c-6, a -7, c-8, no of bits leaked-9)
        r = S[i][0]; s = S[i][1]
        l_a = S[i][4]; l_b = S[i][5]; l_c = S[i][6]
        a = bin2decimal( S[i][7] )
        c = bin2decimal( S[i][8] ) #* (2 ^ l_b)
        m = S[i][3]
        y.append(-(r/s)*(2^l_a))
        x.append((-(m/c) + c*(2^l_b) + a)*(2^l_a))

        if i != 0:
            w_1.append(y[i]/y[0])
            w_2.append((y[i]/y[0]) * (2 ^ (l_c - l_a)))
            u.append(-(2 ^ (l_c - l_a)))
            v.append(x[i] - (y[i]/y[0]) * x[0])

    w_1 = np.array(w_1)
    w_2 = np.array(w_2)
    B[0][n:] = w_1
    B[1][n:] = w_2
    for i in range(2, n+1):
        B[i][(i-2)+n] = u[i-2]
    V = np.zeros(2*n)
    V[n:] = v
    return [B, V]

def CVP2SVP(B, t, n, q):
    n = Integer(n) + Integer(1)
    B_dash = np.zeros((n, n))
    B_dash[:-1, :-1] = B
    B_dash[-1, :-1] = t
    B_dash[-1][-1] = q

    return B_dash


def compute_key(b_d, n, S):
    d=[]
    for i in range(1,n+1):
        d.append(b_d[i])
    # print(len(d))

    b = []
    b.append(b_d[0])
    for i in range(n+1, 2*n):
        b.append(b_d[i])
    # print(len(b))

    result = []
    for i in range(n):
        l_a = S[i][4]
        l_b = S[i][5]
        l_c = S[i][6]
        a = bin2decimal(S[i][7])
        b_i = (b[i]*(2 ^ l_a))
        c = bin2decimal(S[i][8])*(2 ^ l_b)
        d_i = (d[i]*(2 ^ l_c))
        result.append( a + b_i + c + d_i )
    result.append(Integer(0))
    return result

def findKey(S, correctKey, q):

    total_leaked_bits = 0
    gamma_min = 0
    for i in S:
        total_leaked_bits += i[9]
        gamma_min += 1
        if total_leaked_bits >= 160:
            break

    print("gamma min = ",gamma_min)
    keyNotFound = True
    i = gamma_min
    # i=140
    maxIter = len(S)
    computedKey = 0
    while i <= maxIter and keyNotFound == True:
        print('number of samples = ', i)
        [cvpBasis, v] = createCVP(S, i, q)

        cvpBasis = [map(int, j) for j in cvpBasis]
        cvpL = matrix(ZZ, cvpBasis)
        
        for j in range(len(v)):
            v[j] = int(v[j])

        svpBasis = CVP2SVP(cvpBasis, v, len(cvpBasis), q)
        svpBasis = [map(int, j) for j in svpBasis]
        svpL = matrix(ZZ, svpBasis)
        
        '''Solving using CVP'''
        # cvpReducedL = IntegerLattice( cvpL.LLL() )
        # print('LLL done')
        # result = cvpReducedL.closest_vector(v)
        '''end'''

        svpReducedL = IntegerLattice(svpL.LLL())
        # svpReducedL = svpL.BKZ()
        result = svpReducedL.shortest_vector()
        
        # print(correctKey)
        # print(result)
        computedKey = compute_key(result, i, S)
        
        Q = IntegerModRing(q)
        for j in range(i):
            print 'myk',computedKey[j]
            print 'ack', S[i][2]
            print 'crA',correctKey
            s = S[j][1]
            k = S[j][2]
            m = S[j][3]
            r = S[j][0]
            # alpha = (s*k-m)*Q(1/r)
            alpha = (s*computedKey[j]-m)*Q(1/r)

            print 'myA', alpha
            print 
            if alpha == correctKey:
                input("true")
                return computedKey
            if computedKey[j] == k:
                input("TRUE")
        else:
            i = i+5


if __name__ == "__main__":

    f = open("./files/private_key.pem", "r")
    correctKey = ZZ(f.readline())
    f.close()
    f = open("./files/q.pem", "r")
    q = ZZ(f.readline())
    f.close()
    EKOs_list = [] 
    f = open("./files/list.csv", "r")
    S = f.readlines()
    for line in S:
        # S = (r-0, s-1, k-2, h(m)-3, l_a-4, l_b-5, l_c-6, a -7, c-8, no of bits leaked-9)
        line = line.split(',')
        r = ZZ(line[0]) 
        s = ZZ(line[1])
        k = ZZ(line[2])
        m = ZZ(line[3])
        l_a = ZZ(line[4])
        l_b = ZZ(line[5])
        l_c = ZZ(line[6])
        a = line[7]
        c = line[8]
        bits = ZZ(line[9])
        EKOs_list.append([r, s, k, m, l_a, l_b, l_c, a, c, bits])
    f.close()
    # print(len(EKOs_list))
    print (findKey(EKOs_list, correctKey, q))
    
