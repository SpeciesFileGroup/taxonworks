#!/bin/bash

>&2 echo "SpecFile, BM1, BM2, BM3"
for f in `find -name "*_spec.rb" | sort`; do
  printf "\n$f"

  BM="$f"
  for i in `seq 3`; do
    
    START_TIME=$(date +%s)
    rspec $f &> /dev/null
    TIME=$[$(date +%s) - START_TIME]

    printf $"\t$TIME"

    BM+=", $TIME"
  done
  >&2 echo $BM
done