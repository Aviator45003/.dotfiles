#!/bin/python3

try:
    while True:
        th = float(input("Theoretical: "))
        m = float(input("Measured: "))
        print(((th-m)/th)*100)
except:
    print("\nGoodbye\n")
