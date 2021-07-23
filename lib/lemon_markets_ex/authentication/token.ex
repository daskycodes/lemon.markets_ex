defmodule LemonMarketsEx.Token do
  defstruct [:access_token, :token_type, :expires_in, :expires_at, :scope]
  use ExConstructor

  @type t() :: %__MODULE__{
          access_token: String.t(),
          token_type: String.t(),
          expires_in: pos_integer(),
          scope: %{
            order: list(String.t()),
            transaction: list(String.t()),
            data: list(String.t()),
            portfolio: list(String.t()),
            space: String.t()
          }
        }

  @spec from_body(map()) :: __MODULE__.t()
  def from_body(map) do
    auth = new(map)

    %{
      auth
      | scope: parse_scope(auth.scope),
        expires_at: :os.system_time(:seconds) + auth.expires_in
    }
  end

  defp parse_scope(scope) do
    String.split(scope)
    |> Enum.map_reduce(
      %{order: [], transaction: [], data: [], portfolio: [], space: ""},
      fn scope, acc ->
        case String.split(scope, ":") do
          ["order", value] = scope ->
            {scope, Map.update(acc, :order, acc, &[value | &1])}

          ["transaction", value] = scope ->
            {scope, Map.update(acc, :transaction, acc, &[value | &1])}

          ["data", value] = scope ->
            {scope, Map.update(acc, :data, acc, &[value | &1])}

          ["portfolio", value] = scope ->
            {scope, Map.update(acc, :portfolio, acc, &[value | &1])}

          ["space", value] = scope ->
            {scope, Map.put(acc, :space, value)}
        end
      end
    )
    |> elem(1)
  end
end
