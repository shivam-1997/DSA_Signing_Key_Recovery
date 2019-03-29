import numpy as np

def sort(S):
    pass


def createCVP(S, n, l_a, l_b, l_c, q):
    
    B = np.zeros((2*n, 2*n))
    
    I = np.identity(n+1)
    B[:n+1, :n+1] = I
    
    qI = q*np.identity(n-1)
    B[n+1:, n+1:] = qI
    
    W = []
    return B, v

def CVP2SVP(B, t, n, q):

    B_dash = np.zeros((n+1, n+1))
    B_dash[:, :-1] = B
    B[-1, :-1] = t
    B[-1][-1] = q
    
    return B_dash
    
def findKey(listOfTriplet, correctKey, q):
    S = []  # will store the listed list of EKOs
    keyNotFound = True
    for sign in allSignatures:
        # identify the largest interior block and rignmost block
        for block in allBlocks:
            # create an EKO, e, using the position and value of the interior block and rightmost block
            '''
            S = S union e
            '''
            pass
        pass

    gamma_min = sort(S)

    i = gamma_min
    maxIter = len(S)
    computedKey = 0
    while i <= maxIter and keyNotFound == True:
        # create an SVP instance using the top i EKOs from S
        cvpBasis, v = createCVP(S, i, l_a, l_b, l_c, q)
        svpBasis = CVP2SVP(cvpBasis, v, 2*i, q)
        # Solve the SVP instance, compute the DSA private key
        computedKey = Babai(svpBasis)
        # Verify the correctness

        if computedKey == correctKey:
            keyNotFound = False
        else:
            i = i+1

    return computedKey


if __name__ == "__main__": 
    findKey(listOfTriplets, correctKey, q)
