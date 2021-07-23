defmodule LemonMarketsEx.DataTest do
  use ExUnit.Case

  alias LemonMarketsEx.Data

  @client %LemonMarketsEx.Client{client: %Tesla.Client{}}
  @mic "XMUN"
  @coinbase_isin "US19260Q1076"
  @data_url "/trading-venues/#{@mic}/instruments/#{@coinbase_isin}/data"

  describe "Get single trades and quotest" do
    setup do
      Tesla.Mock.mock(fn
        %{method: :get} = env ->
          case env.url do
            @data_url <> "/quotes/latest" ->
              %Tesla.Env{
                status: 200,
                body: Jason.decode!(File.read!("test/fixtures/latest_quote.json"))
              }

            @data_url <> "/trades/latest" ->
              %Tesla.Env{
                status: 200,
                body: Jason.decode!(File.read!("test/fixtures/latest_trade.json"))
              }

            @data_url <> "/ohlc/m1/latest" ->
              %Tesla.Env{
                status: 200,
                body: Jason.decode!(File.read!("test/fixtures/latest_ohlc_data.json"))
              }

            _ ->
              %Tesla.Env{status: 404, body: "Not Found"}
          end
      end)

      :ok
    end

    test "get_latest_quote/3 successfully returns the latest quote" do
      assert {:ok, %{a: 191.0, a_v: 131, b: 190.4, b_v: 131, t: 1_627_050_385.528}} =
               Data.get_latest_quote(@client, @mic, @coinbase_isin)
    end

    test "get_latest_trade/3 successfully returns the latest trade" do
      assert {:ok, %{a: 191.0, a_v: 131, b: 190.4, b_v: 131, t: 1_627_050_385.528}} =
               Data.get_latest_quote(@client, @mic, @coinbase_isin)
    end

    test "get_latest_ohlc_data/4 successfully returns the latest ohlc data" do
      assert {:ok, %{c: 190.8, h: 190.8, l: 190.6, o: 190.6, t: 1.6270503e9}} =
               Data.get_latest_ohlc_data(@client, @mic, @coinbase_isin, "m1")
    end
  end

  describe "OHLC Data" do
    setup do
      Tesla.Mock.mock(fn
        %{method: :get, url: @data_url <> "/ohlc/m1"} = env ->
          case env.query do
            [ordering: "-date"] ->
              %Tesla.Env{
                status: 200,
                body: Jason.decode!(File.read!("test/fixtures/ohlc_data.json"))
              }

            %{
              "date_from" => "1626912000.0",
              "date_until" => "1626998400.0",
              "ordering" => "-date"
            } ->
              %Tesla.Env{
                status: 200,
                body: Jason.decode!(File.read!("test/fixtures/ohlc_data_previous.json"))
              }

            %{
              "date_from" => "1626998400.0",
              "date_until" => "1627084800.0",
              "ordering" => "-date"
            } ->
              %Tesla.Env{
                status: 200,
                body: Jason.decode!(File.read!("test/fixtures/ohlc_data.json"))
              }

            _ ->
              %Tesla.Env{status: 404, body: "Not Found"}
          end
      end)

      :ok
    end

    test "get_ohlc_data/5 successfully returns the requested ohlc data" do
      assert {
               :ok,
               %{
                 next: _next,
                 previous: _previous,
                 results: [
                   %{c: 190.8, h: 190.8, l: 190.6, o: 190.6, t: 1.6270503e9},
                   %{c: 191.0, h: 191.0, l: 191.0, o: 191.0, t: 1_627_049_760.0},
                   %{c: 192.2, h: 192.2, l: 192.2, o: 192.2, t: 1_627_048_020.0},
                   %{c: 191.4, h: 192.0, l: 191.4, o: 192.0, t: 1_627_047_360.0},
                   %{c: 193.4, h: 193.4, l: 193.4, o: 193.4, t: 1.6270467e9},
                   %{c: 193.6, h: 193.6, l: 193.6, o: 193.6, t: 1.627044e9},
                   %{c: 193.0, h: 193.0, l: 193.0, o: 193.0, t: 1.6270413e9},
                   %{c: 193.6, h: 193.6, l: 193.6, o: 193.6, t: 1_627_041_180.0},
                   %{c: 193.0, h: 193.0, l: 193.0, o: 193.0, t: 1_627_040_580.0},
                   %{c: 193.0, h: 193.0, l: 193.0, o: 193.0, t: 1.6270395e9},
                   %{c: 193.0, h: 193.0, l: 193.0, o: 193.0, t: 1.627038e9},
                   %{c: 193.4, h: 193.4, l: 193.4, o: 193.4, t: 1_627_033_380.0},
                   %{c: 193.4, h: 193.4, l: 193.4, o: 193.4, t: 1_627_032_120.0},
                   %{c: 193.4, h: 193.4, l: 193.4, o: 193.4, t: 1.627032e9},
                   %{c: 194.0, h: 194.0, l: 194.0, o: 194.0, t: 1_627_028_520.0},
                   %{c: 194.0, h: 194.0, l: 194.0, o: 194.0, t: 1_627_027_680.0},
                   %{c: 193.6, h: 193.6, l: 193.6, o: 193.6, t: 1.6270269e9},
                   %{c: 193.6, h: 193.6, l: 193.6, o: 193.6, t: 1_627_026_540.0},
                   %{c: 193.6, h: 193.6, l: 193.6, o: 193.6, t: 1_627_026_480.0},
                   %{c: 193.2, h: 193.2, l: 193.2, o: 193.2, t: 1.6270263e9},
                   %{c: 193.2, h: 193.2, l: 193.2, o: 193.2, t: 1_627_024_380.0},
                   %{c: 193.2, h: 193.2, l: 193.2, o: 193.2, t: 1_627_022_160.0},
                   %{c: 193.2, h: 193.2, l: 193.2, o: 193.2, t: 1_627_021_320.0},
                   %{c: 193.2, h: 193.2, l: 193.2, o: 193.2, t: 1_627_020_060.0}
                 ]
               }
             } = Data.get_ohlc_data(@client, @mic, @coinbase_isin, "m1", ordering: "-date")
    end

    test "get_ohlc_data/5 successfully returns the requested ohlc data following the previous link" do
      assert {:ok, %{previous: previous, results: first_data_points}} =
               Data.get_ohlc_data(@client, @mic, @coinbase_isin, "m1", ordering: "-date")

      assert {:ok, %{next: next, results: last_data_points}} = previous.()
      refute last_data_points == first_data_points
      assert {:ok, %{results: ^first_data_points}} = next.()
    end
  end
end
