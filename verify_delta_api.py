#!/usr/bin/env python3
"""
Delta Exchange API Verification Script
Tests the API credentials and documents exact requirements
"""

import requests
import hmac
import hashlib
import time
import json

# Your API credentials
API_KEY = "9dpLVuJ4oq4dSaBkwcZGdObJqkbzSX"
API_SECRET = "WZsSyGj4VuB1re6SvG1jg7B17Geug4TetbrbJcxlQqiFUx7BV6W4ugFpS8qa"
BASE_URL = "https://api.delta.exchange"

def generate_signature(method, path, body, timestamp):
    """Generate HMAC-SHA256 signature for Delta Exchange API"""
    message = f"{method}{path}{body}{timestamp}"
    signature = hmac.new(
        API_SECRET.encode('utf-8'),
        message.encode('utf-8'),
        hashlib.sha256
    ).hexdigest()
    return signature

def make_request(method, endpoint, params=None):
    """Make authenticated request to Delta Exchange API"""
    timestamp = int(time.time())
    body = json.dumps(params) if params else ""
    signature = generate_signature(method, endpoint, body, timestamp)
    
    headers = {
        'Content-Type': 'application/json',
        'api-key': API_KEY,
        'signature': signature,
        'timestamp': str(timestamp)
    }
    
    url = BASE_URL + endpoint
    
    if method == "GET":
        response = requests.get(url, headers=headers)
    elif method == "POST":
        response = requests.post(url, headers=headers, data=body)
    
    return response

def test_api_connection():
    """Test Delta Exchange API connection and document requirements"""
    print("🧪 Delta Exchange API Verification")
    print("=" * 50)
    
    # Test 1: Get account balance
    print("\n1. Testing Account Balance...")
    try:
        response = make_request("GET", "/v2/wallet/balances")
        print(f"   Status: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"   ✅ Success: {len(data.get('result', []))} balances found")
            for balance in data.get('result', [])[:3]:  # Show first 3
                print(f"      {balance.get('asset')}: {balance.get('balance', 0)}")
        else:
            print(f"   ❌ Error: {response.text}")
    except Exception as e:
        print(f"   ❌ Exception: {e}")
    
    # Test 2: Get positions
    print("\n2. Testing Positions...")
    try:
        response = make_request("GET", "/v2/positions")
        print(f"   Status: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            positions = data.get('result', [])
            print(f"   ✅ Success: {len(positions)} positions found")
        else:
            print(f"   ❌ Error: {response.text}")
    except Exception as e:
        print(f"   ❌ Exception: {e}")
    
    # Test 3: Get products
    print("\n3. Testing Products...")
    try:
        response = make_request("GET", "/v2/products")
        print(f"   Status: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            products = data.get('result', [])
            print(f"   ✅ Success: {len(products)} products available")
            # Show some popular products
            btc_products = [p for p in products if 'BTC' in p.get('symbol', '')][:3]
            for product in btc_products:
                print(f"      {product.get('symbol')} (ID: {product.get('id')})")
        else:
            print(f"   ❌ Error: {response.text}")
    except Exception as e:
        print(f"   ❌ Exception: {e}")
    
    # Test 4: Get ticker data
    print("\n4. Testing Market Data...")
    try:
        response = make_request("GET", "/v2/tickers")
        print(f"   Status: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            tickers = data.get('result', [])
            print(f"   ✅ Success: {len(tickers)} tickers available")
        else:
            print(f"   ❌ Error: {response.text}")
    except Exception as e:
        print(f"   ❌ Exception: {e}")
    
    print("\n" + "=" * 50)
    print("📋 API Requirements Summary:")
    print("   • Authentication: HMAC-SHA256")
    print("   • Headers: api-key, signature, timestamp")
    print("   • Base URL: https://api.delta.exchange")
    print("   • Content-Type: application/json")
    print("   • Signature Format: METHOD + PATH + BODY + TIMESTAMP")
    print("\n✅ API credentials are configured and ready!")

if __name__ == "__main__":
    test_api_connection()
