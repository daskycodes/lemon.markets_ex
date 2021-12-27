defmodule LemonMarketsEx.RegulatoryInformation do
  @moduledoc """
  See: https://docs.lemon.markets/trading/orders#regulatory-information
  """

  defstruct [
    :KIID,
    :costs_entry,
    :costs_entry_pct,
    :costs_exit,
    :costs_exit_pct,
    :costs_product,
    :costs_product_pct,
    :costs_running,
    :costs_running_pct,
    :estimated_holding_duration_years,
    :estimated_yield_reduction_total,
    :estimated_yield_reduction_total_pct,
    :legal_disclaimer,
    :yield_reduction_year,
    :yield_reduction_year_exit,
    :yield_reduction_year_exit_pct,
    :yield_reduction_year_following,
    :yield_reduction_year_following_pct,
    :yield_reduction_year_pct
  ]

  @type t() :: %__MODULE__{
          KIID: String.t(),
          costs_entry: integer(),
          costs_entry_pct: String.t(),
          costs_exit: integer(),
          costs_exit_pct: String.t(),
          costs_product: float(),
          costs_product_pct: String.t(),
          costs_running: float(),
          costs_running_pct: String.t(),
          estimated_holding_duration_years: String.t(),
          estimated_yield_reduction_total: integer(),
          estimated_yield_reduction_total_pct: String.t(),
          legal_disclaimer: String.t(),
          yield_reduction_year: integer(),
          yield_reduction_year_exit: integer(),
          yield_reduction_year_exit_pct: String.t(),
          yield_reduction_year_following: integer(),
          yield_reduction_year_following_pct: String.t(),
          yield_reduction_year_pct: String.t()
        }

  use ExConstructor
end
