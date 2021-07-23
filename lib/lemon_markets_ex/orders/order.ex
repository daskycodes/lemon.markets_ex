defmodule LemonMarketsEx.Order do
  defstruct [
    :average_price,
    :created_at,
    :limit_price,
    :processed_at,
    :processed_quantity,
    :quantity,
    :side,
    :status,
    :stop_price,
    :trading_venue_mic,
    :type,
    :uuid,
    :valid_until,
    instrument: %{isin: nil, title: nil}
  ]

  use ExConstructor

  import LemonMarketsEx.Utils

  @type t() :: %__MODULE__{
          average_price: String.t(),
          created_at: float(),
          instrument: %{
            isin: String.t(),
            title: String.t() | nil
          },
          limit_price: String.t(),
          processed_at: float(),
          processed_quantity: integer(),
          quantity: pos_integer(),
          side: String.t(),
          status: String.t(),
          stop_price: String.t(),
          trading_venue_mic: String.t(),
          type: String.t(),
          uuid: String.t(),
          valid_until: float()
        }

  def from_body(map) do
    order = new(map)
    %{order | instrument: map_from_result(order.instrument)}
  end

  @spec from_create(map()) :: __MODULE__.t()
  def from_create(map) do
    order = new(map)
    isin = Map.get(map, "isin")
    %{order | instrument: %{isin: isin, title: nil}}
  end
end
