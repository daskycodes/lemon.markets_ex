use Mix.Config

config :lemon_markets_ex,
  api_key: System.get_env("LEMON_MARKETS_API_KEY"),
  trading_api_url: System.get_env("LEMON_MARKETS_TRADING_API_URL")

import_config "#{Mix.env()}.exs"
