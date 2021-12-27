defmodule LemonMarketsEx.Instrument do
  @moduledoc """
  See: https://docs.lemon.markets/market-data/instruments-tradingvenues#finding-a-stock
  """

  defstruct [:isin, :wkn, :name, :title, :symbol, :type, :venues]
  use ExConstructor

  @type t() :: %__MODULE__{
          isin: String.t(),
          wkn: String.t(),
          name: String.t(),
          title: String.t(),
          symbol: String.t(),
          type: String.t(),
          venues: [
            %{
              name: String.t(),
              title: String.t(),
              mic: String.t(),
              is_open: boolean(),
              tradable: boolean(),
              currency: String.t()
            },
            ...
          ]
        }

  @spec from_response_body(map()) :: %{
          :next => String.t() | nil,
          :page => integer(),
          :pages => integer(),
          :previous => String.t() | nil,
          :results => [__MODULE__.t(), ...],
          :total => integer()
        }
  def from_response_body(%{"results" => results} = body) do
    %{
      results: Enum.map(results, &create/1),
      previous: body["previous"],
      next: body["next"],
      total: body["total"],
      page: body["page"],
      pages: body["pages"]
    }
  end

  @spec create(map()) :: __MODULE__.t()
  def create(map) do
    instrument = new(map)

    venues =
      Enum.map(map["venues"], fn venue ->
        %{
          name: venue["name"],
          title: venue["title"],
          mic: venue["mic"],
          is_open: venue["is_open"],
          tradable: venue["tradable"],
          currency: venue["currency"]
        }
      end)

    Map.put(instrument, :venues, venues)
  end
end
