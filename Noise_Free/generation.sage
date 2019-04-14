from Crypto.Random import random
from Crypto.PublicKey import DSA
from Crypto.Hash import SHA

def find_x01_sequence_util(n):
    n = n[::-1]
    flag = 0
    sm = ''
    for i in n:
        if flag == 0:
            sm = sm + i
            if i == '1':
                flag = 1
        else: 
            sm = sm + 'x'
    return (sm[::-1])

def find_x01_sequence(string):
    n = len(string)
    i=0
    x01_sequence = ''
    while i<n:        
        if string[i] == '0':
            count = 0
            flag_non_zero = 0
            short_string = ''
            for j in range(4):
                if i+j == n:
                    break
                if string[i+j] != '0':
                    flag_non_zero = 1
                    break
                
                count += 1
            if flag_non_zero == 1:
                x01_sequence += 'x'
            else:
                x01_sequence += '0'*count
            i = i + count
        else:
            count = 0
            short_string = ''
            for j in range(4):
                if i+j==n:
                    break
                short_string = short_string + string[i+j]
                count += 1
            x01_sequence = x01_sequence + find_x01_sequence_util(short_string)
            # print(short_string,find_x01_sequence_util(short_string))
            i = i + count 
    # print(x01_sequence)
    return x01_sequence

# find_x01_sequence('110010111000010100000011100110')

def convert(k):
    num = []
    EK = []
    # here by default window_size is considered to be 4
    while k > 0:
        rem = k%16
        k = k//16
        if rem == 0:
            EK.append('0000')
            num.append(0)
        elif rem == 1:
            EK.append('0001')
            num.append(1)
        elif rem == 2:
            EK.append('0010')
            num.append(2)
        elif rem == 3:
            EK.append('0011')
            num.append(3)
        elif rem == 4:
            EK.append('0100')
            num.append(4)
        elif rem == 5:
            EK.append('0101')
            num.append(5)
        elif rem == 6:
            EK.append('0110')
            num.append(6)
        elif rem == 7:
            EK.append('0111')
            num.append(7)
        elif rem == 8:
            EK.append('1000')
            num.append(8)
        elif rem == 9:
            EK.append('1001')
            num.append(9)
        elif rem == 10:
            EK.append('1010')
            num.append('a')
        elif rem == 11:
            EK.append('1011')
            num.append('b')
        elif rem == 12:
            EK.append('1100')
            num.append('c')
        elif rem == 13:
            EK.append('1101')
            num.append('d')
        elif rem == 14:
            EK.append('1110')
            num.append('e')
        elif rem == 15:
            EK.append('1111')
            num.append('f')
   
    num.reverse()
    # print(num)
    EK.reverse()
    # print(EK)
    ek_str = ''
    for i in EK:
        ek_str  = ek_str + i
    x01_seq = find_x01_sequence(ek_str)
    return x01_seq

def generate():
    #create a  new DSA key
    key = DSA.generate(int(1024))

    # subgroup order is q
    f = open("q.pem", "w")
    print(key.q)
    f.write(str(key.q))
    f.close()

    # public_key is y
    f = open("public_key.pem", "w")
    print(key.y)
    f.write(str(key.y))
    f.close()

    # private key x
    f = open("private_key.pem", "w")
    print(hex(key.x))
    hex_key = hex(key.x)
    hex_key = hex_key.rstrip('L')
    hex_key = hex_key.lstrip('0x')
    f.write(str(key.x))
    f.close()

    # print(convert(key.x))
    message = b"Hello"
    bigList = []
    h = SHA.new(message).digest()
    with open("r_s_k_h.csv", "w") as f:
        for i in range(150):
            k = random.StrongRandom().randint(int(1), int(key.q-1))
            sig = key.sign(h, k)
            # S = (r-0, s-1, k-2, h(m)-3, l_a-4, l_b-5, l_c-6, a -7, c-8, number of bits leaked-9)
            print h
            shortList = [sig[0]*1.0, sig[1]*1.0, k, h, convert(k)]
            bigList.append(shortList)
        
if __name__ == "__main__":
    generate()
