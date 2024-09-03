with open("words.txt", "r") as fi:
    buff = fi.read().lower().split("\n")
    buff.sort()

    # Verifica se tem palavra repetida
    for i in range(1, len(buff)):
        if(buff[i] == buff[i-1]):
            print("Ha repeticao de", buff[i])

    # Reescreve no arquivo
    with open("words.txt", "w") as fo:
        for line in buff:
            fo.write(line + "\n")