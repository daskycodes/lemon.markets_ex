defmodule LemonMarketsEx.Trading.Client do
  def get(path, query \\ []), do: Tesla.get(client(), path, query)

  def post(path, params \\ %{}), do: Tesla.post(client(), path, params)

  def put(path, params \\ %{}), do: Tesla.put(client(), path, params)

  def delete(path), do: Tesla.delete(client(), path)

  defp client() do
    middleware = [
      {Tesla.Middleware.BaseUrl, trading_api_url()},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.BearerAuth, token: api_key()}
    ]

    adapter = {adapter(), [recv_timeout: 30_000]}

    Tesla.client(middleware, adapter)
  end

  defp api_key(), do: Application.fetch_env!(:lemon_markets_ex, :api_key)
  defp trading_api_url(), do: Application.fetch_env!(:lemon_markets_ex, :trading_api_url)
  defp adapter(), do: Application.get_env(:tesla, :adapter, Tesla.Adapter.Hackney)
end
