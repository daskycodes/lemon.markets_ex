defmodule LemonMarketsEx.Trading.Error do
  @moduledoc """
  See: https://docs.lemon.markets/resources/error-handling
  """

  defstruct [:error_message, :error_type, :mode, :status, :time]

  @type t() :: %{
          error_message: String.t(),
          error_type: String.t(),
          mode: String.t(),
          status: String.t(),
          time: String.t()
        }

  use ExConstructor
end
