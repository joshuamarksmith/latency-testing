#!/bin/bash

# Quick script to test latency
# @author joshuamsmith

TIMESTAMP=$(date +%s)
OUTPUT=results_$TIMESTAMP.csv
TESTNUM=10
DESTINATION=YOUR_URL_HERE

echo How many tests?
read TESTNUM

# Run tests
echo Testing connection....
for i in $(seq 1 $TESTNUM);
        do curl -s -k -w "%{time_total}\n" -o /dev/null $DESTINATION
        done > $OUTPUT

# Calculate averages
AVG=$(awk '{ total += $1; count++ } END { print total/count }' $OUTPUT)

echo Output is in $OUTPUT
echo Average request time: $AVG.
