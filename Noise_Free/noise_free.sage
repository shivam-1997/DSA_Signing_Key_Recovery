import numpy as np
from generation.sage import *
from fpylll import *


def bin2decimal(string):
    string = string[::-1]
    num = 0
    factor = 1
    for i in string:
        if i == '1':
            num = num + 1*factor
        factor *= 2
    return num


def createCVP(S, n, q):
    # O
    B = np.zeros((2*n, 2*n))
    # I_n+1_x_n+1
    I = np.identity(n+1)
    B[:n+1, :n+1] = I
    # qI_n-1
    qI = q*np.identity(n-1)
    B[n+1:, n+1:] = qI

    w_1 = []
    w_2 = []
    x = []
    y = []
    v = []
    for i in range(n+1):
        # S = (r-0, s-1, k-2, h(m)-3, l_a-4, l_b-5, l_c-6, a -7, c-8, number of bits leaked-9)
        r = S[i][0]
        s = S[i][1]
        l_a = S[i][4]
        l_b = S[i][5]
        l_c = S[i][6]
        a = bin2decimal(S[i][7])
        c = bin2decimal(S[i][8]) * (2 ^ l_b)
        m = S[i][3]
        y.append(-(r/s)*(2 ^ l_a))
        x.append((-(m/c) + c*(2 ^ l_b) + a)*(2 ^ l_a))

        if x != 0:
            w_1.append(y[i]/y[0])
            w_2.append((y[i]/y[0]) * (2 ^ (l_c - l_a)))
            u.append(-(2 ^ (l_c - l_a)))
            v.append(x[i] - (y[i]/y[0]) * x[0])

    w_1 = np.array(w_1)
    w_2 = np.array(w_2)
    B[0][n+1:] = w_1
    B[1][n+1:] = w_2
    for i in range(2, n+2):
        B[i][(i-2)+n+1] = u[i]

    return B, v


def CVP2SVP(B, t, n, q):

    B_dash = np.zeros((n+1, n+1))
    B_dash[:, :-1] = B
    B[-1, :-1] = t
    B[-1][-1] = q

    return B_dash


def findKey(listOfTriplet, correctKey, q):
    S = []  # will store the listed list of EKOs
    S = identify_and_sort(listOfTriplet)

    total_leaked_bits = 0
    gamma_min = 0
    for i in S:
        total_leaked_bits += S[]
        gamma_min += 1
        if total_leaked_bits >= 160:
            break

    keyNotFound = True
    i = gamma_min
    maxIter = len(S)
    computedKey = 0
    while i <= maxIter and keyNotFound == True:
        # create an SVP instance using the top i EKOs from S
        cvpBasis, v = createCVP(S, i, q)
        cvpBasis = [map(ZZ, i) for i in cvpBasis]
        cvpBasis = matrix(cvpBasis)
        v = [map(ZZ, i) for i in v]
        reducedBasis = cvpBasis.LLL(delta=0.75)

        # svpBasis = CVP2SVP(cvpBasis, v, 2*i, q)
        # Solve the SVP instance, compute the DSA private key
        # result = Babai(reducedBasis, v)
        result = CVP.closest_vector(reducedBasis, v)

        computedKey = compute_key(result, S)
        # Verify the correctness
        if computedKey == correctKey:
            keyNotFound = False
        else:
            i = i+1

    return computedKey


if __name__ == "__main__":

    findKey(listOfTriplets, correctKey, q)
