defmodule LemonMarketsEx.Market.Error do
  @moduledoc """
  See: https://docs.lemon.markets/resources/error-handling
  """

  defstruct [:error_message, :error_type, :status, :time]

  @type t() :: %{
          error_message: String.t(),
          error_type: String.t(),
          status: String.t(),
          time: String.t()
        }

  def new(%{status: 400, body: %{"error" => error, "message" => message}}) do
    %__MODULE__{
      error_message: message,
      error_type: error,
      status: "error",
      time: DateTime.utc_now() |> DateTime.to_iso8601()
    }
  end

  def new(%{status: 500}) do
    %__MODULE__{
      error_message: "Internal Server Error",
      error_type: "internal_server_error",
      status: "error",
      time: DateTime.utc_now() |> DateTime.to_iso8601()
    }
  end
end
