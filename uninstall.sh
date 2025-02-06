#!/bin/bash

USER_HOME=$(eval echo "~$USER")
PLIST_PATH="$USER_HOME/Library/LaunchAgents/com.darwinruntime.monitor.plist"
INSTALL_DIR="$USER_HOME/.runtime-monitor"

launchctl unload "$PLIST_PATH" 2>/dev/null
echo "(1/3) Darwin Runtime Monitor unloaded from Launchd successfully."

if [ -L "$PLIST_PATH" ]; then
    rm "$PLIST_PATH"
fi
echo "(2/3) Launchd plist symlink removed successfully."

rm -rf "$INSTALL_DIR"
echo "(3/3) Darwin Runtime Monitor files removed successfully."

echo "✅ System Health Agent uninstalled successfully."
