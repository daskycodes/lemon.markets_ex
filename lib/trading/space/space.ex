defmodule LemonMarketsEx.Space do
  @moduledoc """
  See: https://docs.lemon.markets/trading/spaces
  """

  defstruct [:name, :description, :type, :risk_limit, :linked, :created_at, :id, :buying_power, :earnings, :backfire]
  use ExConstructor

  @type t() :: %__MODULE__{
          name: String.t(),
          description: String.t(),
          type: String.t(),
          risk_limit: integer(),
          linked: String.t() | nil,
          created_at: String.t(),
          id: String.t(),
          buying_power: integer(),
          earnings: integer(),
          backfire: integer()
        }

  @spec from_response_body(map()) :: %{
          :mode => String.t(),
          :status => String.t(),
          :time => String.t(),
          optional(:next) => String.t() | nil,
          optional(:page) => integer(),
          optional(:pages) => integer(),
          optional(:previous) => String.t() | nil,
          optional(:results) => [__MODULE__.t(), ...] | __MODULE__.t(),
          optional(:total) => integer()
        }
  def from_response_body(%{"results" => results} = body) when is_list(results) do
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

  def from_response_body(%{"results" => results} = body) do
    %{
      mode: body["mode"],
      results: new(results),
      status: body["status"],
      time: body["time"]
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
