#!/bin/bash

echo "============================"
echo "  🖥️ OS Version Information"
echo "============================"
if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "OS: $PRETTY_NAME"
else
    uname -a
fi

echo ""
echo "======================================"
echo "  👤 Users with Bash Shell Access"
echo "======================================"
grep '/bash$' /etc/passwd | cut -d: -f1

echo ""
echo "======================"
echo "  🔓 Open Ports"
echo "======================"
if command -v ss &>/dev/null; then
    ss -tuln
elif command -v netstat &>/dev/null; then
    netstat -tuln
else
    echo "Neither ss nor netstat command found."
fi
