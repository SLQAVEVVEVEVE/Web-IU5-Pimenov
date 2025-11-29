# JWT Blacklist Testing Guide

## 🎯 Visual Testing Through Swagger UI

### Step 1: Open Swagger UI
Open in browser: **http://localhost:3000/api-docs**

### Step 2: Register New User
1. Find **`POST /api/auth/sign_up`** endpoint
2. Click "Try it out"
3. Enter JSON body:
```json
{
  "email": "test@example.com",
  "password": "password123",
  "password_confirmation": "password123"
}
```
4. Click "Execute"
5. **Copy the `token` from response** - you'll need it!

### Step 3: Authorize in Swagger
1. Click **🔓 Authorize** button at the top
2. Paste your token in the "Value" field
3. Click "Authorize" then "Close"
4. You should now see 🔒 (locked) icon

### Step 4: Test Authenticated Endpoint
1. Find **`GET /api/me`** endpoint
2. Click "Try it out" → "Execute"
3. Should return 200 with your user info ✅

### Step 5: Sign Out (Blacklist Token)
1. Find **`POST /api/auth/sign_out`** endpoint
2. Click "Try it out" → "Execute"
3. Should return 200 with message: "Successfully signed out" ✅

### Step 6: Verify Token is Blacklisted
1. Try **`GET /api/me`** again
2. Should return **401 Unauthorized** ❌
3. Error: "Invalid or expired token"

### Step 7: Sign In Again
1. Use **`POST /api/auth/sign_in`** with same credentials
2. Get new token (different from first one)
3. New token should work! ✅

---

## 🔍 Monitoring Redis Blacklist

### View Current Blacklisted Tokens

```bash
# Run the monitor script
bash monitor_redis_blacklist.sh
```

Output shows:
- All blacklisted token hashes
- TTL (time-to-live) for each token
- Total count
- Redis stats and memory usage

### Real-time Monitoring

```bash
# Watch Redis commands in real-time
docker-compose exec redis redis-cli MONITOR

# In another terminal, make API requests through Swagger
# You'll see Redis SET/GET commands for blacklist operations
```

### Manual Redis Commands

```bash
# Connect to Redis CLI
docker-compose exec redis redis-cli

# List all blacklist keys
KEYS jwt:blacklist:*

# Get TTL for specific key
TTL jwt:blacklist:<hash>

# Count blacklisted tokens
EVAL "return #redis.call('keys', 'jwt:blacklist:*')" 0

# Clear all blacklist (careful!)
redis-cli --scan --pattern "jwt:blacklist:*" | xargs redis-cli DEL
```

---

## 📊 Expected Results

### After Sign Up
- Redis: 0 blacklisted tokens
- Swagger: Token works for all protected endpoints

### After Sign Out
- Redis: 1 blacklisted token (TTL ~86400 sec = 24 hours)
- Swagger: Token returns 401 on all protected endpoints

### After Sign In Again
- Redis: Still 1 old blacklisted token (will auto-expire)
- Swagger: New token works, old token still rejected

---

## 🧪 Testing Scenarios

### Scenario 1: Basic Flow
1. Sign up → Get token A
2. Access /api/me → 200 ✅
3. Sign out → Token A blacklisted
4. Access /api/me → 401 ❌

### Scenario 2: Multiple Sessions
1. Sign up → Get token A
2. Sign in → Get token B (both valid)
3. Sign out with token A → Only A blacklisted
4. Token B still works ✅

### Scenario 3: Token Expiration
1. Sign up → Get token
2. Sign out → Token blacklisted
3. Wait 24 hours → Token expires naturally
4. Redis auto-deletes blacklist entry (TTL = 0)

---

## 🐛 Troubleshooting

### Swagger shows "Authorization undefined"
- Click 🔓 Authorize button
- Enter token **without** "Bearer " prefix
- Just paste the raw JWT token

### All requests return 401
- Check if Redis is running: `docker-compose ps`
- Redis should show "Up (healthy)"
- Check logs: `docker-compose logs redis`

### Token still works after sign out
- Check Redis connection: `docker-compose exec web rails runner "puts Rails.application.config.redis.ping"`
- Should return "PONG"
- Check blacklist: `bash monitor_redis_blacklist.sh`

### Redis is empty but should have tokens
- Check app logs: `docker-compose logs web | grep -i blacklist`
- May need to restart web service: `docker-compose restart web`

---

## 📝 Quick Test Script

Run this for automated testing:

```bash
# Test blacklist functionality
docker-compose exec web rails runner test_api_blacklist.rb

# Expected output: "ALL API TESTS PASSED ✓"
```

---

## 🎉 Success Indicators

✅ Swagger UI loads at http://localhost:3000/api-docs
✅ Sign up returns token
✅ Token works for /api/me
✅ Sign out returns "Successfully signed out"
✅ Same token gets 401 after sign out
✅ Sign in returns new working token
✅ Redis monitor shows blacklist entries with TTL

---

**Happy Testing!** 🚀
