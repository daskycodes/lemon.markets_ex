defmodule LemonMarketsEx.Utils do
  @moduledoc false

  @spec map_paginated_body(map(), list(), fun()) :: %{
          :next => nil | (() -> any),
          :previous => nil | (() -> any),
          :result => list(any)
        }
  def map_paginated_body(body, function_args, map_fn \\ &map_from_result/1) do
    Map.new()
    |> Map.put_new(:results, Enum.map(body["results"], &map_fn.(&1)))
    |> Map.put(
      :next,
      if not is_nil(body["next"]) do
        pagination_link_to_fun(body["next"], function_args)
      end
    )
    |> Map.put(
      :previous,
      if not is_nil(body["previous"]) do
        pagination_link_to_fun(body["previous"], function_args)
      end
    )
  end

  @spec pagination_link_to_fun(String.t(), list()) :: (() -> any)
  def pagination_link_to_fun(link, [module, func | args]) do
    %{query: query} = :uri_string.parse(link)

    query_params =
      query
      |> String.split("&")
      |> Enum.map(fn param ->
        [key, value] = String.split(param, "=")
        {key, value}
      end)
      |> Map.new()

    fn -> apply(module, func, args ++ [query_params]) end
  end

  @spec map_from_result(map()) :: map()
  def map_from_result(body) when is_nil(body), do: nil

  def map_from_result(body) do
    Enum.map(body, fn {key, value} -> {String.to_atom(key), value} end)
    |> Map.new()
  end
end
