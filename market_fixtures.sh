#!/bin/sh
# Required: httpie, jq

BASE_URL=https://data.lemon.markets/v1
ACCESS_TOKEN=GETAPIKEY

# Venues Fixtures

http $BASE_URL/venues "Authorization:Bearer $ACCESS_TOKEN" > test/fixtures/market/venues.json

# Instruments Fixtures

http $BASE_URL/instruments search==shopify tradable==true "Authorization:Bearer $ACCESS_TOKEN" > test/fixtures/market/instruments.json

# Trades Fixtures

http $BASE_URL/trades isin==US19260Q1076 "Authorization:Bearer $ACCESS_TOKEN" > test/fixtures/market/trades.json

# Quotes Fixtures

http $BASE_URL/quotes isin==US19260Q1076 "Authorization:Bearer $ACCESS_TOKEN" > test/fixtures/market/quotes.json

# OHLC Fixtures

http $BASE_URL/ohlc/m1 isin==US19260Q1076  "Authorization:Bearer $ACCESS_TOKEN" > test/fixtures/market/ohlc.json
