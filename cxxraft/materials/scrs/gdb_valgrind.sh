#!/bin/bash

g++ -g $1
valgrind --leak-check=full -track-origins=yes --vgdb-error=0 ./a.out &
gdb a.out
