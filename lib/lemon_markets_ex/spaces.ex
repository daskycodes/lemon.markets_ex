defmodule LemonMarketsEx.Spaces do
  @moduledoc """
  Spaces are an (if not the most) important concept for using lemon.markets.
  It is crucial to understand what a space is and how it relates to your overall balance and the cash you can invest.
  If you have not quite grasped the concept of spaces yet, please take a look [here](https://docs.lemon.markets/spaces-apps-strategies) for a detailed overview.
  """
  alias LemonMarketsEx.{
    Error,
    Client,
    Space,
    State,
    PortfolioItem,
    PortfolioTransaction,
    Transaction
  }

  import LemonMarketsEx.Utils

  @doc """
  Get the `t:LemonMarketsEx.State.t/0` for the given client.

  The state is a place where unused money is store and can be reached.

  ## Examples

      iex> LemonMarketsEx.Spaces.get_state(client)
      {:ok,
       %LemonMarketsEx.State{
         cash_account_number: nil,
         securities_account_number: nil,
         state: %{balance: "89999.0000"}
       }}

  ### Parameters

  * `client` - `t:LemonMarketsEx.Client.t/0`

  """
  @spec get_state(Client.t()) :: {:error, Error.t()} | {:ok, State.t()}
  def get_state(%Client{client: http_client}) do
    case Tesla.get(http_client, "/state") do
      {:ok, %Tesla.Env{body: body, status: 200}} -> {:ok, State.from_body(body)}
      {:ok, result} -> {:error, Error.from_result(result)}
    end
  end

  @doc """
  Get a list of all your spaces.

  ## Examples

      iex> LemonMarketsEx.Spaces.get_spaces(client)
      {:ok,
      %{
        next: nil,
        previous: nil,
        results: [
          %LemonMarketsEx.Space{
            name: "Naive Paper Strategy",
            state: %{balance: "10000.0000", cash_to_invest: "10000.0000"},
            type: "strategy",
            uuid: "33e81fe3-7ada-433d-bdc4-7db4d5033b60"
          }
        ]
      }}

  ### Parameters

  * `client` - `t:LemonMarketsEx.Client.t/0`
  * `params` - A keyword list of query parameters.
    * `limit` (optional) - The maximum number of spaces to return.
    * `offset` (optional) - The offset to start returning spaces from.
  """
  @spec get_spaces(Client.t(), keyword()) ::
          {:error, Error.t()} | {:ok, %{next: any, previous: any, results: [Space.t()]}}
  def get_spaces(%Client{client: http_client} = client, params \\ []) do
    case Tesla.get(http_client, "/spaces", query: params) do
      {:ok, %Tesla.Env{body: body, status: 200}} ->
        function_args = [__MODULE__, elem(__ENV__.function, 0), client]
        {:ok, map_paginated_body(body, function_args, &Space.from_body/1)}

      {:ok, result} ->
        {:error, Error.from_result(result)}
    end
  end

  @doc """
  Get a `t:LemonMarketsEx.Space.t/0` by its UUID.

  ## Examples

      iex> LemonMarketsEx.Spaces.get_space(client, "33e81fe3-7ada-433d-bdc4-7db4d5033b60")
      {:ok,
      %LemonMarketsEx.Space{
        name: "Naive Paper Strategy",
        state: %{balance: "10000.0000", cash_to_invest: "10000.0000"},
        type: "strategy",
        uuid: "33e81fe3-7ada-433d-bdc4-7db4d5033b60"
      }}

  ### Parameters

  * `client` - `t:LemonMarketsEx.Client.t/0`
  * `space_uuid` - The UUID of the space to get.
  """
  @spec get_space(Client.t(), String.t()) :: {:error, Error.t()} | {:ok, Space.t()}
  def get_space(%Client{client: client}, space_uuid) do
    case Tesla.get(client, "/spaces/#{space_uuid}") do
      {:ok, %Tesla.Env{body: body, status: 200}} -> {:ok, Space.from_body(body)}
      {:ok, result} -> {:error, Error.from_result(result)}
    end
  end

  @doc """
  Get the state of a `t:LemonMarketsEx.Space.t/0`.

  ## Examples

      iex> LemonMarketsEx.Spaces.get_space_state(client, "33e81fe3-7ada-433d-bdc4-7db4d5033b60")
      {:ok, %{balance: "10000.0000", cash_to_invest: "10000.0000"}}

  ### Parameters

  * `client` - `t:LemonMarketsEx.Client.t/0`
  * `space_uuid` - The UUID of the space state to get.
  """
  @spec get_space_state(Client.t(), String.t()) :: {:error, Error.t()} | {:ok, map}
  def get_space_state(%Client{client: client}, space_uuid) do
    case Tesla.get(client, "/spaces/#{space_uuid}/state") do
      {:ok, %Tesla.Env{body: body, status: 200}} -> {:ok, map_from_result(body)}
      {:ok, result} -> {:error, Error.from_result(result)}
    end
  end

  @doc """
  Gets a list of `t:LemonMarketsEx.PortfolioItem.t/0` structs for the given space in the client.

  - Returns `{:ok, %{next: any, previous: any, [PortfolioItem.t()]}}` on success.
  - Returns `{:error, Error.t()}` on failure.

  ## Examples

      iex> LemonMarketsEx.Spaces.get_portfolio(client)
      {:ok, %{next: nil, previous: nil, results: [%PortfolioItem{}, ...]}}

  ### Parameters

  * `client` - `t:LemonMarketsEx.Client.t/0`
  * `params` - A keyword list of query parameters.
    * `limit` (optional) - Required for pagination; default is 200.
    * `offset` (optional) - Required for pagination.
  """
  @spec get_portfolio(Client.t(), keyword()) ::
          {:error, Error.t()}
          | {:ok, %{next: any, previous: any, results: list(PortfolioItem.t())}}
  def get_portfolio(%Client{client: http_client, space: space_uuid} = client, params \\ []) do
    case Tesla.get(http_client, "/spaces/#{space_uuid}/portfolio", query: params) do
      {:ok, %Tesla.Env{body: body, status: 200}} ->
        function_args = [__MODULE__, elem(__ENV__.function, 0), client]
        {:ok, map_paginated_body(body, function_args, &PortfolioItem.from_body/1)}

      {:ok, result} ->
        {:error, Error.from_result(result)}
    end
  end

  @doc """
  Gets a list of `t:LemonMarketsEx.PortfolioTransaction.t/0` structs for the given space in the client.

  - Returns `{:ok, %{next: any, previous: any, [PortfolioTransaction.t()]}}` on success.
  - Returns `{:error, Error.t()}` on failure.

  ## Examples

      iex> LemonMarketsEx.Spaces.get_portfolio_transactions(client)
      {:ok, %{next: nil, previous: nil, results: [%PortfolioTransaction{}, ...]}}

  ### Parameters

  * `client` - `t:LemonMarketsEx.Client.t/0`
  * `params` - A keyword list of query parameters.
    * `created_at_until` (optional) - UTC Unix Timestamp.
    * `created_at_from` (optional) - UTC Unix Timestamp.
    * `limit` (optional) - Required for pagination; default is 200.
    * `offset` (optional) - Required for pagination.
  """
  @spec get_portfolio_transactions(Client.t(), keyword()) ::
          {:error, Error.t()}
          | {:ok, %{next: any, previous: any, results: [PortfolioTransaction.t()]}}
  def get_portfolio_transactions(
        %Client{client: http_client, space: space_uuid} = client,
        params \\ []
      ) do
    case Tesla.get(http_client, "/spaces/#{space_uuid}/portfolio/transactions", query: params) do
      {:ok, %Tesla.Env{body: body, status: 200}} ->
        function_args = [__MODULE__, elem(__ENV__.function, 0), client]
        {:ok, map_paginated_body(body, function_args, &PortfolioTransaction.from_body/1)}

      {:ok, result} ->
        {:error, Error.from_result(result)}
    end
  end

  @doc """
  Gets a list of `t:LemonMarketsEx.Transaction.t/0` structs for the given space in the client.

  - Returns `{:ok, %{next: any, previous: any, [Transaction.t()]}}` on success.
  - Returns `{:error, Error.t()}` on failure.

  ## Examples

      iex> LemonMarketsEx.Spaces.get_transactions(client)
      {:ok, %{next: nil, previous: nil, results: [%Transaction{}, ...]}}

  ### Parameters

  * `client` - `LemonMarketsEx.Client.t()`
  * `params` - A keyword list of query parameters.
    * `created_at_until` (optional) - UTC Unix Timestamp.
    * `created_at_from` (optional) - UTC Unix Timestamp.
    * `limit` (optional) - Required for pagination; default is 200.
    * `offset` (optional) - Required for pagination.
  """
  @spec get_transactions(Client.t(), keyword()) ::
          {:error, Error.t()} | {:ok, %{next: any, previous: any, results: [Transaction.t()]}}
  def get_transactions(%Client{client: http_client, space: space_uuid} = client, params \\ []) do
    case Tesla.get(http_client, "/spaces/#{space_uuid}/transactions", query: params) do
      {:ok, %Tesla.Env{body: body, status: 200}} ->
        function_args = [__MODULE__, elem(__ENV__.function, 0), client]
        {:ok, map_paginated_body(body, function_args, &Transaction.from_body/1)}

      {:ok, result} ->
        {:error, Error.from_result(result)}
    end
  end

  @doc """
  Gets a single `t:LemonMarketsEx.Transaction.t/0` struct for the given space in the client.

  - Returns `{:ok, Transaction.t()}` on success.
  - Returns `{:error, Error.t()}` on failure.

  ## Examples

      iex> LemonMarketsEx.Spaces.get_transaction(client, transaction_uuid)
      {:ok, %Transaction{}}

  ### Parameters

  * `client` - `t:LemonMarketsEx.Client.t/0`
  * `transaction_uuid` - The `UUID` of the transaction.
  """
  @spec get_transaction(Client.t(), String.t()) :: {:error, Error.t()} | {:ok, Transaction.t()}
  def get_transaction(%Client{client: client, space: space_uuid}, transaction_uuid) do
    case Tesla.get(client, "/spaces/#{space_uuid}/transactions/#{transaction_uuid}") do
      {:ok, %Tesla.Env{body: body, status: 200}} -> {:ok, Transaction.from_body(body)}
      {:ok, result} -> {:error, Error.from_result(result)}
    end
  end
end
