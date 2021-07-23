defmodule LemonMarketsEx.Transaction do
  @moduledoc """
  A transaction that affects the cash amount available for your space.
  """

  defstruct [:amount, :uuid, :created_at, :type, :order]
  use ExConstructor

  import LemonMarketsEx.Utils

  @type t() :: %__MODULE__{
          amount: String.t(),
          created_at: number(),
          order: %{
            uuid: String.t(),
            processed_quantity: pos_integer(),
            average_price: String.t(),
            instrument: %{
              title: String.t(),
              isin: String.t()
            }
          },
          type: String.t(),
          uuid: String.t()
        }

  @spec from_body(map()) :: __MODULE__.t()
  def from_body(result) do
    transaction = new(result)

    if not is_nil(transaction.order) do
      order = map_from_result(transaction.order)
      instrument = map_from_result(order.instrument)
      %{transaction | order: %{order | instrument: instrument}}
    else
      transaction
    end
  end
end
