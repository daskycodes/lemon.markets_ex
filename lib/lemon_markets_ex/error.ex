defmodule LemonMarketsEx.Error do
  defstruct [:error, :error_description, :detail, :status]
  use ExConstructor

  @type t() :: %__MODULE__{
          error: String.t(),
          error_description: String.t(),
          detail: map(),
          status: pos_integer()
        }

  @spec from_result(map()) :: LemonMarketsEx.Error.t()
  def from_result(%{status: 404}) do
    %__MODULE__{
      error: "Not Found",
      error_description: "The requested resource was not found on this server.",
      status: 404
    }
  end

  def from_result(%{status: 500}) do
    %__MODULE__{
      error: "Server Error",
      error_description: "Server Error",
      status: 500
    }
  end

  def from_result(%{status: 400, body: body}) do
    %__MODULE__{
      error: "Bad Request",
      error_description: body,
      status: 400
    }
  end

  def from_result(%{body: body, status: status}) do
    new(body) |> Map.put(:status, status)
  end
end
