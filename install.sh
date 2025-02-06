#!/bin/bash

set -e

if [ -z "$USER" ]; then
    echo "❌ USER environment variable must be set."
    exit 1
fi

USER_HOME=$(eval echo "~$USER")
INSTALL_DIR="$USER_HOME/.runtime-monitor"
PLIST_PATH="$USER_HOME/Library/LaunchAgents/com.darwinruntime.monitor.plist"

# Unload and remove previous installation if exists
launchctl unload "$PLIST_PATH" 2>/dev/null
rm -rf "$INSTALL_DIR"

mkdir -p "$INSTALL_DIR"

cp README.md LICENSE "$INSTALL_DIR/"

find . -name "*.sh" ! -name "install.sh" -exec cp {} "$INSTALL_DIR/" \;
chmod +x "$INSTALL_DIR/"*.sh

# Replace $USER with the actual username - launchd doesn't expand ~
sed "s|\$USER|$USER|g" com.darwinruntime.monitor.plist > "$INSTALL_DIR/com.darwinruntime.monitor.plist"

# Remove old symlink before linking new one
rm -f "$PLIST_PATH"
ln -s "$INSTALL_DIR/com.darwinruntime.monitor.plist" "$PLIST_PATH"
chmod 644 "$PLIST_PATH"

# Register the plist with launchd
launchctl load "$PLIST_PATH"

echo "✅ Darwin Runtime Monitor installed successfully!"
echo "It will run every 15 minutes while your Mac is awake."
