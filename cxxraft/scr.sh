#!/bin/bash

if [[ -x $1 ]]; then
  ./$1
else
  ruby $1
fi
