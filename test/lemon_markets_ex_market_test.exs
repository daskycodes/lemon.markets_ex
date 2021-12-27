defmodule LemonMarketsEx.MarketTest do
  use ExUnit.Case, async: true

  alias LemonMarketsEx.Instrument
  alias LemonMarketsEx.Market
  alias LemonMarketsEx.Ohlc
  alias LemonMarketsEx.Quote
  alias LemonMarketsEx.Trade
  alias LemonMarketsEx.Venue

  describe "Venues" do
    test "fetches all venues" do
      Tesla.Mock.mock(fn %{method: :get, url: "https://data.lemon.markets/v1/venues"} ->
        %Tesla.Env{
          status: 200,
          body: Jason.decode!(File.read!("test/fixtures/market/venues.json"))
        }
      end)

      assert {:ok, %{results: [%Venue{} = venue | _]}} = Market.get_venues()
      assert venue.mic == "XMUN"
    end
  end

  describe "Instruments" do
    test "fetches all shopify related instruments" do
      Tesla.Mock.mock(fn %{method: :get, url: "https://data.lemon.markets/v1/instruments"} ->
        %Tesla.Env{
          status: 200,
          body: Jason.decode!(File.read!("test/fixtures/market/instruments.json"))
        }
      end)

      assert {:ok, %{results: [%Instrument{} = instrument | _]}} = Market.get_instruments(search: "shopify", tradable: true, mic: "XMUN")

      assert instrument.name == "SHOPIFY A SUB.VTG"
    end
  end

  describe "Trades" do
    test "fetches all trades for the specific instrument" do
      Tesla.Mock.mock(fn %{method: :get, url: "https://data.lemon.markets/v1/trades"} ->
        %Tesla.Env{
          status: 200,
          body: Jason.decode!(File.read!("test/fixtures/market/trades.json"))
        }
      end)

      assert {:ok, %{results: [%Trade{} = trade | _]}} = Market.get_trades(isin: "US19260Q1076", mic: "XMUN")

      assert trade.isin == "US19260Q1076"
    end
  end

  describe "Quotes" do
    test "fetches all quotes for the specific instrument" do
      Tesla.Mock.mock(fn %{method: :get, url: "https://data.lemon.markets/v1/quotes"} ->
        %Tesla.Env{
          status: 200,
          body: Jason.decode!(File.read!("test/fixtures/market/quotes.json"))
        }
      end)

      assert {:ok, %{results: [%Quote{} = quote | _]}} = Market.get_quotes(isin: "US19260Q1076", mic: "XMUN")

      assert quote.isin == "US19260Q1076"
    end
  end

  describe "OHLC" do
    test "fetches the OHLC data for the specific instrument" do
      Tesla.Mock.mock(fn %{method: :get, url: "https://data.lemon.markets/v1/ohlc/m1"} ->
        %Tesla.Env{status: 200, body: Jason.decode!(File.read!("test/fixtures/market/ohlc.json"))}
      end)

      to = Date.utc_today() |> Date.end_of_week() |> Date.to_iso8601()
      from = Date.utc_today() |> Date.beginning_of_week() |> Date.to_iso8601()

      assert {:ok, %{results: [%Ohlc{} = ohlc | _]}} =
               Market.get_ohlc("m1",
                 isin: "US19260Q1076",
                 mic: "XMUN",
                 limit: 100,
                 from: from,
                 to: to
               )

      assert ohlc.isin == "US19260Q1076"
    end
  end
end
