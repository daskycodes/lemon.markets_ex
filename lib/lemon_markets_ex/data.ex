defmodule LemonMarketsEx.Data do
  @moduledoc """
  Conveniently retrieve historic market data in M1/H1/D1 format, get the latest quotes and trades for specific instruments or stream market data in real time.
  """
  alias LemonMarketsEx.{Error, Client}

  import LemonMarketsEx.Utils

  @doc """
  Retrieve the latest quotes for a specific instrument and use the information for your trading strategy.

  ## Examples

      iex> LemonMarketsEx.Data.get_latest_quote(client, "XMUN", "US0090661010")
      {:ok, %{a: 118.64, a_v: 590, b: 118.44, b_v: 590, t: 1626896210.796}}

  ### Parameters

  * `client` - `t:LemonMarketsEx.Client.t/0`
  * `mic` - Abbreviation of Trading Venue. Currently, only XMUN is supported.
  * `isin` - The ISIN of the instrument you want to get the latest quote for
  """
  @spec get_latest_quote(Client.t(), String.t(), String.t()) :: {:error, Error.t()} | {:ok, map}
  def get_latest_quote(%Client{client: client}, mic, isin) do
    case Tesla.get(client, "/trading-venues/#{mic}/instruments/#{isin}/data/quotes/latest") do
      {:ok, %Tesla.Env{body: body, status: 200}} -> {:ok, map_from_result(body)}
      {:error, result} -> {:error, Error.from_result(result)}
    end
  end

  @doc """
  Retrieve the latest trade for a specific instrument.

  ## Examples

      iex> LemonMarketsEx.Data.get_latest_trade(client, "XMUN", "US0090661010")
      {:ok, %{p: 118.48, t: 1626896169.054, v: 3}}

  ### Parameters

  * `client` - `t:LemonMarketsEx.Client.t/0`
  * `mic` - Abbreviation of Trading Venue. Currently, only XMUN is supported.
  * `isin` - The ISIN of the instrument you want to get the latest quote for.
  """
  @spec get_latest_trade(Client.t(), String.t(), String.t()) :: {:error, Error.t()} | {:ok, map()}
  def get_latest_trade(%Client{client: client}, mic, isin) do
    case Tesla.get(client, "/trading-venues/#{mic}/instruments/#{isin}/data/trades/latest") do
      {:ok, %Tesla.Env{body: body, status: 200}} -> {:ok, map_from_result(body)}
      {:error, result} -> {:error, Error.from_result(result)}
    end
  end

  @doc """
  Get the historic OHLC data for the given ISIN.

  ## Examples

      iex> LemonMarketsEx.Data.get_ohlc_data(client, "XMUN", "US0090661010", "m1")
      %{:ok,
        %{
          next: #Function<4.108004987/0 in LemonMarketsEx.Utils.pagination_link_to_fun/2>,
          previous: #Function<4.108004987/0 in LemonMarketsEx.Utils.pagination_link_to_fun/2>,
          results: [
            %{c: 117.56, h: 117.56, l: 117.56, o: 117.56, t: 1626883320.0},
            %{c: 117.58, h: 117.86, l: 117.58, o: 117.86, t: 1626883260.0},
            %{c: 117.92, h: 117.92, l: 117.92, o: 117.92, t: 1.6268832e9},
            %{c: 118.2, h: 118.2, l: 118.2, o: 118.2, t: 1626882240.0},
            %{c: 118.02, h: 118.02, l: 118.02, o: 118.02, t: 1626882060.0},
            ...
          ]
        }}

  ### Parameters

  * `client` - `t:LemonMarketsEx.Client.t/0`
  * `mic` - Abbreviation of Trading Venue. Currently, only XMUN is supported.
  * `isin` - The ISIN of the instrument you want to get the latest quote for.
  * `x1` - Specify the type of data you want: `"m1"`, `"h1"`, or `"d1"`.
  * `params` - A keyword list of query parameters.
    * `ordering` (optional) - By default, the data is not ordered. Choose between `"date"` (oldest to newest) or `"-date"` (newest to oldest).
    * `date_from` (optional) - UTC UNIX Timestamp. Filter to get data from a specific date.
    * `date_until` (optional) - UTC UNIX Timestamp. Filter to get data from a specific date.

  """
  @spec get_ohlc_data(Client.t(), String.t(), String.t(), String.t(), keyword()) ::
          {:error, Error.t()} | {:ok, %{next: boolean, previous: boolean, results: list(map())}}
  def get_ohlc_data(%Client{client: http_client} = client, mic, isin, x1, params \\ []) do
    case Tesla.get(http_client, "/trading-venues/#{mic}/instruments/#{isin}/data/ohlc/#{x1}",
           query: params
         ) do
      {:ok, %Tesla.Env{body: body, status: 200}} ->
        function_args = [__MODULE__, elem(__ENV__.function, 0), client, mic, isin, x1]
        {:ok, map_paginated_body(body, function_args)}

      {:ok, result} ->
        {:error, Error.from_result(result)}
    end
  end

  @doc """
  Get the latest historic OHLC data for the given ISIN.

  ## Examples

      iex> LemonMarketsEx.Data.get_latest_ohlc_data(client, "XMUN", "US0090661010", "m1")
      %{:ok, %{c: 117.56, h: 117.56, l: 117.56, o: 117.56, t: 1626883320.0}}

  ### Parameters

  * `client` - `t:LemonMarketsEx.Client.t/0`
  * `mic` - Abbreviation of Trading Venue. Currently, only XMUN is supported.
  * `isin` - The ISIN of the instrument you want to get the latest quote for.
  * `x1` - Specify the type of data you want: `"m1"`, `"h1"`, or `"d1"`
  """
  @spec get_latest_ohlc_data(Client.t(), String.t(), String.t(), String.t()) ::
          {:error, Error.t()} | {:ok, map()}
  def get_latest_ohlc_data(%Client{client: client}, mic, isin, x1) do
    case Tesla.get(client, "/trading-venues/#{mic}/instruments/#{isin}/data/ohlc/#{x1}/latest") do
      {:ok, %Tesla.Env{body: body, status: 200}} -> {:ok, map_from_result(body)}
      {:error, result} -> {:error, Error.from_result(result)}
    end
  end
end
