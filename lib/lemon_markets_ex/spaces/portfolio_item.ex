defmodule LemonMarketsEx.PortfolioItem do
  @moduledoc """
  A position that is part of a specific space.
  """

  defstruct [:instrument, :quantity, :average_price, :latest_total_value]
  use ExConstructor

  import LemonMarketsEx.Utils

  @type t() :: %__MODULE__{
          average_price: String.t(),
          instrument: map(),
          latest_total_value: String.t(),
          quantity: pos_integer()
        }

  @spec from_body(map()) :: __MODULE__.t()
  def from_body(result) do
    item = new(result)
    %{item | instrument: map_from_result(item.instrument)}
  end
end
