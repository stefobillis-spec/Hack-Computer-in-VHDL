data = str(input("enter machine code: "))
length = int(input("enter length: "))


'''j=0
for i in range(length+1):
    print(f'when {i} => data <= "{data[j:j+16]}";')
    j += 16'''


j=0
k=0
for i in range(length+1):
    print(f'"{data[j:j+16]}",', end='')
    j += 16
    k += 1
    if k == 5:
        print()
        k = 0