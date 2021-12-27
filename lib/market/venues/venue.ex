defmodule LemonMarketsEx.Venue do
  @moduledoc """
  See: https://docs.lemon.markets/market-data/instruments-tradingvenues#trading-venues
  """

  defstruct [:title, :mic, :is_open, :opening_hours, :opening_days]
  use ExConstructor

  @type t() :: %__MODULE__{
          title: String.t(),
          mic: String.t(),
          is_open: boolean(),
          opening_hours: %{
            start: String.t(),
            end: String.t(),
            timezone: String.t()
          },
          opening_days: list(String.t())
        }

  @spec from_response_body(map()) :: %{
          :next => String.t() | nil,
          :page => integer(),
          :pages => integer(),
          :previous => String.t() | nil,
          :results => [__MODULE__.t(), ...],
          :total => integer()
        }
  def from_response_body(%{"results" => results} = body) do
    %{
      results: Enum.map(results, &create/1),
      previous: body["previous"],
      next: body["next"],
      total: body["total"],
      page: body["page"],
      pages: body["pages"]
    }
  end

  @spec create(map()) :: __MODULE__.t()
  def create(map) do
    venue = new(map)

    opening_hours = %{
      start: get_in(map, ["opening_hours", "start"]),
      end: get_in(map, ["opening_hours", "start"]),
      timezone: get_in(map, ["opening_hours", "timezone"])
    }

    Map.put(venue, :opening_hours, opening_hours)
  end
end
