defmodule LemonMarketsEx.Account do
  @moduledoc """
  See: https://docs.lemon.markets/trading/account
  """

  defstruct [
    :account_id,
    :account_number,
    :address,
    :balance,
    :bank_name_origin,
    :billing_address,
    :billing_email,
    :billing_name,
    :billing_vat,
    :cash_to_invest,
    :cash_to_withdraw,
    :client_id,
    :created_at,
    :data_plan,
    :deposit_id,
    :email,
    :firstname,
    :iban_brokerage,
    :iban_origin,
    :lastname,
    :mode,
    :phone,
    :onboarding_spaces,
    :onboarding_trades,
    :onboarding_trades_missing,
    :tax_allowance,
    :tax_allowance_end,
    :tax_allowance_start,
    :trading_plan
  ]

  @type t() :: %__MODULE__{
          account_id: String.t(),
          account_number: integer() | nil,
          address: String.t() | nil,
          balance: integer(),
          bank_name_origin: String.t() | nil,
          billing_address: String.t() | nil,
          billing_email: String.t() | nil,
          billing_name: String.t() | nil,
          billing_vat: String.t() | nil,
          cash_to_invest: integer(),
          cash_to_withdraw: integer(),
          client_id: String.t() | nil,
          created_at: String.t(),
          data_plan: String.t(),
          deposit_id: String.t() | nil,
          email: String.t(),
          firstname: String.t(),
          iban_brokerage: String.t() | nil,
          iban_origin: String.t() | nil,
          lastname: String.t() | nil,
          mode: String.t(),
          onboarding_spaces: boolean(),
          onboarding_trades: boolean(),
          onboarding_trades_missing: integer(),
          phone: String.t() | nil,
          tax_allowance: integer() | nil,
          tax_allowance_end: String.t() | nil,
          tax_allowance_start: String.t() | nil,
          trading_plan: String.t()
        }

  use ExConstructor

  @spec from_response_body(map()) :: %{mode: String.t(), results: __MODULE__.t(), status: String.t(), time: String.t()}
  def from_response_body(body) do
    %{
      mode: body["mode"],
      results: new(body["results"]),
      status: body["status"],
      time: body["time"]
    }
  end
end
