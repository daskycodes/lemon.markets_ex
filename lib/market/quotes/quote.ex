defmodule LemonMarketsEx.Quote do
  @moduledoc """
  See: https://docs.lemon.markets/market-data/historical-data#quotes
  """

  defstruct [:isin, :mic, :a, :a_v, :b, :b_v, :t]

  @type t() :: %__MODULE__{
          isin: String.t(),
          mic: String.t(),
          a: float(),
          a_v: integer(),
          b: float(),
          b_v: integer(),
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
