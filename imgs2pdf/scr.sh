#!/bin/bash


ruby ./$1 -d imgs -o out.pdf
xdg-open out.pdf
