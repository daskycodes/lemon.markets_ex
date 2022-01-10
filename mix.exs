defmodule LemonMarketsEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :lemon_markets_ex,
      version: "0.2.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: "Elixir client for the lemon.markets API.",
      name: "LemonMarketsEx",
      source_url: "https://github.com/daskycodes/lemon.markets_ex",
      docs: [
        extras: ["README.md"],
        api_reference: false,
        main: "readme",
        groups_for_modules: [
          APIs: [
            LemonMarketsEx.Trading,
            LemonMarketsEx.Market
          ],
          "Data Types": [
            LemonMarketsEx.Order,
            LemonMarketsEx.PortfolioItem,
            LemonMarketsEx.Bankstatement,
            LemonMarketsEx.Document,
            LemonMarketsEx.User,
            LemonMarketsEx.Space,
            LemonMarketsEx.Order,
            LemonMarketsEx.Account,
            LemonMarketsEx.RegulatoryInformation,
            LemonMarketsEx.Withdrawal,
            LemonMarketsEx.Venue,
            LemonMarketsEx.Instrument,
            LemonMarketsEx.Trade,
            LemonMarketsEx.Quote,
            LemonMarketsEx.Ohlc
          ],
          "Error Types": [
            LemonMarketsEx.Trading.Error,
            LemonMarketsEx.Market.Error
          ],
          "HTTP Clients": [
            LemonMarketsEx.Trading.Client,
            LemonMarketsEx.Market.Client
          ]
        ],
        groups_for_functions: [
          Account: &(&1[:tags] == [:account]),
          Order: &(&1[:tags] == [:order]),
          Portfolio: &(&1[:tags] == [:portfolio]),
          Space: &(&1[:tags] == [:space]),
          User: &(&1[:tags] == [:user]),
          Venues: &(&1[:tags] == [:venues]),
          Instruments: &(&1[:tags] == [:instruments]),
          Trades: &(&1[:tags] == [:trades]),
          Quotes: &(&1[:tags] == [:quotes]),
          OHLC: &(&1[:tags] == [:ohlc])
        ]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tesla, "~> 1.4"},
      {:hackney, "~> 1.17.0"},
      {:jason, ">= 1.0.0"},
      {:exconstructor, "~> 1.2.3"},
      {:ex_doc, git: "https://github.com/elixir-lang/ex_doc", ref: "a011116", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["Daniel Khaapamyaki"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/daskycodes/lemon.markets_ex"}
    ]
  end
end
