defmodule LemonMarketsEx do
  @moduledoc """
  Elixir client for the [lemon.markets](https://lemon.markets) API.

  This module provides all requests to the [lemon.markets](https://lemon.markets) API.

  Please check the [README](/doc/readme.html#content) for more information and refer to the Modules `LemonMarketsEx.Authentication`, `LemonMarketsEx.Data`, `LemonMarketsEx.Orders`, `LemonMarketsEx.Spaces` and `LemonMarketsEx.TradingVenues` for more details and examples.
  """

  alias LemonMarketsEx.{
    Authentication,
    Spaces,
    Orders,
    TradingVenues,
    Data
  }

  @doc section: :authentication
  defdelegate authenticate(client_id, client_secret, base_url), to: Authentication
  @doc section: :spaces
  defdelegate get_state(client), to: Spaces
  @doc section: :spaces
  defdelegate get_spaces(client), to: Spaces
  @doc section: :spaces
  defdelegate get_space(client, space_uuid), to: Spaces
  @doc section: :spaces
  defdelegate get_space_state(client, space_uuid), to: Spaces
  @doc section: :spaces
  defdelegate get_portfolio(client, params \\ []), to: Spaces
  @doc section: :spaces
  defdelegate get_portfolio_transactions(client, params \\ []), to: Spaces
  @doc section: :spaces
  defdelegate get_transactions(client, params \\ []), to: Spaces
  @doc section: :spaces
  defdelegate get_transaction(client, transaction_uuid), to: Spaces
  @doc section: :orders
  defdelegate get_orders(client, params \\ []), to: Orders
  @doc section: :orders
  defdelegate get_order(client, order_uuid), to: Orders
  @doc section: :orders
  defdelegate create_order(client, create_order_params), to: Orders
  @doc section: :orders
  defdelegate activate_order(client, order), to: Orders
  @doc section: :orders
  defdelegate delete_order(client, order), to: Orders
  @doc section: :trading_venues
  defdelegate get_instruments(client, params \\ []), to: TradingVenues
  @doc section: :trading_venues
  defdelegate get_opening_days(client, mic), to: TradingVenues
  @doc section: :trading_venues
  defdelegate get_trading_venue(client, mic), to: TradingVenues
  @doc section: :trading_venues
  defdelegate get_trading_venue_instrument(client, mic, isin), to: TradingVenues
  @doc section: :trading_venues

  @doc section: :trading_venues
  defdelegate get_trading_venue_instrument_warrants(client, mic, isin, params \\ []),
    to: TradingVenues

  @doc section: :trading_venues
  defdelegate get_trading_venue_instruments(client, mic, params \\ []), to: TradingVenues
  @doc section: :trading_venues
  defdelegate get_trading_venues(client), to: TradingVenues

  @doc section: :data
  defdelegate get_latest_ohlc_data(client, mic, isin, x1), to: Data
  @doc section: :data
  defdelegate get_latest_quote(client, mic, isin), to: Data
  @doc section: :data
  defdelegate get_latest_trade(client, mic, isin), to: Data
  @doc section: :data
  defdelegate get_ohlc_data(client, mic, isin, x1, params \\ []), to: Data
end
