<h1 align="center">
  🍋 lemon.markets_ex
</h1>
<p align="center">Elixir client for the <a href="https://lemon.markets">lemon.markets</a> API</p>


> Note: [lemon.markets](https://lemon.markets) is in closed beta and this library is a work in progress. Expect breaking changes until the release of version 1.0.

To get a general understading of the API, please refer to the [official documentation](https://docs.lemon.markets) and the [getting started guide](https://docs.lemon.markets/signing-up-getting-access).

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


Please refer to the Modules "`LemonMarketsEx.Authentication`, `LemonMarketsEx.Data`, `LemonMarketsEx.Orders`, `LemonMarketsEx.Spaces` and `LemonMarketsEx.TradingVenues` for more details and examples. You can find the documenataion [here](https://daskycodes.github.io/lemon.markets_ex).

### 🔐 Authentication

Most requests require authentication. To get started, you need to create a client instance.
Every client is scoped to a specific space and has predefined permissions.

You can get your client credentials from your [dashboard](https://dashboard.lemon.markets).

```elixir
{:ok, %LemonMarketsEx.Client{} = client} =
  LemonMarketsEx.authenticate(
    YOUR_CLIENT_ID,
    YOUR_CLIENT_SECRET,
    "https://super-secret.lemon.markets/rest/v1"
  )
```

### 🏦 Your first request

You can check your state, the balance of your state as well as how much cash you have left to invest.

```elixir
{:ok,
  %LemonMarketsEx.State{
    cash_account_number: nil,
    securities_account_number: nil,
    state: %{balance: "100000.0000"}
  }} = LemonMarketsEx.get_state(client)
```

### 📈 Creating an order

#### Finding an instrument

Let's find a `Instrument` we would like to buy:

You can pass in the query parameters as a keyword list or map.

```elixir
iex> LemonMarketsEx.get_instruments(client, search: "AIRBNB", type: "stock")
{:ok,
  %{
    next: nil,
    previous: nil,
    results: [
      %LemonMarketsEx.Instrument{
        currency: "EUR",
        isin: "US0090661010",
        name: "AIRBNB INC. DL-,01",
        symbol: "6Z1",
        title: "AIRBNB INC.",
        tradable: true,
        trading_venues: [%{mic: "XMUN", title: "Gettex"}],
        type: "stock",
        wkn: "A2QG35"
      }
    ]
  }}
```

As you can see the function returns an `:ok` tuple with the result as map `%{next: nil, previous: nil, results: [%LemonMarketsEx.Instrument{}]}`. Please refer to the [Pagionation](#pagination) section on how to paginate through records.

#### Create a new order

So we've found what we would like to buy. A single stock of `AIRBNB`.

To create a new order we need to call the function `LemonMarketsEx.create_order/2` with the `create_order_params` as second argument:

* `create_order_params` - A map of query parameters to create the order.
  * `isin` (required) - ISIN of an instrument.
  * `valid_until` (required) - UTC UNIX Timestamp in seconds or JS Timestamp (see [here](https://docs.lemon.markets/pagination-numbers)). Can be any date in the future.
  * `side` (required) - `"buy"` or `"sell"`.
  * `quantity` (required) - The amount of shares you want to buy.
  * `stop_price` (optional) - See [here](https://docs.lemon.markets/pagination-numbers) for information on numbers format.
  * `limit_price` (optional) - See [here](https://docs.lemon.markets/pagination-numbers) for information on numbers format.

```elixir
iex> valid_until = valid_until = :os.system_time(:seconds) + 360
iex> create_order_params = %{isin: "US0090661010", valid_until: valid_until, side: "buy", quantity: 1}
iex> order = LemonMarketsEx.create_order(client, create_order_params)
{:ok,
  %LemonMarketsEx.Order{
    average_price: nil,
    created_at: nil,
    instrument: %{isin: "US0090661010", title: nil},
    limit_price: nil,
    processed_at: nil,
    processed_quantity: nil,
    quantity: 1,
    side: "buy",
    status: "inactive",
    stop_price: nil,
    trading_venue_mic: "XMUN",
    type: nil,
    uuid: "0f91b8f4-8524-4692-a26c-586a800570ae",
    valid_until: 1626809265.0
  }}
```

#### Activate the newly created order

Nice. We successfully created a new order. But it's status is `"inactive"`. That's because we still need to activate the order by calling the `LemonMarketsEx.activate_order/2` function.
The second argument can either be the newly created `%Order{}` struct or just the `order_uuid`:

```elixir
iex> order = %Order{uuid: "0f91b8f4-8524-4692-a26c-586a800570ae"}
iex> LemonMarketsEx.Spaces.activate_order(client, order)
{:ok, %{status: "activated"}}

iex> order = "0f91b8f4-8524-4692-a26c-586a800570ae"
iex> LemonMarketsEx.Spaces.activate_order(client, order)
{:ok, %{status: "activated"}}
```

🥳 Success!

You might have noticed that we do not need to explicitly specify if we would like to create a `market_order`, `stop_order`, `limit_order` or `stop_limit_order`. [lemon.markets](https://lemon.markets) recognizes the type of order automatically. Please refer to [this great blogpost](https://medium.com/lemon-markets/order-types-at-lemon-markets-explained-a52c39852917) about the different types of orders.

### 📄 Pagination

Most collections in the [lemon.markets](https://lemon.markets) API can be paginated by specifying the `limit` and `offset` query parameters, and calling the anonymous function as `next.()` and `previous.()`:

```elixir
iex> {:ok, %{next: next, previous: nil, results: first_batch}} = LemonMarketsEx.get_instruments(client, search: "AIR", type: "stock", limit: 3)
iex> {:ok, %{next: next, previous: previous, results: second_batch}} = next.()
iex> {:ok, %{results: ^first_batch}} = previous.()
```

## 🤝 Contributing

1. Fork it [daskycodes/lemon.markets_ex](https://github.com/daskycodes/lemon.markets_ex)
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

Copyright (c) 2021 Daniel Khaapamyaki
