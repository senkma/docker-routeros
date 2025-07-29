#!/bin/bash

# RouterOS Production Deployment Script
# This script deploys RouterOS to production server

set -e

ROUTEROS_VERSION=${ROUTEROS_VERSION:-"7.16.1"}
COMPOSE_FILE=${COMPOSE_FILE:-"docker-compose.prod.yml"}

echo "🚀 Deploying RouterOS v${ROUTEROS_VERSION} to production..."

# Check if running as root or with sudo
if [[ $EUID -eq 0 ]]; then
    echo "⚠️  Running as root. Consider using a dedicated user for deployment."
fi

# Check system requirements
echo "🔍 Checking system requirements..."

# Check for KVM support
if [ -e /dev/kvm ]; then
    echo "✅ KVM device found"
else
    echo "❌ KVM device not found. Installing qemu-kvm..."
    apt update && apt install -y qemu-kvm
    modprobe kvm
fi

# Check for TUN device
if [ -e /dev/net/tun ]; then
    echo "✅ TUN device found"
else
    echo "❌ TUN device not found. Loading tun module..."
    modprobe tun
fi

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Please install Docker first."
    exit 1
fi

# Check docker-compose
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null 2>&1; then
    echo "❌ docker-compose not found. Installing..."
    apt update && apt install -y docker-compose-plugin
fi

# Use docker compose if available, fallback to docker-compose
if docker compose version &> /dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
else
    COMPOSE_CMD="docker-compose"
fi

# Create backup directory
mkdir -p ./backups

# Stop existing container if running
echo "🛑 Stopping existing RouterOS container..."
$COMPOSE_CMD -f $COMPOSE_FILE down || true

# Build and start new container
echo "🔨 Building RouterOS container..."
export ROUTEROS_VERSION=$ROUTEROS_VERSION
$COMPOSE_CMD -f $COMPOSE_FILE build --build-arg ROUTEROS_VERSION=$ROUTEROS_VERSION

echo "🚀 Starting RouterOS container..."
$COMPOSE_CMD -f $COMPOSE_FILE up -d

# Wait for container to be ready
echo "⏳ Waiting for RouterOS to start..."
sleep 30

# Health check
if docker ps | grep -q routeros-prod; then
    echo "✅ RouterOS deployed successfully!"
    echo ""
    echo "📋 Production Access Information:"
    echo "   SSH:        ssh admin@$(hostname -I | awk '{print $1}') -p 2222"
    echo "   API:        $(hostname -I | awk '{print $1}'):8728"
    echo "   Web:        http://$(hostname -I | awk '{print $1}'):8080"
    echo "   Winbox:     $(hostname -I | awk '{print $1}'):8291"
    echo ""
    echo "🔑 Default credentials: admin / (no password)"
    echo "📊 View logs: $COMPOSE_CMD -f $COMPOSE_FILE logs -f"
    echo "🛑 Stop: $COMPOSE_CMD -f $COMPOSE_FILE down"
else
    echo "❌ Deployment failed. Check logs:"
    $COMPOSE_CMD -f $COMPOSE_FILE logs
    exit 1
fi
