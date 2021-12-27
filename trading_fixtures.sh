#!/bin/sh
# Required: httpie, jq

BASE_URL=https://paper-trading.lemon.markets/v1
ACCESS_TOKEN=GETACCESSTOKEN

# Account Fixtures

## Fetch Account
http $BASE_URL/account "Authorization:Bearer $ACCESS_TOKEN" > test/fixtures/trading/account/account.json

## Fetch Withdrawals
http $BASE_URL/account/withdrawals "Authorization:Bearer $ACCESS_TOKEN" > test/fixtures/trading/account/withdrawals.json

## Create Wihdrawal
CREATE_WITHDRAWAL_PARAMS='{"amount": "1000000", "pin": "1337"}'
echo $CREATE_WITHDRAWAL_PARAMS | http POST $BASE_URL/account/withdrawals "Authorization:Bearer $ACCESS_TOKEN" > test/fixtures/trading/account/create_withdrawal.json
http $BASE_URL/account/bankstatements "Authorization:Bearer $ACCESS_TOKEN" > test/fixtures/trading/account/bankstatements.json

## Fetch Documents
DOCUMENT_ID=GETDOCUMENTID
http $BASE_URL/account/documents "Authorization:Bearer $ACCESS_TOKEN" > test/fixtures/trading/account/documents.json
http $BASE_URL/account/documents/$DOCUMENT_ID"Authorization:Bearer $ACCESS_TOKEN" > test/fixtures/trading/account/document.json

# Order Fixtures

## Fetch Orders
ORDER_ID=GETORDERID
http $BASE_URL/orders "Authorization:Bearer $ACCESS_TOKEN" > test/fixtures/trading/order/orders.json
http $BASE_URL/orders/$ORDER_ID "Authorization:Bearer $ACCESS_TOKEN" > test/fixtures/trading/order/order.json

## Create New Order
CREATED_ORDER_PARAMS='{"expires_at": "2021-12-28", "isin": "US19260Q1076", "quantity": 1, "side": "buy", "space_id": "sp_1337"}'
echo $CREATED_ORDER_PARAMS | http POST $BASE_URL/orders "Authorization:Bearer $ACCESS_TOKEN" > test/fixtures/trading/order/create_order.json

## Activate Order
CREATED_ORDER_ID=cat test/fixtures/create_order.json | jq ".results.uuid" | sed -e 's/^"//' -e 's/"$//'
ACTIVATE_ORDER_PARAMS='{"pin": "1337"}'
echo $ACTIVATE_ORDER_PARAMS | http POST $BASE_URL/orders/$CREATED_ORDER_ID/activate "Authorization:Bearer $ACCESS_TOKEN" > test/fixtures/trading/order/activate_order.json

# Portfolio Fixtures

## Fetch Portfolio
http $BASE_URL/portfolio "Authorization:Bearer $ACCESS_TOKEN" > test/fixtures/trading/portfolio/portfolio.json

# Space Fixtures

## Fetch Spaces
SPACE_ID=GETSPACEID
http $BASE_URL/spaces "Authorization:Bearer $ACCESS_TOKEN" > test/fixtures/trading/spaces/spaces.json
http $BASE_URL/spaces/$SPACE_ID "Authorization:Bearer $ACCESS_TOKEN" > test/fixtures/trading/spaces/space.json

## User Fixtures
http $BASE_URL/user "Authorization:Bearer $ACCESS_TOKEN" > test/fixtures/trading/user/user.json
