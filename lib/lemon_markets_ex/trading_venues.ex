defmodule LemonMarketsEx.TradingVenues do
  @moduledoc """
  This module provides requests for the  trading venues endpoint. Including trading venue specific instruments.

  You can specify the Trading Venue, from which you want to receive your data. To do so, add the respective abbreviation in the URL.
  We currently support the connection to the Munich Stock Exchange ("XMUN"), but in the future we migt add additional trading vanues,
  which you can then very easily specificy using their abbreviation.

  Instruments are equities that are tradable on lemon.markets: stocks, bonds, funds, warrants or ETFs.
  """
  alias LemonMarketsEx.{Error, TradingVenue, Instrument, Client}

  import LemonMarketsEx.Utils

  @doc """
  Returns a list of all instruments. Currently, only the instruments for the
  "XMUN" exchange are supported.

  ## Examples

      iex> LemonMarketsEx.Instruments.get_instruments(client, search: "AIRBNB", type: "stock")
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

  #### Parameters
  * `client` - `t:LemonMarketsEx.Client.t/0`
  * `params`: A keyword list of parameters.
    * `tradable`: If true, only tradable instruments are returned.
    * `search`: Search for Name/Title, ISIN, WKN or symbol
    * `currency`: 3 letter abbreviation, e.g. `"EUR"` or `"USD"`
    * `type`: `"stock"`, `"bond"`, `"fund"`, `"ETF"`, or `"warrant"`
    * `limit`: The maximum number of instruments to return.
    * `offset`: The offset of the first instrument to return.
  """
  @spec get_instruments(Client.t(), keyword()) ::
          {:error, Error.t()}
          | {:ok, %{next: fun(), previous: fun(), results: list(Instrument.t())}}
  def get_instruments(%Client{client: http_client} = client, params \\ []) do
    case Tesla.get(http_client, "/instruments", query: params) do
      {:ok, %Tesla.Env{body: body, status: 200}} ->
        function_args = [__MODULE__, elem(__ENV__.function, 0), client]
        {:ok, map_paginated_body(body, function_args, &Instrument.from_body/1)}

      {:error, result} ->
        {:error, Error.from_result(result)}
    end
  end

  @doc """
  Get a list of all available trading venues.

  ## Examples

      iex> LemonMarketsEx.TradingVenues.get_trading_venues(client)
      {:ok,
       %{
         next: nil,
         previous: nil,
         results: [
           %LemonMarketsEx.TradingVenue{
             is_open: false,
             mic: "XMUN",
             name: "Börse München - Gettex",
             title: "Gettex"
           }
         ]
       }}

  ### Parameters

  * `client` - `t:LemonMarketsEx.Client.t/0`
  """
  @spec get_trading_venues(Client.t()) ::
          {:error, Error.t()}
          | {:ok,
             %{
               next: nil | (() -> any),
               previous: nil | (() -> any),
               result: list(TradingVenue.t())
             }}
  def get_trading_venues(%Client{client: http_client} = client) do
    case Tesla.get(http_client, "/trading-venues") do
      {:ok, %Tesla.Env{body: body, status: 200}} ->
        function_args = [__MODULE__, elem(__ENV__.function, 0), client]
        {:ok, map_paginated_body(body, function_args, &TradingVenue.from_body/1)}

      {:error, result} ->
        {:error, Error.from_result(result)}
    end
  end

  @doc """
  Get a single `t:LemonMarketsEx.TrandingVenue.t/0` for a given mic.

  ## Examples

      iex> LemonMarketsEx.TradingVenues.get_trading_venue(client, "XMUN")
      {:ok,
       %LemonMarketsEx.TradingVenue{
         is_open: false,
         mic: "XMUN",
         name: "Börse München - Gettex",
         title: "Gettex"
       }}

  ### Parameters

  * `client` - `t:LemonMarketsEx.Client.t/0`
  * `mic` - Abbreviation of Trading Venue. Currently, only `"XMUN"` is supported.
  """
  @spec get_trading_venue(Client.t(), String.t()) :: {:error, Error.t()} | {:ok, TradingVenue.t()}
  def get_trading_venue(%Client{client: http_client}, mic) do
    case Tesla.get(http_client, "/trading-venues/#{mic}") do
      {:ok, %Tesla.Env{body: body, status: 200}} -> {:ok, TradingVenue.from_body(body)}
      {:error, result} -> {:error, Error.from_result(result)}
    end
  end

  @doc """
  Get the trading venue opening days for the given mic.

  ## Examples

      iex> LemonMarketsEx.TradingVenues.get_trading_venue_opening_days(client, "XMUN")
      {:ok,
       %{
         next: nil,
         previous: nil,
         results: [
           %{
             closing_time: 1.6268976e9,
             day_iso: "2021-07-21",
             opening_time: 1.6268472e9
           },
           %{closing_time: 1.6319088e9, day_iso: "2021-09-17", ...},
           %{closing_time: 1.632168e9, ...},
           %{...},
           ...
         ]
       }}

  ### Parameters

  * `client` - `t:LemonMarketsEx.Client.t/0`
  * `mic` - Abbreviation of Trading Venue. Currently, only `"XMUN"` is supported.
  """
  @spec get_opening_days(Client.t(), String.t()) ::
          {:error, Error.t()}
          | {:ok, %{next: nil | (() -> any), previous: nil | (() -> any), result: list(map())}}
  def get_opening_days(%Client{client: http_client} = client, mic) do
    case Tesla.get(http_client, "/trading-venues/#{mic}/opening-days") do
      {:ok, %Tesla.Env{body: body, status: 200}} ->
        function_args = [__MODULE__, elem(__ENV__.function, 0), client, mic]
        {:ok, map_paginated_body(body, function_args)}

      {:error, result} ->
        {:error, Error.from_result(result)}
    end
  end

  @doc """
  Returns a list of all instruments for the given trading venue.

  ## Examples

      iex> LemonMarketsEx.TradingVenues.get_trading_venue_instruments(client, "XMUN", search: "AIRBNB", type: "stock")
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
             trading_venues: [],
             type: "stock",
             wkn: "A2QG35"
           }
         ]
       }}

  #### Parameters
  * `client` - `t:LemonMarketsEx.Client.t/0`
  * `mic` - The trading venue abbreviation. Currently, only `"XMUN"` is supported.
  * `params` - A keyword list of parameters.
    * `tradable` (optional) - If true, only tradable instruments are returned.
    * `search` (optional) - Search for Name/Title, ISIN, WKN or symbol
    * `currency` (optional) - 3 letter abbreviation, e.g. `"EUR"` or `"USD"`
    * `type` (optional) - `"stock"`, `"bond"`, `"fund"`, `"ETF"`, or `"warrant"`
    * `limit` (optional) - The maximum number of instruments to return.
    * `offset` (optional) - The offset of the first instrument to return.
  """
  @spec get_trading_venue_instruments(Client.t(), String.t(), keyword()) ::
          {:error, Error.t()}
          | {:ok,
             %{
               :next => nil | (() -> any),
               :previous => nil | (() -> any),
               :resuts => list(Instrument.t())
             }}
  def get_trading_venue_instruments(%Client{client: http_client} = client, mic, params \\ []) do
    case Tesla.get(http_client, "/trading-venues/#{mic}/instruments", query: params) do
      {:ok, %Tesla.Env{body: body, status: 200}} ->
        function_args = [__MODULE__, elem(__ENV__.function, 0), client, mic]
        {:ok, map_paginated_body(body, function_args, &Instrument.from_body/1)}

      {:error, result} ->
        {:error, Error.from_result(result)}
    end
  end

  @doc """
  Get a single instrument from a specific trading venue.

  ## Examples

      iex> LemonMarketsEx.TradingVenues.get_trading_venue_instrument(client, "XMUN", "US0090661010")
      {:ok,
       %LemonMarketsEx.Instrument{
         currency: "EUR",
         isin: "US0090661010",
         name: "AIRBNB INC. DL-,01",
         symbol: "6Z1",
         title: "AIRBNB INC.",
         tradable: true,
         trading_venues: [],
         type: "stock",
         wkn: "A2QG35"
       }}

  ### Parameters

  * `client` - `t:LemonMarketsEx.Client.t/0`
  * `mic` - The trading venue abbreviation. Currently, only `"XMUN"` is supported.
  * `isin`- The ISIN of the specific instrument you want to retrieve.
  """
  @spec get_trading_venue_instrument(Client.t(), String.t(), String.t()) ::
          {:error, Error.t()} | {:ok, Instrument.t()}
  def get_trading_venue_instrument(%Client{client: client}, mic, isin) do
    case Tesla.get(client, "/trading-venues/#{mic}/instruments/#{isin}") do
      {:ok, %Tesla.Env{body: body, status: 200}} ->
        {:ok, Instrument.from_body(body)}

      {:error, result} ->
        {:error, Error.from_result(result)}
    end
  end

  @doc """
  Get all warrants for a specific instrument.

  ## Examples

      iex> LemonMarketsEx.TradingVenues.get_trading_venue_instrument_warrants(client, "XMUN", "US0090661010", limit: 1)
      {:ok,
       %{
         next: #Function<4.108004987/0 in LemonMarketsEx.Utils.pagination_link_to_fun/2>,
         previous: nil,
         results: [
           %{
             currency: "EUR",
             isin: "DE000TT7PD71",
             name: "HSBC TO. BULL 6Z1",
             symbol: "",
             title: "",
             tradable: false,
             type: "warrant",
             wkn: "TT7PD7"
           }
         ]
       }}

  ### Parameters

  * `client` - `t:LemonMarketsEx.Client.t/0`
  * `mic` - The trading venue abbreviation. Currently, only `"XMUN"` is supported.
  * `isin` - The ISIN of the specific instrument you want to retrieve.
  * `params` - A keyword list of parameters.
    * `tradable` (optional) - `true` or `false`.
    * `search` (optional) - search for Name/Title, ISIN, WKN or symbol.
    * `currency` (optional) - 3 letter abbreviation, e.g. `"EUR"` or `"USD"`
    * `limit` (optional) - Needed for pagination, default is 100.
    * `offset` (optional) - Needed for pagination.
  """
  @spec get_trading_venue_instrument_warrants(Client.t(), String.t(), String.t(), keyword()) ::
          {:error, Error.t()}
          | {:ok,
             %{
               :next => nil | (() -> any),
               :previous => nil | (() -> any),
               :results => list(map())
             }}
  def get_trading_venue_instrument_warrants(
        %Client{client: http_client} = client,
        mic,
        isin,
        params \\ []
      ) do
    case Tesla.get(http_client, "/trading-venues/#{mic}/instruments/#{isin}/warrants",
           query: params
         ) do
      {:ok, %Tesla.Env{body: body, status: 200}} ->
        function_args = [__MODULE__, elem(__ENV__.function, 0), client, mic, isin]
        {:ok, map_paginated_body(body, function_args)}

      {:error, result} ->
        {:error, Error.from_result(result)}
    end
  end
end
