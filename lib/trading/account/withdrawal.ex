defmodule LemonMarketsEx.Withdrawal do
  @moduledoc """
  See: https://docs.lemon.markets/trading/account#withdrawals
  """

  defstruct [:id, :amount, :created_at, :processed_at, :idempotency]

  @type t() :: %__MODULE__{
          id: String.t(),
          amount: integer(),
          created_at: String.t(),
          processed_at: String.t(),
          idempotency: String.t()
        }

  use ExConstructor

  @spec from_response_body(nil | maybe_improper_list | map) :: %{
          :mode => String.t(),
          :status => String.t(),
          :time => String.t(),
          optional(:next) => String.t() | nil,
          optional(:page) => integer(),
          optional(:pages) => integer(),
          optional(:previous) => String.t() | nil,
          optional(:results) => [__MODULE__.t(), ...],
          optional(:total) => integer()
        }
  def from_response_body(%{"results" => results} = body) do
    %{
      mode: body["mode"],
      results: Enum.map(results, &new/1),
      status: body["status"],
      time: body["time"],
      previous: body["previous"],
      next: body["next"],
      total: body["total"],
      page: body["page"],
      pages: body["pages"]
    }
  end

  def from_response_body(body) do
    %{
      mode: body["mode"],
      status: body["status"],
      time: body["time"]
    }
  end
end
