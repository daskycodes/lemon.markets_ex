defmodule LemonMarketsEx.Bankstatement do
  @moduledoc """
  See: https://docs.lemon.markets/trading/account#bank-statements
  """

  defstruct [:id, :account_id, :type, :date, :amount, :isin, :isin_title, :created_at]
  use ExConstructor

  @type t() :: %__MODULE__{
          id: String.t(),
          account_id: String.t(),
          type: String.t(),
          date: String.t(),
          amount: integer(),
          isin: String.t() | nil,
          isin_title: String.t() | nil,
          created_at: String.t()
        }

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
