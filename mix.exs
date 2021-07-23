defmodule LemonMarketsEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :lemon_markets_ex,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "LemonMarketsEx",
      source_url: "https://github.com/daskycodes/lemon.markets_ex",

      # Docs
      docs: [
        extras: ["README.md"],
        api_reference: false,
        main: "readme",
        groups_for_modules: [
          Collections: [
            LemonMarketsEx.Authentication,
            LemonMarketsEx.Data,
            LemonMarketsEx.Orders,
            LemonMarketsEx.Spaces,
            LemonMarketsEx.TradingVenues
          ],
          "Data types": [
            LemonMarketsEx.Client,
            LemonMarketsEx.Error,
            LemonMarketsEx.Instrument,
            LemonMarketsEx.Order,
            LemonMarketsEx.PortfolioItem,
            LemonMarketsEx.PortfolioTransaction,
            LemonMarketsEx.Space,
            LemonMarketsEx.State,
            LemonMarketsEx.Token,
            LemonMarketsEx.TradingVenue,
            LemonMarketsEx.Transaction
          ]
        ],
        groups_for_functions: [
          Authentication: &(&1[:section] == :authentication),
          Spaces: &(&1[:section] == :spaces),
          Orders: &(&1[:section] == :orders),
          TradingVenues: &(&1[:section] == :trading_venues),
          Data: &(&1[:section] == :data)
        ]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {LemonMarketsEx.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tesla, "~> 1.4"},
      {:hackney, "~> 1.17.0"},
      {:jason, ">= 1.0.0"},
      {:exconstructor, "~> 1.2.3"},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false}
    ]
  end

  defp description do
    """
    Elixir client for the lemon.markets API.
    """
  end

  defp package do
    [
      maintainers: ["Daniel Khaapamyaki"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/daskycodes/lemon.markets_ex"}
    ]
  end
end
