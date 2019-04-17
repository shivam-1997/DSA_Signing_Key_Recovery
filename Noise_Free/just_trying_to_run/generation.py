from Crypto.Random import random
from Crypto.PublicKey import DSA
from Crypto.Hash import SHA
from parse import *
# from fpylll import *

def bytes_to_int(bytes):
    result = 0
    for b in bytes:
        result = result * 256 + int(b)
    return result


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
    i = 0
    x01_sequence = ''
    while i < n:
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
                if i+j == n:
                    break
                short_string = short_string + string[i+j]
                count += 1
            x01_sequence = x01_sequence + find_x01_sequence_util(short_string)
            # print(short_string,find_x01_sequence_util(short_string))
            i = i + count
    # print(x01_sequence)
    return x01_sequence

# find_x01_sequence('110010111000010100000011100110')

def generate():
    #create a  new DSA key
    key = DSA.generate(int(1024 ))

    # subgroup order is q
    f = open("./files/q.pem", "w")
    # print(key.q)
    f.write(str(key.q))
    f.close()

    # public_key is y
    f = open("./files/public_key.pem", "w")
    # print(key.y)
    f.write(str(key.y))
    f.close()

    # private key x
    f = open("./files/private_key.pem", "w")
    # print(hex(key.x))
    hex_key = hex(key.x)
    hex_key = hex_key.rstrip('L')
    hex_key = hex_key.lstrip('0x')
    f.write(str(key.x))
    f.close()

    # print(convert(key.x))
    message = b"Hello"
    bigList = []
    h = SHA.new(message).digest()
    h = bytes_to_int(h)
    for i in range(150):
        k = random.StrongRandom().randint(int(1), int(key.q-1))
        sig = key.sign(h, k)
        # S = (r-0, s-1, k-2, h(m)-3, l_a-4, l_b-5, l_c-6, a -7, c-8, number of bits leaked-9)
        # print h
        shortList = [sig[0], sig[1], k, h]
        bigList.append(shortList)

    print('list generated')
    EKOs_list = sortfn(bigList)
    print('EKOs generated and sorted')
    with open("./files/list.csv", "w") as f:
        for i in EKOs_list:
            print(i[0], i[1], i[2], i[3], i[4], i[5], i[6], i[7], i[8], i[9], file=f, sep=',')

    print('Files written to disk')


if __name__ == "__main__":
    generate()
