defmodule LemonMarketsEx.Market.Client do
  def get(path, query \\ []), do: Tesla.get(client(), path, query)

  defp client() do
    middleware = [
      {Tesla.Middleware.BaseUrl, "https://data.lemon.markets/v1"},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.BearerAuth, token: api_key()}
    ]

    adapter = {adapter(), [recv_timeout: 30_000]}

    Tesla.client(middleware, adapter)
  end

  defp api_key(), do: Application.fetch_env!(:lemon_markets_ex, :api_key)
  defp adapter(), do: Application.get_env(:tesla, :adapter, Tesla.Adapter.Hackney)
end
