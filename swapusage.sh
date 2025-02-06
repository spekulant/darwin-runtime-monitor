#!/bin/bash

MEDIUM_THRESHOLD=512
HIGH_THRESHOLD=1000

output=$(sysctl vm.swapusage)
# sampled outputs:
# vm.swapusage: total = 1024.00M  used = 14.75M  free = 1009.25M  (encrypted)
# vm.swapusage: total = 0.00M  used = 0.00M  free = 0.00M  (encrypted)

used_mb=$(echo "$output" | awk -F'used = ' '{print $2}' | awk '{print $1}' | sed 's/M//')

if (( $(echo "$used_mb >= $HIGH_THRESHOLD" | bc -l) )); then
    osascript -e 'display notification "Swap usage is critically high!" with title "High Swap Usage Alert"'
elif (( $(echo "$used_mb >= $MEDIUM_THRESHOLD" | bc -l) )); then
    osascript -e 'display notification "Swap usage is rising. Consider closing apps." with title "Increased Swap Usage Warning"'
fi
