#!/bin/bash
# Quick Redis Blacklist Checker

echo "🔍 Current Blacklist Status:"
echo ""

# Get count
COUNT=$(docker-compose exec -T redis redis-cli KEYS "jwt:blacklist:*" | grep -c "jwt:blacklist:" || echo "0")

if [ "$COUNT" = "0" ]; then
  echo "✓ No tokens currently blacklisted"
  echo "  (This is normal if no one has signed out recently)"
else
  echo "📋 Found $COUNT blacklisted token(s):"
  echo ""

  docker-compose exec -T redis redis-cli KEYS "jwt:blacklist:*" | while read key; do
    if [ ! -z "$key" ]; then
      ttl=$(docker-compose exec -T redis redis-cli TTL "$key" | tr -d '\r')
      hours=$((ttl / 3600))
      mins=$(((ttl % 3600) / 60))
      echo "  • Token hash: ${key#jwt:blacklist:}" | cut -c1-60
      echo "    Expires in: ${hours}h ${mins}m"
      echo ""
    fi
  done
fi

echo "---"
echo "💡 To monitor in real-time:"
echo "   docker-compose exec redis redis-cli MONITOR"
