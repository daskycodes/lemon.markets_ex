defmodule LemonMarketsEx.TradingVenuesTest do
  use ExUnit.Case

  alias LemonMarketsEx.{TradingVenues, TradingVenue, Instrument}

  @client %LemonMarketsEx.Client{client: %Tesla.Client{}}

  setup do
    Tesla.Mock.mock(fn
      %{method: :get} = env ->
        case env.url do
          "/instruments" ->
            %Tesla.Env{
              status: 200,
              body: Jason.decode!(File.read!("test/fixtures/instruments.json"))
            }

          "/instruments" <> "/" <> _isin ->
            %Tesla.Env{
              status: 200,
              body: Jason.decode!(File.read!("test/fixtures/instrument.json"))
            }

          "/trading-venues" ->
            %Tesla.Env{
              status: 200,
              body: Jason.decode!(File.read!("test/fixtures/trading_venues.json"))
            }

          "/trading-venues" <> "/" <> "XMUN" ->
            %Tesla.Env{
              status: 200,
              body: Jason.decode!(File.read!("test/fixtures/trading_venue.json"))
            }

          "/trading-venues" <> "/" <> "XMUN" <> "/opening-days" ->
            %Tesla.Env{
              status: 200,
              body: Jason.decode!(File.read!("test/fixtures/opening_days.json"))
            }

          "/trading-venues" <> "/" <> "XMUN" <> "/instruments" ->
            %Tesla.Env{
              status: 200,
              body: Jason.decode!(File.read!("test/fixtures/trading_venue_instruments.json"))
            }

          "/trading-venues" <> "/" <> "XMUN" <> "/instruments" <> "/US19260Q1076" ->
            %Tesla.Env{
              status: 200,
              body: Jason.decode!(File.read!("test/fixtures/trading_venue_instrument.json"))
            }

          "/trading-venues" <> "/" <> "XMUN" <> "/instruments" <> "/US19260Q1076" <> "/warrants" ->
            %Tesla.Env{
              status: 200,
              body:
                Jason.decode!(File.read!("test/fixtures/trading_venue_instrument_warrants.json"))
            }

          _ ->
            %Tesla.Env{status: 404, body: "Not Found"}
        end
    end)

    :ok
  end

  test "get_instruments/2 successfully returns all instruments for the search query" do
    assert {:ok, %{next: nil, previous: nil, results: [instrument]}} =
             TradingVenues.get_instruments(@client,
               tradable: true,
               search: "coinabase",
               type: "stock"
             )

    assert %Instrument{
             currency: "EUR",
             isin: "US19260Q1076",
             name: "COINBASE GLB.CL.A -,00001",
             symbol: "1QZ",
             title: "COINBASE GLOBAL INC.",
             tradable: true,
             trading_venues: [%{mic: "XMUN", title: "Gettex"}],
             type: "stock",
             wkn: "A2QP7J"
           } = instrument
  end

  test "get_trading_venues/1 successfully returns all available trading venues" do
    assert {:ok,
            %{
              next: nil,
              previous: nil,
              results: [
                %TradingVenue{
                  is_open: true,
                  mic: "XMUN",
                  name: "Börse München - Gettex",
                  title: "Gettex"
                }
              ]
            }} = TradingVenues.get_trading_venues(@client)
  end

  test "get_trading_venue/2 successfully returns a single trading venue" do
    assert {:ok,
            %TradingVenue{
              is_open: true,
              mic: "XMUN",
              name: "Börse München - Gettex",
              title: "Gettex"
            }} = TradingVenues.get_trading_venue(@client, "XMUN")
  end

  test "get_opening_days/2 successfully returns the trading venue's opening days" do
    assert {:ok, %{next: nil, previous: nil, results: opening_days}} =
             TradingVenues.get_opening_days(@client, "XMUN")

    assert %{closing_time: 1.6270704e9, day_iso: "2021-07-23", opening_time: 1.62702e9} =
             List.first(opening_days)
  end

  test "get_trading_venue_instruments/2 successfully returns the trading venue's instruments for the given query" do
    assert {
             :ok,
             %{
               next: nil,
               previous: nil,
               results: [
                 %Instrument{
                   currency: "EUR",
                   isin: "US19260Q1076",
                   name: "COINBASE GLB.CL.A -,00001",
                   symbol: "1QZ",
                   title: "COINBASE GLOBAL INC.",
                   tradable: true,
                   trading_venues: [],
                   type: "stock",
                   wkn: "A2QP7J"
                 }
               ]
             }
           } =
             TradingVenues.get_trading_venue_instruments(@client, "XMUN",
               tradable: true,
               search: "coinabase",
               type: "stock"
             )
  end

  test "get_trading_venue_instrument/2 successfully returns a single instrument available in the trading venue" do
    assert {
             :ok,
             %Instrument{
               currency: "EUR",
               isin: "US19260Q1076",
               name: "COINBASE GLB.CL.A -,00001",
               symbol: "1QZ",
               title: "COINBASE GLOBAL INC.",
               tradable: true,
               trading_venues: [],
               type: "stock",
               wkn: "A2QP7J"
             }
           } = TradingVenues.get_trading_venue_instrument(@client, "XMUN", "US19260Q1076")
  end

  test "get_trading_venue_instrument_warrants/4 successfully returns the instruments warrants" do
    assert {:ok, %{next: nil, previous: nil, results: warrants}} =
             TradingVenues.get_trading_venue_instrument_warrants(@client, "XMUN", "US19260Q1076")

    assert %{
             currency: "EUR",
             isin: "DE000HR77YT2",
             name: "UC-HVB DIS.CERT. 21 CALL 1QZ",
             symbol: "",
             title: "HVB DISCOUNT CALL OPTIONSSCHEIN AUF DIE AKTIE DER COINBASE GLOBAL INC.",
             tradable: true,
             type: "warrant",
             wkn: "HR77YT"
           } = List.first(warrants)
  end
end
