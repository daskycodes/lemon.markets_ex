defmodule LemonMarketsEx.State do
  defstruct [:cash_account_number, :securities_account_number, :state]
  use ExConstructor

  import LemonMarketsEx.Utils

  @type t() :: %__MODULE__{
          cash_account_number: String.t() | nil,
          securities_account_number: String.t() | nil,
          state: %{balance: String.t()}
        }

  @spec from_body(map()) :: LemonMarketsEx.State.t()
  def from_body(result) do
    state = new(result)
    %{state | state: map_from_result(state.state)}
  end
end
