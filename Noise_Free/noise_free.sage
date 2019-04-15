def sortfn(r, s, k, hm, inp_list):
    out_list = list()
    for i in inp_list:
        t = parser(r, s, k, hm, i)
        for p in t:
            out_list.append(p)
    print(out_list)
    n = len(out_list)
    quickSort(out_list, 0, n - 1)

    print(out_list)
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
                a_list.append((r, s, k, hm, lsb_len, c+1, idash, lsb, temp, idash - (c + 1) + lsb_len))
                total_block_len += len(temp)
            temp = ''
            idash =  c
        else:
            temp = temp + i

    if len(temp) >= 5:
        a_list.append((r, s, k, hm, lsb_len, c+1, idash, lsb, temp, idash - (c + 1) + lsb_len))
        total_block_len += len(temp)

    return a_list

def partition(arr,low,high):
    i = (low - 1)
    pivot = arr[high][4]

    for j in range(low , high):
        if arr[j][4] <= pivot:
            i = i + 1
            arr[i], arr[j] = arr[j], arr[i]

    arr[i + 1], arr[high] = arr[high], arr[i + 1]
    return (i + 1)

def quickSort(arr,low,high):
    if low < high:
        pi = partition(arr,low,high)
        quickSort(arr, low, pi-1)
        quickSort(arr, pi+1, high)


x = ["11001xx10101xx00000", "111111xxx0000000", "1111111110xx00000011", "1001010xxxx11111"]
sortfn('r', 's', 'k', 'h(m)' , x)
