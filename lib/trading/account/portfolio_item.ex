defmodule LemonMarketsEx.PortfolioItem do
  @moduledoc """
  See: https://docs.lemon.markets/trading/portfolio
  """

  defstruct [
    :space_id,
    :isin,
    :isin_title,
    :quantity,
    :buy_quantity,
    :sell_quantity,
    :buy_price_avg,
    :buy_price_min,
    :buy_price_max,
    :buy_price_avg_historical,
    :sell_price_min,
    :sell_price_max,
    :sell_price_avg_historical,
    :sell_orders_total,
    :buy_orders_total
  ]

  @type t() :: %__MODULE__{
          space_id: String.t(),
          isin: String.t(),
          isin_title: String.t(),
          quantity: integer(),
          buy_quantity: integer(),
          sell_quantity: integer(),
          buy_price_avg: integer(),
          buy_price_min: integer(),
          buy_price_max: integer(),
          buy_price_avg_historical: integer(),
          sell_price_min: integer(),
          sell_price_max: integer(),
          sell_price_avg_historical: integer(),
          sell_orders_total: integer(),
          buy_orders_total: integer()
        }

  use ExConstructor

  @spec from_response_body(map()) :: %{
          mode: String.t(),
          next: String.t() | nil,
          page: integer(),
          pages: integer(),
          previous: String.t() | nil,
          results: [__MODULE__.t(), ...],
          status: String.t(),
          time: String.t(),
          total: integer()
        }
  def from_response_body(body) do
    %{
      mode: body["mode"],
      results: Enum.map(body["results"], &new/1),
      status: body["status"],
      time: body["time"],
      previous: body["previous"],
      next: body["next"],
      total: body["total"],
      page: body["page"],
      pages: body["pages"]
    }
  end
end
