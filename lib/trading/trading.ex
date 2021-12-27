defmodule LemonMarketsEx.Trading do
  @moduledoc """
  The [lemon.markets](https://lemon.markets) Trading API.
  """

  import LemonMarketsEx.Trading.Client

  alias LemonMarketsEx.Account
  alias LemonMarketsEx.Bankstatement
  alias LemonMarketsEx.Document
  alias LemonMarketsEx.Trading.Error
  alias LemonMarketsEx.Order
  alias LemonMarketsEx.PortfolioItem
  alias LemonMarketsEx.Space
  alias LemonMarketsEx.User
  alias LemonMarketsEx.Withdrawal

  @doc """
  Retrieves your currently authenticated account from the lemon.markets Trading API.

  See: https://docs.lemon.markets/trading/account#get-account

  ## Examples

      iex> {:ok, %{results: %LemonMarketsEx.Account{} = account}} = LemonMarketsEx.Trading.get_account
      iex> account.balance
      1000000000

  """
  @doc tags: [:account]
  @spec get_account :: {:error, Error.t()} | {:ok, %{mode: String.t(), results: Account.t(), status: String.t(), time: String.t()}}
  def get_account do
    case get("/account") do
      {:ok, %{body: body, status: 200}} -> {:ok, Account.from_response_body(body)}
      {:ok, %{body: body}} -> {:error, Error.new(body)}
    end
  end

  @doc """
  Retrieves your account's withdrawals from the lemon.markets Trading API.

  See: https://docs.lemon.markets/trading/account#withdrawals

  ## Parameters

  * `query` - A keyword list of query parameters.
    * `page` (optional) - The specific results page you want to request. - See: https://docs.lemon.markets/trading/overview#pagination-in-the-trading-api
    * `limit` (optional) - The amount of results per page. - See: https://docs.lemon.markets/trading/overview#pagination-in-the-trading-api

  ## Examples

      iex> LemonMarketsEx.Trading.get_withdrawals(page: 10, limit: 5)
      {:ok,
        %{
          mode: "paper",
          next: nil,
          page: 10,
          pages: 1,
          previous: "https://paper-trading.lemon.markets/v1/account/withdrawals?limit=5&page=0",
          results: [],
          status: "ok",
          time: "2021-12-26T18:34:14.269+00:00",
          total: 0
        }}

  """
  @doc tags: [:account]
  @spec get_withdrawals(keyword()) ::
          {:error, Error.t()}
          | {:ok,
             %{
               mode: String.t(),
               results: [Withdrawal.t(), ...],
               status: String.t(),
               time: String.t(),
               previous: String.t(),
               next: String.t(),
               total: integer(),
               page: integer(),
               pages: integer()
             }}
  def get_withdrawals(query \\ []) do
    case get("/account/withdrawals", query: query) do
      {:ok, %{body: body, status: 200}} -> {:ok, Withdrawal.from_response_body(body)}
      {:ok, %{body: body}} -> {:error, Error.new(body)}
    end
  end

  @doc """
  Withdraw funds from your account with the lemon.markets Trading API.

  See: https://docs.lemon.markets/trading/account#withdrawals

  ## Parameters

  * `params` - A map of request body params.
    * `amount` (required) - The amount you wish to withdraw. - See: https://docs.lemon.markets/trading/overview#working-with-numbers-in-the-trading-api
    * `pin` (required) - The personal verification PIN you set during the onboarding.

  ## Examples

      iex> LemonMarketsEx.Trading.create_withdrawal(%{amount: 1000000, pin: "1337"})
      {:ok, %{mode: "paper", status: "ok", time: "2021-12-26T19:08:07.873+00:00"}}

      iex> LemonMarketsEx.Trading.create_withdrawal(%{amount: 100000, pin: "1337"})
      {:error,
        %LemonMarketsEx.Error{
          error_message: "Invalid 'amount' (Minimum withdraw amount is 100€.)",
          error_type: "invalid_query",
          mode: "paper",
          status: "error",
          time: "2021-12-26T19:04:13.642+00:00"
        }}

  """
  @doc tags: [:account]
  @spec create_withdrawal(%{amount: number(), pin: binary()}) ::
          {:error, Error.t()} | {:ok, %{mode: String.t(), status: String.t(), time: String.t()}}
  def create_withdrawal(params) do
    case post("/account/withdrawals", params) do
      {:ok, %{body: body, status: 200}} -> {:ok, Withdrawal.from_response_body(body)}
      {:ok, %{body: body}} -> {:error, Error.new(body)}
    end
  end

  @doc """
  Retrieves your account's bankstatments from the lemon.markets Trading API.

  See: https://docs.lemon.markets/trading/account#bank-statements

  ## Parameters

  * `query` - A keyword list of query parameters.
    * `type` (optional) - Filter for different types of bank statements: `pay_in`, `pay_out`, `order_buy`, `order_sell`, `eod_balance`, `dividend`.
    * `from` (optional) - Filter for bank statements after a specific date. Format: "YYYY-MM-DD".
    * `to` (optional) - Filter for bank statements until a specific date. Format: "YYYY-MM-DD".
    * `page` (optional) - The specific results page you want to request. - See: https://docs.lemon.markets/trading/overview#pagination-in-the-trading-api
    * `limit` (optional) - The amount of results per page. - See: https://docs.lemon.markets/trading/overview#pagination-in-the-trading-api

  ## Examples

      iex> LemonMarketsEx.Trading.get_bankstatements
      {:ok,
        %{
          mode: "paper",
          next: nil,
          page: 1,
          pages: 1,
          previous: nil,
          results: [
            %LemonMarketsEx.Bankstatement{
              account_id: "acc_1337",
              amount: 1000000000,
              created_at: "2021-12-18T21:48:03.257+00:00",
              date: "2021-12-17",
              id: "bst_1337",
              isin: nil,
              isin_title: nil,
              type: "pay_in"
            },
            %LemonMarketsEx.Bankstatement{
              account_id: "acc_1337",
              amount: 1000000000,
              created_at: "2021-12-18T21:48:03.257+00:00",
              date: "2021-12-17",
              id: "bst_1337",
              isin: nil,
              isin_title: nil,
              type: "eod_balance"
            }
          ],
          status: "ok",
          time: "2021-12-26T19:27:20.444+00:00",
          total: 2
       }}

  """
  @doc tags: [:account]
  @spec get_bankstatements(keyword()) ::
          {:error, Error.t()}
          | {:ok,
             %{
               mode: String.t(),
               next: String.t(),
               page: integer(),
               pages: integer(),
               previous: String.t(),
               results: [Bankstatement.t(), ...],
               status: String.t(),
               time: String.t(),
               total: integer()
             }}
  def get_bankstatements(query \\ []) do
    case get("/account/bankstatements", query: query) do
      {:ok, %{body: body, status: 200}} -> {:ok, Bankstatement.from_response_body(body)}
      {:ok, %{body: body}} -> {:error, Error.new(body)}
    end
  end

  @doc """
  Retrieves your account's documents from the lemon.markets Trading API.

  See: https://docs.lemon.markets/trading/account#get-documents

  ## Examples

      iex> LemonMarketsEx.Trading.get_documents
      {:ok,
        %{
          mode: "paper",
          results: [%LemonMarketsEx.Document{}, ...],
          status: "ok",
          time: "2021-12-26T19:40:45.772+00:00"
       }}

  """
  @doc tags: [:account]
  @spec get_documents ::
          {:error, Error.t()} | {:ok, %{mode: String.t(), results: [Document.t(), ...], status: String.t(), time: String.t()}}
  def get_documents do
    case get("/account/documents") do
      {:ok, %{body: body, status: 200}} -> {:ok, Document.from_response_body(body)}
      {:ok, %{body: body}} -> {:error, Error.new(body)}
    end
  end

  @doc """
  Retrieves a single document from the lemon.markets Trading API.

  See: https://docs.lemon.markets/trading/account#get-documents

  ## Parameters

  * `query` - A keyword list of query parameters.
    * `no_redirect` (optional) - Defaults to `false`

  ## Examples

      iex> LemonMarketsEx.Trading.get_document(document_id)
      {:ok,
        %{
          mode: "paper",
          results: %LemonMarketsEx.Document{},
          status: "ok",
          time: "2021-12-26T19:40:45.772+00:00"
       }}

  """
  @doc tags: [:account]
  @spec get_document(binary(), no_redirect: boolean()) ::
          {:error, Error.t()} | {:ok, %{mode: String.t(), results: Document.t(), status: String.t(), time: String.t()}}
  def get_document(document_id, query \\ []) do
    case get("/account/documents/#{document_id}", query: query) do
      {:ok, %{body: body, status: 200}} -> {:ok, Document.from_response_body(body)}
      {:ok, %{body: body}} -> {:error, Error.new(body)}
    end
  end

  @doc """
  Retrieves your orders from the lemon.markets Trading API.

  See: https://docs.lemon.markets/trading/orders

  ## Parameters

  * `query` - A keyword list of query parameters.
    * `page` (optional) - The specific results page you want to request. - See: https://docs.lemon.markets/trading/overview#pagination-in-the-trading-api
    * `limit` (optional) - The amount of results per page. - See: https://docs.lemon.markets/trading/overview#pagination-in-the-trading-api
    * `from` (optional) - Specify an ISO date string (YYYY-MM-DD) to get only orders from a specific date on.
    * `to` (optional) - Specify an ISO date string (YYYY-MM-DD) to get only orders until a specific date.
    * `isin` (optional) - Add this Query Parameter to only see orders from a specific instrument.
    * `side` (optional) - Filter to either only see `"buy"` or `"sell"` orders.
    * `status` (optional) - Filter for status `"inactive"`, `"activated"`, `"open"` (Real Money only), `"in_progress"`, `"cancelling"`, `"executed"`, `"cancelled"` or `"expired"`
    * `type` (optional) - Add this Query Parameter to only see the orders of a specific space.
    * `key_creation_id` (optional) - Add this Query Parameter to only see the orders of a specific space.

  ## Examples

      iex> LemonMarketsEx.Trading.get_orders
      {:ok,
        %{
        mode: "paper",
        next: nil,
        page: 1,
        pages: 1,
        previous: nil,
        results: [%LemonMarketsEx.Order{}, ...],
        status: "ok",
        time: "2021-12-26T21:35:55.546+00:00",
        total: 0
      }}

  """
  @doc tags: [:order]
  @spec get_orders(keyword()) ::
          {:error, Error.t()}
          | {:ok,
             %{
               mode: String.t(),
               status: String.t(),
               time: String.t(),
               next: nil | String.t(),
               page: integer(),
               pages: integer(),
               previous: nil | String.t(),
               results: [Order.t(), ...],
               total: integer()
             }}
  def get_orders(query \\ []) do
    case get("/orders", query: query) do
      {:ok, %{body: body, status: 200}} -> {:ok, Order.from_response_body(body)}
      {:ok, %{body: body}} -> {:error, Error.new(body)}
    end
  end

  @doc """
  Retrieves a single order from the lemon.markets Trading API.

  See: https://docs.lemon.markets/trading/orders

  ## Examples

      iex> LemonMarketsEx.Trading.get_order(order_id)
      {:ok,
        %{
        mode: "paper",
        results: %LemonMarketsEx.Order{...},
        status: "ok",
        time: "2021-12-26T21:35:55.546+00:00",
      }}

  """
  @doc tags: [:order]
  @spec get_order(binary()) :: {:error, Error.t()} | {:ok, %{mode: String.t(), status: String.t(), time: String.t(), results: Order.t()}}
  def get_order(order_id) do
    case get("/orders/#{order_id}") do
      {:ok, %{body: body, status: 200}} -> {:ok, Order.from_response_body(body)}
      {:ok, %{body: body}} -> {:error, Error.new(body)}
    end
  end

  @doc """
  Places a new order on lemon.markets Trading API.

  > In the Paper Money environment, you can place orders all day everyday, even outside of the standard trading hours.
  > To do so, use "venue": "allday" in your request body. The order is then executed at the price of the last saved quote for the respective ISIN.

  See: https://docs.lemon.markets/trading/orders#placing-an-order

  ## Parameters

    * `params` - A map of request body params.
      * `isin` (required) - Internation Security Identification Number of the instrument you wish to buy or sell.
      * `expires_at` (required) - ISO String date (YYYY-MM-DD). Order expires at the end of the specified day. Maximum expiration date is 30 days in the future.
      * `side` (required) - With this you can define whether you want to buy (`"buy"`) or sell (`"sell"`) a specific instrument
      * `quantity` (required) - The amount of shares you want to buy. Limited to 1000 per request.
      * `venue` (required) - Market Identifier Code of Stock exchange you want to address. Default value is `"xmun"`. Use `venue: "allday"` for 24/7 order exeution (only in the Paper Money environment).
      * `space_id` (required) - Identification Number of the space you want to place the order with.
      * `stop_price` (optional) - Stop Price for your Order. See: https://docs.lemon.markets/trading/overview#working-with-numbers-in-the-trading-api
      * `limit_price` (optional) - Limit Price for your Order. See: https://docs.lemon.markets/trading/overview#working-with-numbers-in-the-trading-api

  ## Examples

      iex> params = %{
        expires_at: "2021-12-27",
        isin: "US19260Q1076",
        quantity: 1,
        side: "buy",
        space_id: "sp_1337"
      }
      iex> LemonMarketsEx.Trading.create_order(params)
      {:ok,
        %{
        mode: "paper",
        results: %LemonMarketsEx.Order{},
        status: "ok",
        time: "2021-12-26T21:35:55.546+00:00",
      }}

  """
  @doc tags: [:order]
  @spec create_order(map()) :: {:error, Error.t()} | {:ok, %{mode: String.t(), status: String.t(), time: String.t(), results: Order.t()}}
  def create_order(params) do
    case post("/orders", params) do
      {:ok, %{body: body, status: 200}} -> {:ok, Order.from_response_body(body)}
      {:ok, %{body: body}} -> {:error, Error.new(body)}
    end
  end

  @doc """
  Activate a placed order on lemon.markets Trading API.

  See: https://docs.lemon.markets/trading/orders#activating-an-order

  ## Parameters

    * `params` - A map of request body params.
      * `pin` (required) - PIN to activate an order. If you want to activate a real money order use the 4-digit PIN you set during your onboarding process. If you want to activate a paper money order you can use any random 4-digit PIN.

  ## Examples

      iex> LemonMarketsEx.Trading.activate_order(order_id, %{pin: "1337"})
      {:ok, %{mode: "paper", status: "ok", time: "2021-12-26T22:12:05.023+00:00"}}

  """
  @doc tags: [:order]
  @spec activate_order(binary(), %{pin: String.t()}) ::
          {:error, Error.t()} | {:ok, %{mode: String.t(), status: String.t(), time: String.t()}}
  def activate_order(order_id, params) do
    case post("/orders/#{order_id}/activate", params) do
      {:ok, %{body: body, status: 200}} -> {:ok, Order.from_response_body(body)}
      {:ok, %{body: body}} -> {:error, Error.new(body)}
    end
  end

  @doc """
  Cancel a placed order on lemon.markets Trading API.

  See: https://docs.lemon.markets/trading/orders#activating-an-order

  ## Examples

      iex> LemonMarketsEx.Trading.delete_order(order_id)
      {:ok, %{mode: "paper", status: "ok", time: "2021-12-26T22:12:05.023+00:00"}}

  """
  @doc tags: [:order]
  @spec delete_order(binary()) :: {:error, Error.t()} | {:ok, %{mode: String.t(), status: String.t(), time: String.t()}}
  def delete_order(order_id) do
    case delete("/orders/#{order_id}") do
      {:ok, %{body: body, status: 200}} -> {:ok, Order.from_response_body(body)}
      {:ok, %{body: body}} -> {:error, Error.new(body)}
    end
  end

  @doc """
  Retrieves your portfolio from the lemon.markets Trading API.

  See: https://docs.lemon.markets/trading/portfolio

  ## Parameters

  * `query` - A keyword list of query parameters.
    * `page` (optional) - The specific results page you want to request. - See: https://docs.lemon.markets/trading/overview#pagination-in-the-trading-api
    * `limit` (optional) - The amount of results per page. - See: https://docs.lemon.markets/trading/overview#pagination-in-the-trading-api
    * `isin` (optional) - Add this Query Parameter to only see orders from a specific instrument.
    * `space_id` (optional) - Filter for a specific Space in your portfolio

  ## Examples

      iex> LemonMarketsEx.Trading.get_portfolio
      {:ok,
        %{
        mode: "paper",
        next: nil,
        page: 1,
        pages: 1,
        previous: nil,
        results: [%LemonMarketsEx.PortfolioItem{}, ...],
        status: "ok",
        time: "2021-12-26T21:35:55.546+00:00",
        total: 0
      }}

  """
  @doc tags: [:portfolio]
  @spec get_portfolio(keyword()) ::
          {:error, Error.t()}
          | {:ok,
             %{
               mode: String.t(),
               next: nil | String.t(),
               page: integer(),
               pages: integer(),
               previous: nil | String.t(),
               results: [PortfolioItem.t(), ...],
               status: String.t(),
               time: String.t(),
               total: integer()
             }}
  def get_portfolio(query \\ []) do
    case get("/portfolio", query: query) do
      {:ok, %{body: body, status: 200}} -> {:ok, PortfolioItem.from_response_body(body)}
      {:ok, %{body: body}} -> {:error, Error.new(body)}
    end
  end

  @doc """
  Fetch the current `t:LemonMarketsEx.User.t/0` for the authenticated client.

  See: https://paper-trading.lemon.markets/v1/docs#/user/user_get_user__get

  ## Examples

      iex> LemonMarketsEx.Trading.get_user
      {:ok,
        %{
          mode: "paper",
          results: %LemonMarketsEx.User{
            account_id: "acc_1337",
            country: "de",
            created_at: "2021-12-18T21:47:19.204+00:00",
            data_plan: "free",
            email: "trader@lemon.markets",
            firstname: "trader@lemon.markets",
            language: "en",
            lastname: nil,
            notifications_general: false,
            notifications_order: false,
            phone: nil,
            phone_verified: nil,
            pin_verified: false,
            tax_allowance: nil,
            tax_allowance_end: nil,
            tax_allowance_start: nil,
            trading_plan: "free",
            user_id: "usr_1337"
          },
          status: "ok",
          time: "2021-12-26T17:46:33.108+00:00"
        }}
  """
  @doc tags: [:user]
  @spec get_user :: {:error, Error.t()} | {:ok, %{mode: binary(), results: User.t(), status: binary(), time: binary()}}
  def get_user do
    case get("/user") do
      {:ok, %{body: body, status: 200}} -> {:ok, User.from_response_body(body)}
      {:ok, %{body: body}} -> {:error, Error.new(body)}
    end
  end

  @doc """
  Retrieves your spaces from the lemon.markets Trading API.

  See: https://docs.lemon.markets/trading/spaces

  ## Parameters

  * `query` - A keyword list of query parameters.
    * `page` (optional) - The specific results page you want to request. - See: https://docs.lemon.markets/trading/overview#pagination-in-the-trading-api
    * `limit` (optional) - The amount of results per page. - See: https://docs.lemon.markets/trading/overview#pagination-in-the-trading-api
    * `type` (optional) - Filter for manual or automated spaces (`"manual"` or `"auto"`). Automated spaces are coming soon.

  ## Examples

      iex> LemonMarketsEx.Trading.get_spaces
      {:ok,
        %{
        mode: "paper",
        next: nil,
        page: 1,
        pages: 1,
        previous: nil,
        results: [%LemonMarketsEx.Space{}, ...],
        status: "ok",
        time: "2021-12-26T21:35:55.546+00:00",
        total: 0
      }}

  """
  @doc tags: [:space]
  @spec get_spaces(keyword()) ::
          {:error, Error.t()}
          | {:ok,
             %{
               mode: String.t(),
               status: String.t(),
               time: String.t(),
               next: String.t() | nil,
               previous: String.t() | nil,
               page: integer(),
               pages: integer(),
               results: [Space.t(), ...],
               total: integer()
             }}
  def get_spaces(query \\ []) do
    case get("/spaces", query: query) do
      {:ok, %{body: body, status: 200}} -> {:ok, Space.from_response_body(body)}
      {:ok, %{body: body}} -> {:error, Error.new(body)}
    end
  end

  @doc """
  Retrieves a single space from the lemon.markets Trading API.

  See: https://docs.lemon.markets/trading/spaces

  ## Examples

      iex> LemonMarketsEx.Trading.get_space(space_id)
      {:ok,
        %{
        mode: "paper",
        results: %LemonMarketsEx.Space{},
        status: "ok",
        time: "2021-12-26T21:35:55.546+00:00",
      }}

  """
  @doc tags: [:space]
  @spec get_space(binary()) ::
          {:error, Error.t()} | {:ok, %{:mode => String.t(), :status => String.t(), :time => String.t(), :results => Space.t()}}
  def get_space(space_id) do
    case get("/spaces/#{space_id}") do
      {:ok, %{body: body, status: 200}} -> {:ok, Space.from_response_body(body)}
      {:ok, %{body: body}} -> {:error, Error.new(body)}
    end
  end

  @doc """
  Creates a new space on the lemon.markets Trading API.

  See: https://docs.lemon.markets/trading/spaces

  ## Parameters

    * `params` - A map of request body params.
      * `name` (required) - Give your new Space a name.
      * `type` (required) - Define the Space type. Currently, we only offer manual Spaces (`"manual"`). Automated spaces (`"auto"`) are coming soon.
      * `risk_limit` (required) - Risk limit of your new Space. The Risk Limit defines the maximum amount of money you can spend for trades executed in that space.
      * `description` (optional) - Description of the new Space.

  ## Examples

      iex> params = %{name: "Stonks", type: "manual", risk_limit: 100000000}
      iex> LemonMarketsEx.Trading.create_space(params)
      {:ok,
        %{
        mode: "paper",
        results: %LemonMarketsEx.Space{},
        status: "ok",
        time: "2021-12-26T21:35:55.546+00:00",
      }}

  """
  @doc tags: [:space]
  @spec create_space(map()) ::
          {:error, Error.t()} | {:ok, %{:mode => String.t(), :status => String.t(), :time => String.t(), :results => Space.t()}}
  def create_space(params) do
    case post("/spaces", params) do
      {:ok, %{body: body, status: 200}} -> {:ok, Space.from_response_body(body)}
      {:ok, %{body: body}} -> {:error, Error.new(body)}
    end
  end

  @doc """
  Updates a space on the lemon.markets Trading API.

  See: https://docs.lemon.markets/trading/spaces

  ## Parameters

    * `params` - A map of request body params.
      * `name` (optional) - Give your new Space a name.
      * `linked` (optional) - Real Money Spaces only: new potential linked Paper Money Space
      * `risk_limit` (optional) - Risk limit of your new Space. The Risk Limit defines the maximum amount of money you can spend for trades executed in that space.
      * `description` (optional) - Description of the new Space.

  ## Examples

      iex> params = %{name: "Stonks"}
      iex> LemonMarketsEx.Trading.update_space(space_id, params)
      {:ok,
        %{
        mode: "paper",
        results: %LemonMarketsEx.Space{},
        status: "ok",
        time: "2021-12-26T21:35:55.546+00:00",
      }}

  """
  @doc tags: [:space]
  @spec update_space(binary(), map()) ::
          {:error, Error.t()} | {:ok, %{:mode => String.t(), :status => String.t(), :time => String.t(), :results => Space.t()}}
  def update_space(space_id, params) do
    case put("/spaces/#{space_id}", params) do
      {:ok, %{body: body, status: 200}} -> {:ok, Space.from_response_body(body)}
      {:ok, %{body: body}} -> {:error, Error.new(body)}
    end
  end

  @doc """
  Deletes a space from the lemon.markets Trading API.

  You can only delete an empty space, meaning that the space has nothing in its portfolio and no pending orders.
  See: https://docs.lemon.markets/trading/spaces

   ## Examples

      iex> LemonMarketsEx.Trading.delete_space(space_id)
      {:ok, %{mode: "paper", status: "ok", time: "2021-12-26T23:09:51.496+00:00"}}

  """
  @doc tags: [:space]
  @spec delete_space(binary()) :: {:error, Error.t()} | {:ok, %{:mode => String.t(), :status => String.t(), :time => String.t()}}
  def delete_space(space_id) do
    case delete("/spaces/#{space_id}") do
      {:ok, %{body: body, status: 200}} -> {:ok, Space.from_response_body(body)}
      {:ok, %{body: body}} -> {:error, Error.new(body)}
    end
  end
end
