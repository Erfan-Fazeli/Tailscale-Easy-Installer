#!/usr/bin/env python3
import json
import urllib.request
import urllib.error
import sys
from typing import Dict, Optional

def get_ip_info() -> Optional[Dict]:
    """Get IP geolocation info from multiple APIs with fallback"""
    
    apis = [
        "http://ip-api.com/json",
        "https://ipapi.co/json", 
        "https://ipinfo.io/json"
    ]
    
    for api in apis:
        try:
            print(f"Trying API: {api}", file=sys.stderr)
            with urllib.request.urlopen(api, timeout=5) as response:
                data = json.loads(response.read().decode())
                
                if not data or response.status != 200:
                    continue
                    
                print(f"✓ Successfully got data from: {api}", file=sys.stderr)
                
                # Parse based on API format
                if api == "http://ip-api.com/json":
                    country = data.get('countryCode', 'XX')
                    region = data.get('regionName', 'UnknownRegion')
                    org = data.get('isp', 'UnknownProvider')
                elif api == "https://ipapi.co/json":
                    country = data.get('country', 'XX')
                    region = data.get('region', 'UnknownRegion')
                    org = data.get('org', 'UnknownProvider')
                else:  # ipinfo.io
                    country = data.get('country', 'XX')
                    region = data.get('region', 'UnknownRegion')
                    org = data.get('org', 'UnknownProvider')
                
                return {
                    'country': country.upper() if len(country) == 2 else 'XX',
                    'region': region,
                    'org': org,
                    'api': api
                }
                
        except Exception as e:
            print(f"✗ Failed with {api}: {str(e)[:100]}", file=sys.stderr)
            continue
    
    print("✗ All APIs failed - using fallback data", file=sys.stderr)
    return {
        'country': 'XX',
        'region': 'UnknownRegion',
        'org': 'UnknownProvider',
        'api': 'fallback'
    }

def main():
    """Get IP geolocation data and output in simple format for shell script parsing"""
    
    # Get IP info from APIs
    data = get_ip_info()
    if not data:
        data = {'country': 'XX', 'region': 'UnknownRegion', 'org': 'UnknownProvider', 'api': 'error'}
    
    # Output simple format that shell script can parse easily
    # Format: COUNTRY-REGION-ORG
    print(f"{data['country']}-{data['region']}-{data['org']}")
    
    # Log detailed info to stderr (won't interfere with shell script parsing)
    print(f"API used: {data['api']}", file=sys.stderr)

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        # Output fallback format that won't break shell script parsing
        print("XX-UnknownRegion-UnknownProvider")
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
