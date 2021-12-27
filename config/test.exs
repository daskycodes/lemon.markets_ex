use Mix.Config

config :tesla, adapter: Tesla.Mock

config :lemon_markets_ex,
  api_key: "test",
  trading_api_url: "https://paper-trading.lemon.markets/v1"
