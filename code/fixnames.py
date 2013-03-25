from os import *
import sys



for path in sys.argv[1:]:
    l = listdir(path)
    for x in l:
        y = x.lower()
        if x != y:
            rename(path + "/" + x, path + "/" + y)
