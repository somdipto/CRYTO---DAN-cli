#!/bin/bash

# Delta Exchange API Test Script
# Tests API credentials and documents exact requirements

API_KEY="9dpLVuJ4oq4dSaBkwcZGdObJqkbzSX"
API_SECRET="WZsSyGj4VuB1re6SvG1jg7B17Geug4TetbrbJcxlQqiFUx7BV6W4ugFpS8qa"
BASE_URL="https://api.delta.exchange"

echo "🧪 Delta Exchange API Verification"
echo "=================================================="

# Function to generate signature
generate_signature() {
    local method=$1
    local path=$2
    local body=$3
    local timestamp=$4
    local message="${method}${path}${body}${timestamp}"
    echo -n "$message" | openssl dgst -sha256 -hmac "$API_SECRET" -hex | cut -d' ' -f2
}

# Test 1: Get account balance
echo ""
echo "1. Testing Account Balance..."
TIMESTAMP=$(date +%s)
SIGNATURE=$(generate_signature "GET" "/v2/wallet/balances" "" "$TIMESTAMP")

RESPONSE=$(curl -s -w "HTTPSTATUS:%{http_code}" \
  -H "Content-Type: application/json" \
  -H "api-key: $API_KEY" \
  -H "signature: $SIGNATURE" \
  -H "timestamp: $TIMESTAMP" \
  "$BASE_URL/v2/wallet/balances")

HTTP_STATUS=$(echo $RESPONSE | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
BODY=$(echo $RESPONSE | sed -e 's/HTTPSTATUS\:.*//g')

echo "   Status: $HTTP_STATUS"
if [ "$HTTP_STATUS" -eq 200 ]; then
    echo "   ✅ Success: API connection working!"
    echo "   Response: $BODY" | head -c 200
    echo "..."
else
    echo "   ❌ Error: $BODY"
fi

# Test 2: Get products (public endpoint)
echo ""
echo "2. Testing Products (Public)..."
TIMESTAMP=$(date +%s)
SIGNATURE=$(generate_signature "GET" "/v2/products" "" "$TIMESTAMP")

RESPONSE=$(curl -s -w "HTTPSTATUS:%{http_code}" \
  -H "Content-Type: application/json" \
  -H "api-key: $API_KEY" \
  -H "signature: $SIGNATURE" \
  -H "timestamp: $TIMESTAMP" \
  "$BASE_URL/v2/products")

HTTP_STATUS=$(echo $RESPONSE | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
BODY=$(echo $RESPONSE | sed -e 's/HTTPSTATUS\:.*//g')

echo "   Status: $HTTP_STATUS"
if [ "$HTTP_STATUS" -eq 200 ]; then
    echo "   ✅ Success: Products endpoint working!"
    # Count products
    PRODUCT_COUNT=$(echo "$BODY" | grep -o '"symbol"' | wc -l)
    echo "   Found: ~$PRODUCT_COUNT products available"
else
    echo "   ❌ Error: $BODY"
fi

echo ""
echo "=================================================="
echo "📋 Delta Exchange API Requirements:"
echo "   • Base URL: https://api.delta.exchange"
echo "   • Authentication: HMAC-SHA256"
echo "   • Required Headers:"
echo "     - Content-Type: application/json"
echo "     - api-key: [your API key]"
echo "     - signature: [HMAC signature]"
echo "     - timestamp: [Unix timestamp]"
echo "   • Signature Format: METHOD + PATH + BODY + TIMESTAMP"
echo "   • Hash Algorithm: SHA256"
echo ""
echo "✅ Your API credentials are configured!"
echo "🚀 Ready for DANTO integration!"
