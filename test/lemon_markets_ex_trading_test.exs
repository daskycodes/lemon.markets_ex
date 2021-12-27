defmodule LemonMarketsEx.TradingTest do
  use ExUnit.Case, async: true

  alias LemonMarketsEx.Account
  alias LemonMarketsEx.Bankstatement
  alias LemonMarketsEx.Document
  alias LemonMarketsEx.Order
  alias LemonMarketsEx.PortfolioItem
  alias LemonMarketsEx.Space
  alias LemonMarketsEx.Trading
  alias LemonMarketsEx.User
  alias LemonMarketsEx.Withdrawal

  describe "Account" do
    test "fetches the authenticated account" do
      Tesla.Mock.mock(fn %{method: :get, url: "https://paper-trading.lemon.markets/v1/account"} ->
        %Tesla.Env{status: 200, body: Jason.decode!(File.read!("test/fixtures/trading/account/account.json"))}
      end)

      assert {:ok, %{results: %Account{} = account}} = Trading.get_account()
      assert account.email == "trader@lemon.markets"
    end

    test "fetches the account's withdrawals" do
      Tesla.Mock.mock(fn %{method: :get, url: "https://paper-trading.lemon.markets/v1/account/withdrawals"} ->
        %Tesla.Env{status: 200, body: Jason.decode!(File.read!("test/fixtures/trading/account/withdrawals.json"))}
      end)

      assert {:ok, %{results: [%Withdrawal{} = withdrawal | _]}} = Trading.get_withdrawals()
      assert withdrawal.id == "wtd_pyQjWNNDDc4KQ64J8L5sphKtLKCwKV39cc"
    end

    test "creates a new withdrawal" do
      Tesla.Mock.mock(fn %{method: :post, url: "https://paper-trading.lemon.markets/v1/account/withdrawals"} ->
        %Tesla.Env{status: 200, body: Jason.decode!(File.read!("test/fixtures/trading/account/create_withdrawal.json"))}
      end)

      assert {:ok, %{mode: "paper", status: "ok", time: _time}} = Trading.create_withdrawal(%{amount: 1_000_000, pin: "1337"})
    end

    test "fetches the account's bankstatements" do
      Tesla.Mock.mock(fn %{method: :get, url: "https://paper-trading.lemon.markets/v1/account/bankstatements"} ->
        %Tesla.Env{status: 200, body: Jason.decode!(File.read!("test/fixtures/trading/account/bankstatements.json"))}
      end)

      assert {:ok, %{results: [%Bankstatement{} = bankstatement | _]}} = Trading.get_bankstatements()
      assert bankstatement.id == "bst_1337"
    end

    test "fetches the account's documents" do
      Tesla.Mock.mock(fn %{method: :get, url: "https://paper-trading.lemon.markets/v1/account/documents"} ->
        %Tesla.Env{status: 200, body: Jason.decode!(File.read!("test/fixtures/trading/account/documents.json"))}
      end)

      assert {:ok, %{results: [%Document{} = document | _]}} = Trading.get_documents()
      assert document.id == "string"
    end

    test "fetches a single account's document" do
      Tesla.Mock.mock(fn %{method: :get, url: "https://paper-trading.lemon.markets/v1/account/documents/1"} ->
        %Tesla.Env{status: 200, body: Jason.decode!(File.read!("test/fixtures/trading/account/document.json"))}
      end)

      assert {:ok, %{results: %Document{} = document}} = Trading.get_document("1")
      assert document.id == "string"
    end
  end

  describe "Order" do
    test "fetches all orders" do
      Tesla.Mock.mock(fn %{method: :get, url: "https://paper-trading.lemon.markets/v1/orders"} ->
        %Tesla.Env{status: 200, body: Jason.decode!(File.read!("test/fixtures/trading/order/orders.json"))}
      end)

      assert {:ok, %{results: [%Order{} = order | _]}} = Trading.get_orders()
      assert order.id == "ord_1337"
    end

    test "fetches a single order" do
      Tesla.Mock.mock(fn %{method: :get, url: "https://paper-trading.lemon.markets/v1/orders/ord_1337"} ->
        %Tesla.Env{status: 200, body: Jason.decode!(File.read!("test/fixtures/trading/order/order.json"))}
      end)

      assert {:ok, %{results: %Order{} = order}} = Trading.get_order("ord_1337")
      assert order.id == "ord_1337"
    end

    test "creates a new order" do
      Tesla.Mock.mock(fn %{method: :post, url: "https://paper-trading.lemon.markets/v1/orders"} ->
        %Tesla.Env{status: 200, body: Jason.decode!(File.read!("test/fixtures/trading/order/create_order.json"))}
      end)

      params = %{
        expires_at: "2021-12-27",
        isin: "US19260Q1076",
        quantity: 1,
        side: "buy",
        space_id: "sp_1337"
      }

      assert {:ok, %{results: %Order{} = order}} = Trading.create_order(params)
      assert order.id == "ord_1337"
    end

    test "activate a created order" do
      Tesla.Mock.mock(fn %{method: :post, url: "https://paper-trading.lemon.markets/v1/orders/ord_1337/activate"} ->
        %Tesla.Env{status: 200, body: Jason.decode!(File.read!("test/fixtures/trading/order/activate_order.json"))}
      end)

      assert {:ok, %{mode: "paper", status: "ok", time: _time}} = Trading.activate_order("ord_1337", %{pin: "1337"})
    end

    test "deletes a created order" do
      Tesla.Mock.mock(fn %{method: :delete, url: "https://paper-trading.lemon.markets/v1/orders/ord_1337"} ->
        %Tesla.Env{status: 200, body: Jason.decode!(File.read!("test/fixtures/trading/order/delete_order.json"))}
      end)

      assert {:ok, %{mode: "paper", status: "ok", time: _time}} = Trading.delete_order("ord_1337")
    end
  end

  describe "Portfolio" do
    test "Fetches the portfolio" do
      Tesla.Mock.mock(fn %{method: :get, url: "https://paper-trading.lemon.markets/v1/portfolio"} ->
        %Tesla.Env{status: 200, body: Jason.decode!(File.read!("test/fixtures/trading/portfolio/portfolio.json"))}
      end)

      assert {:ok, %{results: [%PortfolioItem{} = item | _]}} = Trading.get_portfolio()
      assert item.isin == "US19260Q1076"
    end
  end

  describe "Spaces" do
    test "fetches all spaces" do
      Tesla.Mock.mock(fn %{method: :get, url: "https://paper-trading.lemon.markets/v1/spaces"} ->
        %Tesla.Env{status: 200, body: Jason.decode!(File.read!("test/fixtures/trading/spaces/spaces.json"))}
      end)

      assert {:ok, %{results: [%Space{} = space | _]}} = Trading.get_spaces()
      assert space.name == "Serious Stocks"
    end

    test "fetches a single space" do
      Tesla.Mock.mock(fn %{method: :get, url: "https://paper-trading.lemon.markets/v1/spaces/sp_1337"} ->
        %Tesla.Env{status: 200, body: Jason.decode!(File.read!("test/fixtures/trading/spaces/space.json"))}
      end)

      assert {:ok, %{results: %Space{} = space}} = Trading.get_space("sp_1337")
      assert space.name == "Serious Stocks"
    end

    test "create a new space" do
      Tesla.Mock.mock(fn %{method: :post, url: "https://paper-trading.lemon.markets/v1/spaces"} ->
        %Tesla.Env{status: 200, body: Jason.decode!(File.read!("test/fixtures/trading/spaces/create_space.json"))}
      end)

      params = %{name: "Serious Stocks", type: "manual", risk_limit: 100_000_000}
      assert {:ok, %{results: %Space{} = space}} = Trading.create_space(params)
      assert space.name == "Serious Stocks"
    end

    test "update a space" do
      Tesla.Mock.mock(fn %{method: :put, url: "https://paper-trading.lemon.markets/v1/spaces/sp_1337"} ->
        %Tesla.Env{status: 200, body: Jason.decode!(File.read!("test/fixtures/trading/spaces/update_space.json"))}
      end)

      params = %{name: "Stonks and the City"}
      assert {:ok, %{results: %Space{} = space}} = Trading.update_space("sp_1337", params)
      assert space.name == "Stonks and the City"
    end

    test "deletes a space" do
      Tesla.Mock.mock(fn %{method: :delete, url: "https://paper-trading.lemon.markets/v1/spaces/sp_1337"} ->
        %Tesla.Env{status: 200, body: Jason.decode!(File.read!("test/fixtures/trading/spaces/delete_space.json"))}
      end)

      assert {:ok, %{mode: "paper", status: "ok", time: _time}} = Trading.delete_space("sp_1337")
    end
  end

  describe "User" do
    test "fetches the authenticated user" do
      Tesla.Mock.mock(fn %{method: :get, url: "https://paper-trading.lemon.markets/v1/user"} ->
        %Tesla.Env{status: 200, body: Jason.decode!(File.read!("test/fixtures/trading/user/user.json"))}
      end)

      assert {:ok, %{results: %User{} = user}} = Trading.get_user()
      assert user.email == "trader@lemon.markets"
    end
  end
end
