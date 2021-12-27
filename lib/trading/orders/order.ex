defmodule LemonMarketsEx.Order do
  @moduledoc """
  See: https://docs.lemon.markets/trading/orders
  """

  defstruct [
    :id,
    :isin,
    :isin_title,
    :expires_at,
    :created_at,
    :side,
    :quantity,
    :stop_price,
    :limit_price,
    :estimated_price,
    :venue,
    :status,
    :space_id,
    :type,
    :executed_quantity,
    :executed_price,
    :activated_at,
    :executed_at,
    :rejected_at,
    :notes,
    :charge,
    :chargable_at,
    :key_creation_id,
    :key_activation_id,
    :regulatory_information,
    :idempotency
  ]

  @type t() :: %__MODULE__{
          id: String.t(),
          isin: String.t(),
          isin_title: String.t(),
          expires_at: String.t(),
          created_at: String.t(),
          side: String.t(),
          quantity: integer(),
          stop_price: integer(),
          limit_price: integer(),
          estimated_price: integer(),
          venue: String.t(),
          status: String.t(),
          space_id: String.t(),
          type: String.t(),
          executed_quantity: integer(),
          executed_price: integer(),
          activated_at: String.t() | nil,
          executed_at: String.t() | nil,
          rejected_at: String.t() | nil,
          notes: String.t(),
          charge: integer(),
          chargable_at: String.t(),
          key_creation_id: String.t(),
          key_activation_id: Stringt.t(),
          regulatory_information: LemonMarketsEx.RegulatoryInformation.t(),
          idempotency: String.t()
        }

  use ExConstructor

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
      results: Enum.map(results, &create/1),
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
      results: create(results),
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

  @spec create(map()) :: __MODULE__.t()
  def create(map) do
    order = new(map)
    Map.put(order, :regulatory_information, LemonMarketsEx.RegulatoryInformation.new(order.regulatory_information))
  end
end
