def sortfn(inp_list):
    out_list = list()
    for i in inp_list:
        t = parser(i[0], i[1], i[2], i[3], i[4])
        for p in t:
            out_list.append(p)

    n = len(out_list)
    quickSort(out_list, 0, n - 1)
    out_list = out_list[::-1]
    for i in range(len(out_list)):
        print(i+1, out_list[i])
    return(out_list)


def parser(r, s, k, hm, string):
    a_list = list()
    j = 0
    temp = ''
    total_block_len = 0
    idash = len(string)
    c = len(string)

    lsb = ''
    for i in reversed(string):
        if i == 'x':
            break
        lsb = lsb + i
    lsb = lsb[::-1]
    lsb_len = len(lsb)

    for i in string[0: -lsb_len]:
        c = c - 1
        if i == 'x':
            if len(temp) >= 5:
                a_list.append((r, s, k, hm, lsb_len, c+1, idash,
                               lsb, temp, idash - (c + 1) + lsb_len))
                total_block_len += len(temp)
            temp = ''
            idash = c
        else:
            temp = temp + i

    if len(temp) >= 5:
        a_list.append((r, s, k, hm, lsb_len, c+1, idash,
                       lsb, temp, idash - (c + 1) + lsb_len))
        total_block_len += len(temp)

    return a_list


def partition(arr, low, high):
    i = (low - 1)
    pivot = arr[high][4]

    for j in range(low, high):
        if arr[j][4] <= pivot:
            i = i + 1
            arr[i], arr[j] = arr[j], arr[i]

    arr[i + 1], arr[high] = arr[high], arr[i + 1]
    return (i + 1)


def quickSort(arr, low, high):
    if low < high:
        pi = partition(arr, low, high)
        quickSort(arr, low, pi-1)
        quickSort(arr, pi+1, high)


x = [('r1', 's1', 'k1', 'hm1', "11001xx10101xx00000"), ('r2', 's2', 'k2', 'hm2', "111111xxx0000000"),
     ('r3', 's3', 'k3', 'hm3', "1111111110xx00000011"), ('r4', 's4', 'k4', 'hm4', "1001010xxxx11111")]
sortfn(x)
