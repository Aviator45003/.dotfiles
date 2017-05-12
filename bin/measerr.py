#!/bin/python3

th = 1
try:
    while th != 0 or m != 0:
        th = float(input("Theoretical: "))
        m = float(input("Measured: "))
        print(abs(round(((th-m)/float(th))*100, 3)))
except:
    print("\nGoodbye\n")
