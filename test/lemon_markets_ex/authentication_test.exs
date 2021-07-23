defmodule LemonMarketsEx.AuthenticationTest do
  use ExUnit.Case

  alias LemonMarketsEx.{Authentication, Token}

  setup do
    Tesla.Mock.mock(fn
      %{method: :post} ->
        %Tesla.Env{status: 200, body: Jason.decode!(File.read!("test/fixtures/auth.json"))}
    end)

    :ok
  end

  test "Successfully returns a Token struct" do
    assert {:ok, %Token{} = token} =
             Authentication.request_auth_token("CLIENT_ID", "CLIENT_SECRET")

    assert token.access_token == ""
    assert token.token_type == "bearer"
    assert token.expires_in == 2_591_999
    assert token.expires_at == :os.system_time(:seconds) + token.expires_in

    assert token.scope == %{
             data: ["stream", "historical", "read"],
             order: ["stock", "bond", "warrant", "etf", "fund", "read"],
             portfolio: ["read"],
             space: "268908e8-e31d-47bc-b830-8b90f80806ed",
             transaction: ["read", "create"]
           }
  end

  test "Successfully returns an authenticated client" do
    assert {:ok, %LemonMarketsEx.Client{} = client} =
             Authentication.authenticate(
               "CLIENT_ID",
               "CLIENT_SECRET",
               "https://super-secret.lemon.markets/rest/v1"
             )

    assert client.space == "268908e8-e31d-47bc-b830-8b90f80806ed"
    assert %Tesla.Client{} = client.client
  end
end
