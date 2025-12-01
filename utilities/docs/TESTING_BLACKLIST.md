# JWT Blacklist Testing Guide

## рџЋЇ Visual Testing Through Swagger UI

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
1. Click **рџ”“ Authorize** button at the top
2. Paste your token in the "Value" field
3. Click "Authorize" then "Close"
4. You should now see рџ”’ (locked) icon

### Step 4: Test Authenticated Endpoint
1. Find **`GET /api/me`** endpoint
2. Click "Try it out" в†’ "Execute"
3. Should return 200 with your user info вњ…

### Step 5: Sign Out (Blacklist Token)
1. Find **`POST /api/auth/sign_out`** endpoint
2. Click "Try it out" в†’ "Execute"
3. Should return 200 with message: "Successfully signed out" вњ…

### Step 6: Verify Token is Blacklisted
1. Try **`GET /api/me`** again
2. Should return **401 Unauthorized** вќЊ
3. Error: "Invalid or expired token"

### Step 7: Sign In Again
1. Use **`POST /api/auth/sign_in`** with same credentials
2. Get new token (different from first one)
3. New token should work! вњ…

---

## рџ”Ќ Monitoring Redis Blacklist

### View Current Blacklisted Tokens

```bash
# Run the monitor script
bash utilities/scripts/monitor_redis_blacklist.sh
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

## рџ“Љ Expected Results

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

## рџ§Є Testing Scenarios

### Scenario 1: Basic Flow
1. Sign up в†’ Get token A
2. Access /api/me в†’ 200 вњ…
3. Sign out в†’ Token A blacklisted
4. Access /api/me в†’ 401 вќЊ

### Scenario 2: Multiple Sessions
1. Sign up в†’ Get token A
2. Sign in в†’ Get token B (both valid)
3. Sign out with token A в†’ Only A blacklisted
4. Token B still works вњ…

### Scenario 3: Token Expiration
1. Sign up в†’ Get token
2. Sign out в†’ Token blacklisted
3. Wait 24 hours в†’ Token expires naturally
4. Redis auto-deletes blacklist entry (TTL = 0)

---

## рџђ› Troubleshooting

### Swagger shows "Authorization undefined"
- Click рџ”“ Authorize button
- Enter token **without** "Bearer " prefix
- Just paste the raw JWT token

### All requests return 401
- Check if Redis is running: `docker-compose ps`
- Redis should show "Up (healthy)"
- Check logs: `docker-compose logs redis`

### Token still works after sign out
- Check Redis connection: `docker-compose exec web rails runner "puts Rails.application.config.redis.ping"`
- Should return "PONG"
- Check blacklist: `bash utilities/scripts/monitor_redis_blacklist.sh`

### Redis is empty but should have tokens
- Check app logs: `docker-compose logs web | grep -i blacklist`
- May need to restart web service: `docker-compose restart web`

---

## рџ“ќ Quick Test Script

Run this for automated testing:

```bash
# Test blacklist functionality
docker-compose exec web rails runner test_api_blacklist.rb

# Expected output: "ALL API TESTS PASSED вњ“"
```

---

## рџЋ‰ Success Indicators

вњ… Swagger UI loads at http://localhost:3000/api-docs
вњ… Sign up returns token
вњ… Token works for /api/me
вњ… Sign out returns "Successfully signed out"
вњ… Same token gets 401 after sign out
вњ… Sign in returns new working token
вњ… Redis monitor shows blacklist entries with TTL

---

**Happy Testing!** рџљЂ

