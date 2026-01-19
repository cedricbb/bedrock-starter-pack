#!/usr/bin/env bash

set -e

# Charger les variables d'environnement
if [ -f .env ]; then
    source .env
else
    echo "❌ .env file not found"
    exit 1
fi

PROJECT_NAME=${PROJECT_NAME:-myproject}
DOMAIN="${PROJECT_NAME}.arxama.local"

ACTION=${1:-add}

case "$ACTION" in
    add)
        if grep -q "$DOMAIN" /etc/hosts 2>/dev/null; then
            echo "⚠️  Entry already exists in /etc/hosts"
        else
            echo "📝 Adding $DOMAIN to /etc/hosts..."
            echo "127.0.0.1 $DOMAIN" | sudo tee -a /etc/hosts > /dev/null
            echo "✅ Added $DOMAIN to /etc/hosts"
        fi
        ;;
    remove)
        if grep -q "$DOMAIN" /etc/hosts 2>/dev/null; then
            echo "🗑️  Removing $DOMAIN from /etc/hosts..."
            sudo sed -i "/$DOMAIN/d" /etc/hosts
            echo "✅ Removed $DOMAIN from /etc/hosts"
        else
            echo "⚠️  Entry not found in /etc/hosts"
        fi
        ;;
    *)
        echo "Usage: $0 {add|remove}"
        echo ""
        echo "  add    - Add entry to /etc/hosts"
        echo "  remove - Remove entry from /etc/hosts"
        exit 1
        ;;
esac
