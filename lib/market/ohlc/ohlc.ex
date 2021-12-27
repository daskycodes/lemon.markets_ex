defmodule LemonMarketsEx.Ohlc do
  @moduledoc """
  See: https://docs.lemon.markets/market-data/historical-data#get-ohlcx1
  """

  defstruct [:isin, :mic, :o, :h, :l, :c, :t]

  @type t() :: %__MODULE__{
          isin: String.t(),
          mic: String.t(),
          o: float(),
          h: float(),
          l: float(),
          c: float(),
          t: String.t()
        }

  use ExConstructor

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
      results: Enum.map(results, &new/1),
      previous: body["previous"],
      next: body["next"],
      total: body["total"],
      page: body["page"],
      pages: body["pages"]
    }
  end
end
