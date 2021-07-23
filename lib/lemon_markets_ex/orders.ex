defmodule LemonMarketsEx.Orders do
  @moduledoc """
  This module provides order requests for the lemon.markets API. See [here](https://docs.lemon.markets/working-with-orders) for more information.
  """
  alias LemonMarketsEx.{
    Error,
    Client,
    Order
  }

  import LemonMarketsEx.Utils

  @doc """
  Get a list of all orders that you placed with the API scoped to the given space in the client.
  Additonally, you also have the option to filter the response to only get the orders you are specifically interested in.

  ## Examples

      iex> LemonMarketsEx.Spaces.get_orders(client)
      {:ok,
      %{
        next: nil,
        previous: nil,
        results: [
          %LemonMarketsEx.Order{
            average_price: "117.4600",
            created_at: 1626444099.043547,
            instrument: %{isin: "US0090661010", title: "AIRBNB INC."},
            limit_price: nil,
            processed_at: 1626444132.988,
            processed_quantity: 4,
            quantity: 4,
            side: "buy",
            status: "executed",
            stop_price: nil,
            type: "market",
            trading_venue_mic: "XMUN",
            uuid: "f4515dd5-bb80-4fb2-8e76-43e1b63dfe91",
            valid_until: 1629115248.0
          },
          ...
        ]
      }}

  ### Parameters

  * `client` - `t:LemonMarketsEx.Client.t/0`
  * `params` - A keyword list of query parameters.
    * `created_at_until` (optional) - UTC UNIX Timestamp in seconds or JS Timestamp (see [here](https://docs.lemon.markets/pagination-numbers)). Can be any date in the future.
    * `created_at_from` (optional) - UTC UNIX Timestamp in seconds or JS Timestamp (see [here](https://docs.lemon.markets/pagination-numbers)). Can be any date in the future.
    * `side` (optional) - `"buy"` or `"sell"`.
    * `type` (optional) - Filter for order type: `"limit"`, `"market"`, `"stop_limit"`, `"stop_market"`.
    * `status` (optional) - Filter for status: `"inactive"`, `"active"`, `"in_progress"`, `"executed"`, `"deleted"`, `"expired"`.
    * `limit` (optional) - Required for pagination; default is 200.
    * `offset` (optional) - Required for pagination.
  """
  @spec get_orders(Client.t(), keyword()) ::
          {:error, Error.t()}
          | {:ok, %{next: String.t(), previous: String.t(), results: [Order.t()]}}
  def get_orders(%Client{client: http_client, space: space_uuid} = client, params \\ []) do
    case Tesla.get(http_client, "/spaces/#{space_uuid}/orders", query: params) do
      {:ok, %Tesla.Env{body: body, status: 200}} ->
        function_args = [__MODULE__, elem(__ENV__.function, 0), client]
        {:ok, map_paginated_body(body, function_args, &Order.from_body/1)}

      {:ok, result} ->
        {:error, Error.from_result(result)}
    end
  end

  @doc """
  Get a single `t:LemonMarketsEx.Order.t/0` by UUID placed with the API scoped to the given space in the client.

  ## Examples

      iex> LemonMarketsEx.Spaces.get_order(client, "f4515dd5-bb80-4fb2-8e76-43e1b63dfe91")
      {:ok,
      %LemonMarketsEx.Order{
        average_price: "117.4600",
        created_at: 1626444099.043547,
        instrument: %{isin: "US0090661010", title: "AIRBNB INC."},
        limit_price: nil,
        processed_at: 1626444132.988,
        processed_quantity: 4,
        quantity: 4,
        side: "buy",
        status: "executed",
        stop_price: nil,
        type: "market",
        trading_venue_mic: "XMUN",
        uuid: "f4515dd5-bb80-4fb2-8e76-43e1b63dfe91",
        valid_until: 1629115248.0
      }}

  ### Parameters

  * `client` - `t:LemonMarketsEx.Client.t/0`
  * `order_uuid` - The UUID of the order to get.
  """
  @spec get_order(Client.t(), String.t()) :: {:error, Error.t()} | {:ok, Order.t()}
  def get_order(%Client{client: client, space: space_uuid}, order_uuid) do
    case Tesla.get(client, "/spaces/#{space_uuid}/orders/#{order_uuid}") do
      {:ok, %Tesla.Env{body: body, status: 200}} -> {:ok, Order.from_body(body)}
      {:ok, result} -> {:error, Error.from_result(result)}
    end
  end

  @doc """
  Create a new `t:LemonMarketsEx.Order.t/0` with the API scoped to the given space in the client.

  ## Examples

      iex> isin = "US0090661010"
      iex> valid_until = :os.system_time(:seconds) + 3600
      iex> LemonMarketsEx.Spaces.create_order(client, %{isin: isin, valid_until: valid_until, side: "buy", quantity: 1})
      {:ok,
      %LemonMarketsEx.Order{
        average_price: nil,
        created_at: nil,
        instrument: %{isin: "US0090661010", title: nil},
        limit_price: nil,
        processed_at: nil,
        processed_quantity: nil,
        quantity: 1,
        side: "buy",
        status: "inactive",
        stop_price: nil,
        trading_venue_mic: "XMUN",
        type: nil,
        uuid: "0f91b8f4-8524-4692-a26c-586a800570ae",
        valid_until: 1626809265.0
      }}

  ### Parameters

  * `client` - `t:LemonMarketsEx.Client.t/0`
  * `create_order_params` - A map of query parameters to create the order.
    * `isin` (required) - ISIN of an instrument.
    * `valid_until` (required) - UTC UNIX Timestamp in seconds or JS Timestamp (see [here](https://docs.lemon.markets/pagination-numbers)). Can be any date in the future.
    * `side` (required) - `"buy"` or `"sell"`.
    * `quantity` (required) - The amount of shares you want to buy.
    * `stop_price` (optional) - See [here](https://docs.lemon.markets/pagination-numbers) for information on numbers format.
    * `limit_price` (optional) - See [here](https://docs.lemon.markets/pagination-numbers) for information on numbers format.
  """
  @spec create_order(Client.t(), map()) :: {:error, Error.t()} | {:ok, Order.t()}
  def create_order(%Client{client: client, space: space_uuid}, create_order_params) do
    case Tesla.post(client, "/spaces/#{space_uuid}/orders", create_order_params) do
      {:ok, %Tesla.Env{body: body, status: 201}} ->
        {:ok, Order.from_create(body)}

      {:ok, result} ->
        {:error, Error.from_result(result)}
    end
  end

  @doc """
  Activates a created `t:LemonMarketsEx.Order.t/0` with the API scoped to the given space in the client.

  You can either pass the `t:LemonMarketsEx.Order.t/0` struct or the UUID of the order to activate.

  - Returns `{:ok, %{status: "activated"}}` on success.
  - Returns `{:error, Error.t()}` on failure.

  ## Examples

      iex> order = %Order{uuid: "0f91b8f4-8524-4692-a26c-586a800570ae"}
      iex> LemonMarketsEx.Spaces.activate_order(client, order)
      {:ok, %{status: "activated"}}

      iex> LemonMarketsEx.Spaces.activate_order(client, "0f91b8f4-8524-4692-a26c-586a800570ae")
      {:ok, %{status: "activated"}}

  ### Parameters

  * `client` - `t:LemonMarketsEx.Client.t/0`
  * `order` - The `Order.t()` to activate | `order_uuid` - The UUID of the order to activate.
  """
  @spec activate_order(Client.t(), Order.t() | String.t()) :: {:error, Error.t()} | {:ok, map()}
  def activate_order(%Client{} = client, %Order{uuid: order_uuid} = _order),
    do: activate_order(client, order_uuid)

  def activate_order(%Client{client: client, space: space_uuid}, order_uuid) do
    case Tesla.put(client, "/spaces/#{space_uuid}/orders/#{order_uuid}/activate", []) do
      {:ok, %Tesla.Env{body: body, status: 200}} -> {:ok, map_from_result(body)}
      {:ok, result} -> {:error, Error.from_result(result)}
    end
  end

  @doc """
  Delete an `t:LemonMarketsEx.Order.t/0` with the API scoped to the given space in the client.
  The order's status has to be `"inactive"` or `"active"`.

  You can either pass the `Order.t()` struct or the UUID of the order to be deleted.

  - Returns `:ok` on success.
  - Returns `{:error, Error.t()}` on failure.

  ## Examples

      iex> order = %Order{uuid: "0f91b8f4-8524-4692-a26c-586a800570ae"}
      iex> LemonMarketsEx.Spaces.delete_order(client, order)
      :ok

      iex> LemonMarketsEx.Spaces.delete_order(client, "0f91b8f4-8524-4692-a26c-586a800570ae")
      :ok

  ### Parameters

  * `client` - `t:LemonMarketsEx.Client.t/0`
  * `order` - The `Order.t()` to delete | `order_uuid` - The UUID of the order to delete.
  """
  @spec delete_order(Client.t(), Order.t() | String.t()) :: {:error, Error.t()} | :ok
  def delete_order(%Client{} = client, %Order{uuid: order_uuid}),
    do: delete_order(client, order_uuid)

  def delete_order(%Client{client: client, space: space_uuid}, order_uuid) do
    case Tesla.delete(client, "/spaces/#{space_uuid}/orders/#{order_uuid}") do
      {:ok, %Tesla.Env{status: 204}} -> :ok
      {:ok, result} -> {:error, Error.from_result(result)}
    end
  end
end
