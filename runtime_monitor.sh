#!/bin/bash

USER_HOME=$(eval echo "~$USER")

SCRIPT_DIR="$USER_HOME/.runtime-monitor"

"$SCRIPT_DIR/swapusage.sh"
"$SCRIPT_DIR/kernelcpu.sh"
