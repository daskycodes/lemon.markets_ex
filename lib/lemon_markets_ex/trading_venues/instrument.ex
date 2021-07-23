defmodule LemonMarketsEx.Instrument do
  defstruct [:isin, :wkn, :name, :title, :symbol, :type, :currency, :tradable, trading_venues: []]
  use ExConstructor

  import LemonMarketsEx.Utils

  @type t() :: %__MODULE__{
          currency: String.t(),
          isin: String.t(),
          name: String.t(),
          symbol: String.t(),
          title: String.t(),
          tradable: boolean(),
          trading_venues:
            list(%{
              title: String.t(),
              mic: String.t()
            }),
          type: String.t(),
          wkn: String.t()
        }

  @spec from_body(map()) :: __MODULE__.t()
  def from_body(result) do
    instrument = new(result)
    trading_venues = Enum.map(instrument.trading_venues, &map_from_result/1)
    %{instrument | trading_venues: trading_venues}
  end
end
