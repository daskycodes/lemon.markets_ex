defmodule LemonMarketsEx.OrdersTest do
  use ExUnit.Case

  alias LemonMarketsEx.{Orders, Order}

  @valid_space_uuid "268908e8-e31d-47bc-b830-8b90f80806ed"
  @valid_order_uuid "4c4cc6a3-1692-4487-99fb-198b8e2d490a"
  @client %LemonMarketsEx.Client{client: %Tesla.Client{}, space: @valid_space_uuid}

  setup do
    Tesla.Mock.mock(fn
      %{method: :get} = env ->
        case env.url do
          "/spaces" <> "/" <> <<_uuid::288>> <> "/orders" ->
            %Tesla.Env{status: 200, body: Jason.decode!(File.read!("test/fixtures/orders.json"))}

          "/spaces" <> "/" <> <<_uuid::288>> <> "/orders" <> "/#{@valid_order_uuid}" ->
            %Tesla.Env{status: 200, body: Jason.decode!(File.read!("test/fixtures/order.json"))}

          _ ->
            %Tesla.Env{status: 404, body: "Not Found"}
        end

      %{method: :post, url: "/spaces" <> "/" <> <<_uuid::288>> <> "/orders"} ->
        %Tesla.Env{
          status: 201,
          body: Jason.decode!(File.read!("test/fixtures/create_order.json"))
        }

      %{
        method: :put,
        url:
          "/spaces" <>
              "/" <> <<_uuid::288>> <> "/orders" <> "/" <> <<_order_uuid::288>> <> "/activate"
      } ->
        %Tesla.Env{
          status: 200,
          body: Jason.decode!(File.read!("test/fixtures/activate_order.json"))
        }

      %{
        method: :delete,
        url: "/spaces" <> "/" <> <<_uuid::288>> <> "/orders" <> "/" <> <<_order_uuid::288>>
      } ->
        %Tesla.Env{status: 204}
    end)

    :ok
  end

  test "get_orders/2 successfully returns all orders in the clients space" do
    assert {:ok, %{next: nil, previous: nil, results: orders}} = Orders.get_orders(@client)

    assert %Order{
             average_price: "0.0000",
             created_at: 1_626_993_165.675849,
             instrument: %{isin: "US0090661010", title: "AIRBNB INC."},
             limit_price: nil,
             processed_at: nil,
             processed_quantity: 0,
             quantity: 1,
             side: "buy",
             status: "inactive",
             stop_price: nil,
             trading_venue_mic: "XMUN",
             type: "market",
             uuid: "8a8df021-92ce-4049-a2bb-ad46120ebf2f",
             valid_until: 1_626_995_082.0
           } = List.first(orders)
  end

  test "get_order/2 successfully returns a single order in the clients space" do
    assert {
             :ok,
             %LemonMarketsEx.Order{
               valid_until: 1_626_869_086.0,
               average_price: "0.0000",
               created_at: 1_626_865_486.688425,
               instrument: %{isin: "US0090661010", title: "AIRBNB INC."},
               limit_price: "120.0000",
               processed_at: nil,
               processed_quantity: 0,
               quantity: 1,
               side: "buy",
               status: "expired",
               stop_price: "100.0000",
               trading_venue_mic: "XMUN",
               type: "stop_limit",
               uuid: @valid_order_uuid
             }
           } = Orders.get_order(@client, @valid_order_uuid)
  end

  test "create_order/2 successfully returns the created order" do
    create_order_params = %{
      isin: "US0090661010",
      valid_until: 1_626_995_082,
      side: "buy",
      quantity: 1
    }

    assert {:ok,
            %LemonMarketsEx.Order{
              average_price: nil,
              created_at: nil,
              instrument: %{isin: "US0090661010", title: nil},
              limit_price: nil,
              processed_at: nil,
              processed_quantity: nil,
              quantity: 1,
              side: "buy",
              status: "inactive",
              stop_price: nil,
              trading_venue_mic: "XMUN",
              type: nil,
              uuid: "7160ccfa-51aa-4a0c-9f6c-0d836c6a735a",
              valid_until: 1_626_995_082.0
            }} = Orders.create_order(@client, create_order_params)
  end

  test "activate_order/2 successfully activates a created order" do
    assert {:ok, %{status: "activated"}} =
             Orders.activate_order(@client, %Order{uuid: @valid_order_uuid})

    assert {:ok, %{status: "activated"}} = Orders.activate_order(@client, @valid_order_uuid)
  end

  test "delete_order/2 successfully activates a created order" do
    assert :ok = Orders.delete_order(@client, %Order{uuid: @valid_order_uuid})
    assert :ok = Orders.delete_order(@client, @valid_order_uuid)
  end
end
