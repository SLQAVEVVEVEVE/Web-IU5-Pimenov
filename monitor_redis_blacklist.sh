#!/bin/bash
# Redis JWT Blacklist Monitor

echo "=========================================="
echo "Redis JWT Blacklist Monitor"
echo "=========================================="
echo ""

# Get all blacklist keys
echo "📋 Blacklisted tokens:"
echo "---"
docker-compose exec -T redis redis-cli KEYS "jwt:blacklist:*" | while read key; do
  if [ ! -z "$key" ]; then
    ttl=$(docker-compose exec -T redis redis-cli TTL "$key" | tr -d '\r')
    echo "Key: $key"
    echo "  TTL: $ttl seconds (~$((ttl / 3600)) hours remaining)"
    echo ""
  fi
done

# Count total
count=$(docker-compose exec -T redis redis-cli KEYS "jwt:blacklist:*" | grep -c "jwt:blacklist:" || echo "0")
echo "---"
echo "Total blacklisted tokens: $count"
echo ""

# Show Redis stats
echo "📊 Redis Stats:"
echo "---"
docker-compose exec -T redis redis-cli INFO stats | grep -E "total_connections_received|total_commands_processed|keyspace_hits|keyspace_misses"
echo ""

# Show memory
echo "💾 Memory Usage:"
echo "---"
docker-compose exec -T redis redis-cli INFO memory | grep -E "used_memory_human|used_memory_peak_human"
echo ""

echo "=========================================="
echo "💡 Real-time monitoring:"
echo "   docker-compose exec redis redis-cli MONITOR"
echo ""
echo "🔍 Watch blacklist count:"
echo "   watch -n 1 'docker-compose exec redis redis-cli KEYS \"jwt:blacklist:*\" | wc -l'"
echo "=========================================="
