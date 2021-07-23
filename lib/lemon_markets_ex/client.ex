defmodule LemonMarketsEx.Client do
  @moduledoc """
  Client for interacting with the lemon.markets API.

  After sucessfully authenticating with the API,
  and receiving the `t:LemonMarketsEx.Token.t/0` from `LemonMarketsEx.Authentication.request_auth_token/2`,
  you can call `LemonMarketsEx.Client.new/2` to get a client, scoped to a space to make further API calls.

  For more information about the Authentication process, see [here](https://docs.lemon.markets/authentication).
  """
  defstruct [:client, :token, :space]

  @type t() :: %__MODULE__{
          client: Tesla.Client.t(),
          token: LemonMarketsEx.Token.t(),
          space: String.t()
        }

  @doc """
  Create a client, scoped to a space given the `t:LemonMarketsEx.Token.t/0` to make further API calls.

  ## Examples

      iex> {:ok, token} = LemonMarketsEx.Authentication.request_auth_token(client_id, client_secret)
      iex> client = LemonMarketsEx.Client.new(token, base_url)
      iex> LemonMarketsEx.get_state(client)
      {:ok,
       %LemonMarketsEx.State{
         cash_account_number: nil,
         securities_account_number: nil,
         state: %{balance: "89999.0000"}
       }}
  """
  @spec new(LemonMarketsEx.Token.t(), String.t()) :: __MODULE__.t()
  def new(%LemonMarketsEx.Token{} = token, base_url) do
    %{access_token: access_token, scope: %{space: space}} = token

    middleware = [
      {Tesla.Middleware.BaseUrl, base_url},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.BearerAuth, token: access_token}
    ]

    %__MODULE__{client: Tesla.client(middleware), token: token, space: space}
  end
end
