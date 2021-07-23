#!/bin/sh
# Required: httpie, jq

# Authentication Fixtures
http --multipart https://auth.lemon.markets/oauth2/token client_id="$CLIENT_ID" client_secret="$CLIENT_SECRET" grant_type="client_credentials" > test/fixtures/auth.json

contents="$(jq '.access_token = ""' test/fixtures/auth.json)" && \
echo "${contents}" > test/fixtures/auth.json

# Spaces Fixtures
http $BASE_URL/state "Authorization:Bearer $ACCESS_TOKEN" > test/fixtures/state.json
http $BASE_URL/spaces "Authorization:Bearer $ACCESS_TOKEN" > test/fixtures/spaces.json
http $BASE_URL/spaces/$SPACE_UUID "Authorization:Bearer $ACCESS_TOKEN" > test/fixtures/space.json
http $BASE_URL/spaces/$SPACE_UUID/state "Authorization:Bearer $ACCESS_TOKEN" > test/fixtures/space_state.json
http $BASE_URL/spaces/$SPACE_UUID/portfolio "Authorization:Bearer $ACCESS_TOKEN" > test/fixtures/portfolio.json
http $BASE_URL/spaces/$SPACE_UUID/portfolio/transactions "Authorization:Bearer $ACCESS_TOKEN" > test/fixtures/portfolio_transactions.json
http $BASE_URL/spaces/$SPACE_UUID/transactions "Authorization:Bearer $ACCESS_TOKEN" > test/fixtures/transactions.json
http $BASE_URL/spaces/$SPACE_UUID/transactions/$TRANSACTION_UUID "Authorization:Bearer $ACCESS_TOKEN" > test/fixtures/transaction.json

# Orders Fixtures
CREATE_ORDER_PARAMS='{"isin": "US0090661010", "valid_until": "1626995082", "side": "buy", "quantity": 1}'

http $BASE_URL/spaces/$SPACE_UUID/orders "Authorization:Bearer $ACCESS_TOKEN" > test/fixtures/orders.json
http $BASE_URL/spaces/$SPACE_UUID/orders/$ORDER_UUID "Authorization:Bearer $ACCESS_TOKEN" > test/fixtures/order.json
echo $CREATE_ORDER_PARAMS | http POST $BASE_URL/spaces/$SPACE_UUID/orders "Authorization:Bearer $ACCESS_TOKEN" > test/fixtures/create_order.json

CREATED_ORDER_UUID=cat test/fixtures/create_order.json | jq ".uuid" | sed -e 's/^"//' -e 's/"$//'
http PUT $BASE_URL/spaces/$SPACE_UUID/orders/$CREATED_ORDER_UUID/activate "Authorization:Bearer $ACCESS_TOKEN" > test/fixtures/activate_order.json

# Trading Venues Fixtures
http $BASE_URL/instruments tradable==true search==coinbase type==stock "Authorization:Bearer $ACCESS_TOKEN" > test/fixtures/instruments.json
http $BASE_URL/instruments/US19260Q1076 "Authorization:Bearer $ACCESS_TOKEN" > test/fixtures/instrument.json

http $BASE_URL/trading-venues "Authorization:Bearer $ACCESS_TOKEN" > test/fixtures/trading_venues.json
http $BASE_URL/trading-venues/XMUN "Authorization:Bearer $ACCESS_TOKEN" > test/fixtures/trading_venue.json
http $BASE_URL/trading-venues/XMUN/opening-days "Authorization:Bearer $ACCESS_TOKEN" > test/fixtures/opening_days.json

http $BASE_URL/trading-venues/XMUN/instruments tradable==true search==coinbase type==stock "Authorization:Bearer $ACCESS_TOKEN" > test/fixtures/trading_venue_instruments.json
http $BASE_URL/trading-venues/XMUN/instruments/US19260Q1076 "Authorization:Bearer $ACCESS_TOKEN" > test/fixtures/trading_venue_instrument.json
http $BASE_URL/trading-venues/XMUN/instruments/US19260Q1076/warrants "Authorization:Bearer $ACCESS_TOKEN" > test/fixtures/trading_venue_instrument_warrants.json

# Data Fixtures
DATA_URL=$BASE_URL/trading-venues/XMUN/instruments/US19260Q1076/data

http $DATA_URL/quotes/latest "Authorization:Bearer $ACCESS_TOKEN" > test/fixtures/latest_quote.json
http $DATA_URL/trades/latest "Authorization:Bearer $ACCESS_TOKEN" > test/fixtures/latest_trade.json
http $DATA_URL/ohlc/m1/latest "Authorization:Bearer $ACCESS_TOKEN" > test/fixtures/latest_ohlc_data.json
http $DATA_URL/ohlc/m1 "Authorization:Bearer $ACCESS_TOKEN" ordering=="-date" > test/fixtures/ohlc_data.json
http $DATA_URL/ohlc/m1 "Authorization:Bearer $ACCESS_TOKEN" ordering=="-date" date_until==1626998400.0 date_from==1626912000.0 > test/fixtures/ohlc_data_previous.json
