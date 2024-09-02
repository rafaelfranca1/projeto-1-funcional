with open("words.txt", "r") as fi:
    buffer = fi.read().split("\n")
    buffer.sort()
    with open("words.txt", "w") as fo:
        for word in buffer:
            fo.write(word + "\n")