defmodule LemonMarketsEx.TradingVenue do
  defstruct [:name, :title, :mic, :is_open]
  use ExConstructor

  @type t() :: %__MODULE__{
          is_open: boolean(),
          mic: String.t(),
          name: String.t(),
          title: String.t()
        }

  @spec from_body(map()) :: __MODULE__.t()
  def from_body(body) do
    new(body)
  end
end
