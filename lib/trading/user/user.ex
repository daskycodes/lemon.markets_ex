defmodule LemonMarketsEx.User do
  @moduledoc """
  See: https://paper-trading.lemon.markets/v1/docs#/user/user_get_user__get
  """

  defstruct [
    :account_id,
    :country,
    :created_at,
    :data_plan,
    :email,
    :firstname,
    :language,
    :lastname,
    :notifications_general,
    :notifications_order,
    :phone,
    :phone_verified,
    :pin_verified,
    :tax_allowance,
    :tax_allowance_end,
    :tax_allowance_start,
    :trading_plan,
    :user_id
  ]

  @type t() :: %__MODULE__{
          account_id: String.t(),
          country: String.t(),
          created_at: String.t(),
          data_plan: String.t(),
          email: String.t(),
          firstname: String.t(),
          language: String.t(),
          lastname: String.t() | nil,
          notifications_general: boolean(),
          notifications_order: boolean(),
          phone: String.t() | nil,
          phone_verified: String.t() | nil,
          pin_verified: boolean(),
          tax_allowance: number() | nil,
          tax_allowance_end: String.t() | nil,
          tax_allowance_start: String.t() | nil,
          trading_plan: String.t(),
          user_id: String.t()
        }

  use ExConstructor

  @spec from_response_body(map()) :: %{mode: String.t(), results: __MODULE__.t(), status: String.t(), time: String.t()}
  def from_response_body(%{"results" => results} = body) do
    %{
      mode: body["mode"],
      results: new(results),
      status: body["status"],
      time: body["time"]
    }
  end
end
