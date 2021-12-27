defmodule LemonMarketsEx.Document do
  @moduledoc """
  See: https://docs.lemon.markets/trading/account#get-documents
  """

  defstruct [:id, :name, :category, :link, :public_url, :viewed_first_at, :viewed_last_at, :created_at]
  use ExConstructor

  @type t() :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          category: String.t(),
          link: String.t(),
          public_url: String.t(),
          viewed_first_at: String.t(),
          viewed_last_at: String.t(),
          created_at: String.t()
        }

  @spec from_response_body(map) :: %{
          mode: String.t(),
          results: [__MODULE__.t(), ...] | __MODULE__.t(),
          status: String.t(),
          time: String.t()
        }
  def from_response_body(%{"results" => results} = body) when is_list(results) do
    %{
      mode: body["mode"],
      results: Enum.map(results, &new/1),
      status: body["status"],
      time: body["time"]
    }
  end

  def from_response_body(%{"results" => results} = body) do
    %{
      mode: body["mode"],
      results: new(results),
      status: body["status"],
      time: body["time"]
    }
  end
end
