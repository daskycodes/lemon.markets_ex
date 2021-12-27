defmodule LemonMarketsEx.Market do
  @moduledoc """
  The [lemon.markets](https://lemon.markets) Market Data API.
  """

  import LemonMarketsEx.Market.Client

  alias LemonMarketsEx.Instrument
  alias LemonMarketsEx.Market.Error
  alias LemonMarketsEx.Ohlc
  alias LemonMarketsEx.Quote
  alias LemonMarketsEx.Trade
  alias LemonMarketsEx.Venue

  @doc """
  Retrieves the available trading venues from the lemon.markets Market Data API.

  See: https://docs.lemon.markets/market-data/instruments-tradingvenues#trading-venues

  ## Parameters

  * `query` - A keyword list of query parameters.
    * `mic` (optional) - Enter a Market Identifier Code (MIC) in there. Default is `"XMUN"`.
    * `page` (optional) - The specific results page you want to request. - See: https://docs.lemon.markets/trading/overview#pagination-in-the-trading-api
    * `limit` (optional) - The amount of results per page. - See: https://docs.lemon.markets/trading/overview#pagination-in-the-trading-api

  ## Examples

      iex> LemonMarketsEx.Market.get_venues
      {:ok,
        %{
          next: nil,
          page: 1,
          pages: 1,
          previous: nil,
          results: [
            %LemonMarketsEx.Venue{
              is_open: true,
              mic: "XMUN",
              opening_days: ["2021-12-27", "2021-12-28", "2021-12-29",
                "2021-12-30"],
              opening_hours: %{
                end: "08:00",
                start: "08:00",
                timezone: "Europe/Berlin"
              },
              title: "Gettex"
            },
            %LemonMarketsEx.Venue{
              is_open: true,
              mic: "LMBPX",
              opening_days: ["2021-12-27", "2021-12-28", "2021-12-29",
                "2021-12-30"],
              opening_hours: %{
                end: "08:00",
                start: "08:00",
                timezone: "Europe/Berlin"
              },
              title: "LM Best Performance"
            }
          ],
          total: 2
       }}

  """
  @doc tags: [:venues]
  @spec get_venues(keyword()) ::
          {:error, Error.t()}
          | {:ok,
             %{
               next: nil | String.t(),
               page: integer(),
               pages: integer(),
               previous: nil | String.t(),
               results: [Venue.t(), ...],
               total: integer()
             }}
  def get_venues(query \\ []) do
    case get("/venues", query: query) do
      {:ok, %{body: body, status: 200}} -> {:ok, Venue.from_response_body(body)}
      {:ok, response} -> {:error, Error.new(response)}
    end
  end

  @doc """
  Find stocks on the lemon.markets Market Data API.

  See: https://docs.lemon.markets/market-data/instruments-tradingvenues#finding-a-stock

  ## Parameters

  * `query` - A keyword list of query parameters.
    * `isin` (optional) - Specify the Instrument you are interested in through it Internation Securities Identification Number. You can also specify multiple ISINs. Maximum 10 ISINs per Request.
      Searching for multiple isins can be done through a comma separated string e.g. `"US88160R1014,US19260Q1076"` or multiple `:isin` keys e.g. `LemonMarketsEx.Market.get_instruments(isin: "US88160R1014", isin: "US19260Q1076")`.
    * `mic` (optional) - Enter a Market Identifier Code (MIC) in there. Default is `"XMUN"`.
    * `search` (optional) - Search for Name/Title, ISIN, WKN or symbol. You can also perform a partial search by only specifiying the first 4 symbols.
    * `currency` (optional) - Define a three letter ISO currency code to see instruments traded in a specific currency, like `"EUR"` or `"USD"`.
    * `tradable` (optional) - Filter for tradable or non-tradable Instruments with `true` or `false`.
    * `page` (optional) - The specific results page you want to request. - See: https://docs.lemon.markets/trading/overview#pagination-in-the-trading-api
    * `limit` (optional) - The amount of results per page. - See: https://docs.lemon.markets/trading/overview#pagination-in-the-trading-api

  ## Examples

      iex> LemonMarketsEx.Market.get_instruments(search: "shopify", tradable: true, mic: "XMUN")
      {:ok,
        %{
          next: nil,
          page: 1,
          pages: 1,
          previous: nil,
          results: [
            %LemonMarketsEx.Instrument{
              isin: "CA82509L1076",
              name: "SHOPIFY A SUB.VTG",
              symbol: "307",
              title: "SHOPIFY INC.",
              type: "stock",
              venues: [
                %{
                  currency: "EUR",
                  is_open: true,
                  mic: "XMUN",
                  name: "Börse München - Gettex",
                  title: "Gettex",
                  tradable: true
                }
              ],
              wkn: "A14TJP"
            }
          ],
          total: 1
        }}

  """
  @doc tags: [:instruments]
  @spec get_instruments(keyword()) ::
          {:error, Error.t()}
          | {:ok,
             %{
               next: nil | String.t(),
               page: integer(),
               pages: integer(),
               previous: nil | String.t(),
               results: [Venue.t(), ...],
               total: integer()
             }}
  def get_instruments(query \\ []) do
    case get("/instruments", query: query) do
      {:ok, %{body: body, status: 200}} -> {:ok, Instrument.from_response_body(body)}
      {:ok, response} -> {:error, Error.new(response)}
    end
  end

  @doc """
  Retrieve trades from the lemon.markets Market Data API.

  > ## ⚠️ Working with 'from' and 'to' in the Trades endpoint
  > [lemon.markets](https://lemon.markets) are currently working hard on adding the possibility to specifiy the time range you want to get the Trades for.
  > However, there are still some inconsistencies with using from and to to define your desired time range. Using these query parameters to specify your time range in most
  > cases results in a 500 Server Error, so please try not to use it/rely on it at this stage. We are working on it :)

  See: https://docs.lemon.markets/market-data/historical-data#trades

  ## Parameters

  * `query` - A keyword list of query parameters.
    * `isin` (required) - Specify the Instrument you are interested in through it Internation Securities Identification Number. You can also specify multiple ISINs. Maximum 10 ISINs per Request.
      Searching for multiple isins can be done through a comma separated string e.g. `"US88160R1014,US19260Q1076"` or multiple `:isin` keys e.g. `LemonMarketsEx.Market.get_instruments(isin: "US88160R1014", isin: "US19260Q1076")`.
    * `mic` (optional) - Market Identifier Code of Trading Venue. Currently, only `"XMUN"` is supported.
    * `from` (optional) - Start of Time Range for which you want to get the Trades. Use int/date-iso-string to define your timestamp range. Use from=latest to receive the latest quotes.
    * `to` (optional) - End of Time Range for which you want to get the Trades. Use int/date-iso-string to define your timestamp range.
    * `decimals` (optional) - The numbers format you want to get your response in, either decimals or int. Default is `true`.
    * `epoch` (optional) - The date format you want to get your response in. Default is `false`. By default, the API will return ISO string dates.
    * `sorting` (optional) - FSort your API response, either ascending (`"asc"`) or descending (`"desc"`).
    * `page` (optional) - The specific results page you want to request. - See: https://docs.lemon.markets/trading/overview#pagination-in-the-trading-api
    * `limit` (optional) - The amount of results per page. - See: https://docs.lemon.markets/trading/overview#pagination-in-the-trading-api

  ## Examples

      iex> LemonMarketsEx.Market.get_trades(isin: "US19260Q1076", mic: "XMUN")
      {:ok,
        %{
          next: nil,
          page: 1,
          pages: 1,
          previous: nil,
          results: [
            %LemonMarketsEx.Trade{
              isin: "US19260Q1076",
              mic: "XMUN",
              p: 246.5,
              t: "2021-12-27T16:13:28.688+00:00",
              v: 8
            }
          ],
          total: 1
        }}

  """
  @doc tags: [:trades]
  @spec get_trades(keyword()) ::
          {:error, Error.t()}
          | {:ok,
             %{
               next: nil | String.t(),
               page: integer(),
               pages: integer(),
               previous: nil | String.t(),
               results: [Trade.t(), ...],
               total: integer()
             }}
  def get_trades(query \\ []) do
    case get("/trades", query: query) do
      {:ok, %{body: body, status: 200}} -> {:ok, Trade.from_response_body(body)}
      {:ok, response} -> {:error, Error.new(response)}
    end
  end

  @doc """
  Retrieve quotes from the lemon.markets Market Data API.

  > ## ⚠️ Working with 'from' and 'to' in the Trades endpoint
  > [lemon.markets](https://lemon.markets) are currently working hard on adding the possibility to specifiy the time range you want to get the Trades for.
  > However, there are still some inconsistencies with using from and to to define your desired time range. Using these query parameters to specify your time range in most
  > cases results in a 500 Server Error, so please try not to use it/rely on it at this stage. We are working on it :)

  See: https://docs.lemon.markets/market-data/historical-data#quotes

  ## Parameters

  * `query` - A keyword list of query parameters.
    * `isin` (required) - Specify the Instrument you are interested in through it Internation Securities Identification Number. You can also specify multiple ISINs. Maximum 10 ISINs per Request.
      Searching for multiple isins can be done through a comma separated string e.g. `"US88160R1014,US19260Q1076"` or multiple `:isin` keys e.g. `LemonMarketsEx.Market.get_instruments(isin: "US88160R1014", isin: "US19260Q1076")`.
    * `mic` (optional) - Market Identifier Code of Trading Venue. Currently, only `"XMUN"` is supported.
    * `from` (optional) - Start of Time Range for which you want to get the Trades. Use int/date-iso-string to define your timestamp range. Use from=latest to receive the latest quotes.
    * `to` (optional) - End of Time Range for which you want to get the Trades. Use int/date-iso-string to define your timestamp range.
    * `decimals` (optional) - The numbers format you want to get your response in, either decimals or int. Default is `true`.
    * `epoch` (optional) - The date format you want to get your response in. Default is `false`. By default, the API will return ISO string dates.
    * `sorting` (optional) - FSort your API response, either ascending (`"asc"`) or descending (`"desc"`).
    * `page` (optional) - The specific results page you want to request. - See: https://docs.lemon.markets/trading/overview#pagination-in-the-trading-api
    * `limit` (optional) - The amount of results per page. - See: https://docs.lemon.markets/trading/overview#pagination-in-the-trading-api

  ## Examples

      iex> LemonMarketsEx.Market.get_quotes(isin: "US19260Q1076", mic: "XMUN")
      {:ok,
        %{
          next: nil,
          page: 1,
          pages: 1,
          previous: nil,
          results: [
            %LemonMarketsEx.Quote{
              a: 245.0,
              a_v: 102,
              b: 244.0,
              b_v: 102,
              isin: "US19260Q1076",
              mic: "XMUN",
              t: "2021-12-27T16:22:14.847+00:00"
            }
          ],
          total: 1
        }}

  """
  @doc tags: [:quotes]
  @spec get_quotes(keyword()) ::
          {:error, Error.t()}
          | {:ok,
             %{
               next: nil | String.t(),
               page: integer(),
               pages: integer(),
               previous: nil | String.t(),
               results: [Quote.t(), ...],
               total: integer()
             }}
  def get_quotes(query \\ []) do
    case get("/quotes", query: query) do
      {:ok, %{body: body, status: 200}} -> {:ok, Quote.from_response_body(body)}
      {:ok, response} -> {:error, Error.new(response)}
    end
  end

  @doc """
  Retrieve historic OHLC from the lemon.markets Market Data API.

  See: https://docs.lemon.markets/market-data/historical-data#quotes

  ## Parameters

  * `timespan` (required) - Specify the type of data you wish to retrieve: `"m1"` (per minute), `"h1"` (per hour), or `"d1"` (per day).

  * `query` - A keyword list of query parameters.
    * `isin` (required) - Specify the Instrument you are interested in through it Internation Securities Identification Number. You can also specify multiple ISINs. Maximum 10 ISINs per Request.
      Searching for multiple isins can be done through a comma separated string e.g. `"US88160R1014,US19260Q1076"` or multiple `:isin` keys e.g. `LemonMarketsEx.Market.get_instruments(isin: "US88160R1014", isin: "US19260Q1076")`.
    * `mic` (optional) - Market Identifier Code of Trading Venue. Currently, only `"XMUN"` is supported.
    * `from` (optional) - Start of Time Range for which you want to get the Trades. Use int/date-iso-string to define your timestamp range. Use from=latest to receive the latest quotes.
    * `to` (optional) - End of Time Range for which you want to get the Trades. Use int/date-iso-string to define your timestamp range.
    * `decimals` (optional) - The numbers format you want to get your response in, either decimals or int. Default is `true`.
    * `epoch` (optional) - The date format you want to get your response in. Default is `false`. By default, the API will return ISO string dates.
    * `sorting` (optional) - FSort your API response, either ascending (`"asc"`) or descending (`"desc"`).
    * `page` (optional) - The specific results page you want to request. - See: https://docs.lemon.markets/trading/overview#pagination-in-the-trading-api
    * `limit` (optional) - The amount of results per page. - See: https://docs.lemon.markets/trading/overview#pagination-in-the-trading-api

  ## Examples

      iex> to = Date.utc_today |> Date.end_of_week |> Date.to_iso8601
      iex> from = Date.utc_today |> Date.beginning_of_week |> Date.to_iso8601
      iex> LemonMarketsEx.Market.get_ohlc("m1", isin: "US19260Q1076", mic: "XMUN", limit: 100, from: from, to: to)
      {:ok,
        %{
          next: nil,
          page: 1,
          pages: 1,
          previous: nil,
          results: [
            %LemonMarketsEx.Ohlc{
              c: 237.5,
              h: 237.5,
              isin: "US19260Q1076",
              l: 237.5,
              mic: "XMUN",
              o: 237.5,
              t: "2021-12-27T07:01:00.000+00:00"
            },
            %LemonMarketsEx.Ohlc{...},
            ...
          ],
          total: 48
        }}

  """
  @doc tags: [:ohlc]
  @spec get_ohlc(keyword()) ::
          {:error, Error.t()}
          | {:ok,
             %{
               next: nil | String.t(),
               page: integer(),
               pages: integer(),
               previous: nil | String.t(),
               results: [Ohlc.t(), ...],
               total: integer()
             }}
  def get_ohlc(timespan, query \\ []) do
    case get("/ohlc/#{timespan}", query: query) do
      {:ok, %{body: body, status: 200}} -> {:ok, Ohlc.from_response_body(body)}
      {:ok, response} -> {:error, Error.new(response)}
    end
  end
end
