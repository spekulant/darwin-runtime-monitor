#!/bin/bash

MEDIUM_THRESHOLD=40
HIGH_THRESHOLD=100

CPU_USAGE=$(top -pid 0 -l 3 -stats cpu | tail -n 1)

CPU_USAGE_INT=$(echo "$CPU_USAGE" | awk '{print int($1)}')

if (( $(echo "$CPU_USAGE_INT >= $HIGH_THRESHOLD" | bc -l) )); then
    osascript -e 'display notification "Consider adjusting your connected devices or closing resource-intensive applications." with title "High Kernel CPU Usage"'
elif (( $(echo "$CPU_USAGE_INT >= $MEDIUM_THRESHOLD" | bc -l) )); then
    osascript -e 'display notification "If you notice performance issues, adjusting connected devices may help." with title "Increased Kernel CPU Usage"'
fi
