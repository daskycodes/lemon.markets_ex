defmodule LemonMarketsEx.Authentication do
  @moduledoc """
  This module provides authentication requests for the [lemon.markets](https://lemon.markets) API. See [here](https://docs.lemon.markets/signing-up-getting-access) for more information.
  """

  alias Tesla.Multipart
  alias LemonMarketsEx.{Error, Token, Client}

  @doc """
  Requests a new `t:LemonMarketsEx.Token.t/0` from the lemon.markets API.

  - Returns `{:ok, %LemonMarketsEx.Token{}}` if successful.
  - Returns `{:error, %LemonMarketsEx.Error{}}` if unsuccessfull.

  ## Examples

      iex> LemonMarketsEx.Authentication.request_auth_token(client_id, client_secret)
      {:ok,
      %LemonMarketsEx.Token{
        access_token: "...",
        token_type: "bearer",
        expires_in: 2591999,
        expires_at: 1629410619,
        scope: %{
          data: ["stream", "historical", "read"],
          order: ["stock", "bond", "warrant", "etf", "fund", "read"],
          portfolio: ["read"],
          space: "268908e8-e31d-47bc-b830-8b90f80806ed",
          transaction: ["read", "create"]
        }
      }}

  ### Parameters

  * `client_id` - Grab the client ID from your client in the [dashboard](https://dashboard.lemon.markets).
  * `client_secret` - Grab the client secret from your client in the [dashboard](https://dashboard.lemon.markets).
  """
  @spec request_auth_token(String.t(), String.t()) :: {:error, Error.t()} | {:ok, Token.t()}
  def request_auth_token(client_id, client_secret) do
    mp =
      Multipart.new()
      |> Multipart.add_content_type_param("charset=utf-8")
      |> Multipart.add_field("client_id", client_id)
      |> Multipart.add_field("client_secret", client_secret)
      |> Multipart.add_field("grant_type", "client_credentials")

    client = Tesla.client([Tesla.Middleware.JSON])

    case Tesla.post(client, "https://auth.lemon.markets/oauth2/token", mp) do
      {:ok, %Tesla.Env{body: body, status: 200}} -> {:ok, Token.from_body(body)}
      {:ok, result} -> {:error, Error.from_result(result)}
    end
  end

  @doc """
  Authenticates the client with the lemon.markets API. Returns a new `t:LemonMarketsEx.Client.t/0` scoped to the space for the client_id.

  The `t:LemonMarketsEx.Client.t/0` is needed to make authenticated requests to the lemon.markets API.

  - Returns `{:ok, %LemonMarketsEx.Client{}}` on success.
  - Returns `{:error, %LemonMarketsEx.Error{}}` on failure.

  ## Examples

      iex> LemonMarketsEx.Authentication.authenticate(client_id, client_secret, base_url)
      {:ok, %LemonMarketsEx.Client{}}

  ### Parameters

  * `client_id` - Grab the client ID from your client in the [dashboard](https://dashboard.lemon.markets).
  * `client_secret` - Grab the client secret from your client in the [dashboard](https://dashboard.lemon.markets).
  * `base_url` - The base URL for the lemon.markets API.
  """
  @spec authenticate(String.t(), String.t(), String.t()) ::
          {:error, Error.t()} | {:ok, Client.t()}
  def authenticate(client_id, client_secret, base_url) do
    with {:ok, token} <- request_auth_token(client_id, client_secret) do
      {:ok, Client.new(token, base_url)}
    end
  end
end
