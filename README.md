<h1 align="center">
  🍋 lemon.markets_ex
</h1>
<p align="center">Elixir client for the <a href="https://lemon.markets">lemon.markets</a> API</p>

> ## ⚠️ Open Beta Notice
>
> Note: [lemon.markets](https://lemon.markets) is in open beta and this library is a work in progress. Expect breaking changes until the release of version 1.0.

To get a general understading of the API, please refer to the [official documentation](https://docs.lemon.markets) and the [quickstart guide](https://docs.lemon.markets/quickstart).

## 💻 Installation

The package is currently not available on [hex.pm](https://hex.pm) but can be installed directly from GitHub.

```elixir
def deps do
  [
    {:lemon_markets_ex, github: "daskycodes/lemon.markets_ex"}
  ]
end
```

## 🚀 Getting started

Please refer to the Modules `LemonMarketsEx.Trading` and `LemonMarketsEx.Market` for more details and examples. You can find the documentation [here](https://daskycodes.github.io/lemon.markets_ex).

### 🔐 Configuration

All requests to the API have to be authenticated. You can get your `api_key` from the [lemon.markets dashboard](https://dashboard.lemon.markets/).

You can configure the Elixir API Client by setting them up in the `config.exs`

```elixir
config :lemon_markets_ex,
  api_key: "LEMON_MARKETS_API_KEY",
  trading_api_url: "https://paper-trading.lemon.markets/v1"
```

There are 2 options for the `LEMON_MARKETS_TRADING_API_URL`:

- `"https://paper-trading.lemon.markets/v1"`
- `"https://trading.lemon.markets/v1"`

### 🏦 Your first request

You can check your account information, to make sure you are correctly authenticated.

```elixir
iex> LemonMarketsEx.Trading.get_account()
{:ok,
 %{
   mode: "paper",
   results: %LemonMarketsEx.Account{...},
   status: "ok",
   time: "2021-12-27T19:04:38.710+00:00"
 }}
```

### 📈 Creating an order

#### Finding an instrument

Let's find an `Instrument` we would like to buy:

```elixir
iex>  LemonMarketsEx.Market.get_instruments(search: "AIRBNB", tradable: true)
{:ok,
 %{
   next: nil,
   page: 1,
   pages: 1,
   previous: nil,
   results: [
     %LemonMarketsEx.Instrument{isin: "US0090661010", ...}
   ],
   total: 1
 }}
```

As you can see the function returns an `:ok` tuple with the result as map

```elixir
%{next: nil, previous: nil, page: 1, pages: 1, total: 1, results: [%LemonMarketsEx.Instrument{}]}
```

Please refer to [pagination-in-the-market-data-api](https://docs.lemon.markets/market-data/overview#pagination-in-the-market-data-api)

#### Create a new order

So we've found what we would like to buy. A single stock of `AIRBNB` with the ISIN `"US0090661010"`

To create a new order we need to call the function `LemonMarketsEx.Trading.create_order/1` with the following `params` as second argument:

- `params` - A map of request body params.
  - `isin` (required) - Internation Security Identification Number of the instrument you wish to buy or sell.
  - `expires_at` (required) - ISO String date (YYYY-MM-DD). Order expires at the end of the specified day. Maximum expiration date is 30 days in the future.
  - `side` (required) - With this you can define whether you want to buy (`"buy"`) or sell (`"sell"`) a specific instrument
  - `quantity` (required) - The amount of shares you want to buy. Limited to 1000 per request.
  - `venue` (required) - Market Identifier Code of Stock exchange you want to address. Default value is `"xmun"`. Use `venue: "allday"` for 24/7 order exeution (only in the Paper Money environment).
  - `space_id` (required) - Identification Number of the space you want to place the order with.
  - `stop_price` (optional) - Stop Price for your Order. See: https://docs.lemon.markets/trading/overview#working-with-numbers-in-the-trading-api
  - `limit_price` (optional) - Limit Price for your Order. See: https://docs.lemon.markets/trading/overview#working-with-numbers-in-the-trading-api

```elixir
iex> params = %{
  expires_at: "2021-12-27",
  isin: "US19260Q1076",
  quantity: 1,
  side: "buy",
  space_id: "sp_1337"
}
iex> LemonMarketsEx.Trading.create_order(params)
{:ok,
  %{
  mode: "paper",
  results: %LemonMarketsEx.Order{},
  status: "ok",
  time: "2021-12-26T21:35:55.546+00:00",
}}
```

#### Activate the newly created order

Nice. We successfully created a new order. But it's status is `"inactive"`. That's because we still need to activate the order by calling the `LemonMarketsEx.Trading.activate_order/1` function.

We can simply pass in the `order_id` to the function and activate it.

```elixir
iex> LemonMarketsEx.activate_order(order_id)
{:ok, %{mode: "paper", status: "ok", time: "2021-12-26T22:12:05.023+00:00"}}
```

🥳 Success!

You might have noticed that we do not need to explicitly specify if we would like to create a `market_order`, `stop_order`, `limit_order` or `stop_limit_order`. [lemon.markets](https://lemon.markets) recognizes the type of order automatically. Please refer to [this great blogpost](https://medium.com/lemon-markets/order-types-at-lemon-markets-explained-a52c39852917) about the different types of orders.

## 🤝 Contributing

1. Fork it [daskycodes/lemon.markets_ex](https://github.com/daskycodes/lemon.markets_ex)
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

Copyright (c) 2021 Daniel Khaapamyaki
