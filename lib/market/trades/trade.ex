defmodule LemonMarketsEx.Trade do
  @moduledoc """
  See: https://docs.lemon.markets/market-data/historical-data#trades
  """

  defstruct [:isin, :mic, :p, :t, :v]

  @type t() :: %__MODULE__{
          isin: String.t(),
          mic: String.t(),
          p: float(),
          t: String.t(),
          v: integer()
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
