defmodule LemonMarketsEx.PortfolioTransaction do
  @moduledoc """
  A position which was added to your portfolio through a transaction.
  """

  defstruct [
    :quantity,
    :order_id,
    :uuid,
    :average_price,
    :side,
    instrument: %{}
  ]

  use ExConstructor

  import LemonMarketsEx.Utils

  @type t() :: %__MODULE__{
          average_price: String.t(),
          instrument: map(),
          order_id: String.t(),
          quantity: pos_integer(),
          side: String.t(),
          uuid: String.t()
        }

  @spec from_body(map()) :: __MODULE__.t()
  def from_body(result) do
    transaction = new(result)
    %{transaction | instrument: map_from_result(transaction.instrument)}
  end
end
