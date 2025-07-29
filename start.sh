#!/bin/bash

# RouterOS Docker Startup Script
# This script helps you start RouterOS locally with proper system checks

set -e

echo "🚀 Starting RouterOS Docker Container..."

# Check if running on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo "⚠️  Warning: This container is designed for Linux. You may experience issues on other platforms."
fi

# Check for KVM support
if [ -e /dev/kvm ]; then
    echo "✅ KVM device found - hardware acceleration will be available"
else
    echo "⚠️  KVM device not found - running in emulation mode (slower)"
    echo "   To enable KVM on Ubuntu/Debian: sudo apt install qemu-kvm"
    echo "   Make sure your user is in the 'kvm' group: sudo usermod -a -G kvm $USER"
fi

# Check for TUN device
if [ -e /dev/net/tun ]; then
    echo "✅ TUN device found"
else
    echo "❌ TUN device not found - container may not work properly"
    echo "   Try: sudo modprobe tun"
fi

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running or not accessible"
    echo "   Make sure Docker is installed and running"
    exit 1
fi

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null 2>&1; then
    echo "❌ docker-compose not found"
    echo "   Install with: sudo apt install docker-compose"
    exit 1
fi

echo "🔨 Building RouterOS v7.19.4 container..."

# Use docker compose if available, fallback to docker-compose
if docker compose version &> /dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
else
    COMPOSE_CMD="docker-compose"
fi

# Build and start the container
$COMPOSE_CMD up --build -d

echo "⏳ Waiting for RouterOS to start..."
sleep 10

# Check if container is running
if docker ps | grep -q routeros-local; then
    echo "✅ RouterOS container is running!"
    echo ""
    echo "📋 Connection Information:"
    echo "   SSH:        ssh admin@localhost -p 2222"
    echo "   Telnet:     telnet localhost 2223"
    echo "   HTTP:       http://localhost:8080"
    echo "   HTTPS:      https://localhost:8443"
    echo "   API:        localhost:8728"
    echo "   API SSL:    localhost:8729"
    echo "   VNC:        localhost:5900"
    echo "   Winbox:     localhost:8291"
    echo ""
    echo "🔑 Default credentials: admin / (no password)"
    echo ""
    echo "📊 To view logs: $COMPOSE_CMD logs -f"
    echo "🛑 To stop: $COMPOSE_CMD down"
else
    echo "❌ Container failed to start. Check logs with: $COMPOSE_CMD logs"
    exit 1
fi
