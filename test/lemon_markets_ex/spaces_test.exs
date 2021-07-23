defmodule LemonMarketsEx.SpacesTest do
  use ExUnit.Case

  alias LemonMarketsEx.{
    Spaces,
    Space,
    State,
    PortfolioItem,
    PortfolioTransaction,
    Transaction,
    Error
  }

  @valid_space_uuid "268908e8-e31d-47bc-b830-8b90f80806ed"
  @invalid_space_uuid "b3f0d687-0813-4bb6-bed8-da4674902938"
  @client %LemonMarketsEx.Client{client: %Tesla.Client{}, space: @valid_space_uuid}

  setup do
    Tesla.Mock.mock(fn env ->
      case env.url do
        "/state" ->
          %Tesla.Env{status: 200, body: Jason.decode!(File.read!("test/fixtures/state.json"))}

        "/spaces" ->
          %Tesla.Env{status: 200, body: Jason.decode!(File.read!("test/fixtures/spaces.json"))}

        "/spaces" <> "/#{@valid_space_uuid}" ->
          %Tesla.Env{status: 200, body: Jason.decode!(File.read!("test/fixtures/space.json"))}

        "/spaces" <> "/#{@valid_space_uuid}" <> "/state" ->
          %Tesla.Env{
            status: 200,
            body: Jason.decode!(File.read!("test/fixtures/space_state.json"))
          }

        "/spaces" <> "/#{@valid_space_uuid}" <> "/portfolio" ->
          %Tesla.Env{
            status: 200,
            body: Jason.decode!(File.read!("test/fixtures/portfolio.json"))
          }

        "/spaces" <> "/#{@valid_space_uuid}" <> "/portfolio/transactions" ->
          %Tesla.Env{
            status: 200,
            body: Jason.decode!(File.read!("test/fixtures/portfolio_transactions.json"))
          }

        "/spaces" <> "/#{@valid_space_uuid}" <> "/transactions" ->
          %Tesla.Env{
            status: 200,
            body: Jason.decode!(File.read!("test/fixtures/transactions.json"))
          }

        "/spaces" <> "/#{@valid_space_uuid}" <> "/transactions" <> "/" <> <<_uuid::288>> ->
          %Tesla.Env{
            status: 200,
            body: Jason.decode!(File.read!("test/fixtures/transaction.json"))
          }

        _ ->
          %Tesla.Env{status: 404, body: "Not Found"}
      end
    end)

    :ok
  end

  test "get_state/1 successfully returns the state of your account" do
    assert {:ok,
            %State{
              cash_account_number: nil,
              securities_account_number: nil,
              state: %{balance: "89999.0000"}
            }} = Spaces.get_state(@client)
  end

  test "get_spaces/2 successfully returns all spaces" do
    {:ok, %{next: next, previous: previous, results: results}} = Spaces.get_spaces(@client)

    assert is_nil(next)
    assert is_nil(previous)

    assert %Space{
             uuid: @valid_space_uuid,
             name: "Test",
             type: "strategy",
             state: state
           } = List.first(results)

    assert state == %{balance: "9224.8800", cash_to_invest: "8427.7320"}
  end

  test "get_space/2 successfully returns a single space" do
    assert {:ok,
            %Space{
              uuid: @valid_space_uuid,
              name: "Test",
              type: "strategy",
              state: state
            }} = Spaces.get_space(@client, @valid_space_uuid)

    assert state == %{balance: "9224.8800", cash_to_invest: "8427.7320"}
  end

  test "get_space/2 returns a not found error when the space_uuid is unknown" do
    assert {:error,
            %Error{
              detail: nil,
              error: "Not Found",
              error_description: "The requested resource was not found on this server.",
              status: 404
            }} = Spaces.get_space(@client, @invalid_space_uuid)
  end

  test "get_space_state/2 successfully returns a space's state" do
    assert {:ok, %{balance: "9224.8800", cash_to_invest: "8427.7320"}} =
             Spaces.get_space_state(@client, @valid_space_uuid)
  end

  test "get_portfolio/2 successfully returns the spaces portfolio items" do
    assert {
             :ok,
             %{
               next: nil,
               previous: nil,
               results: [
                 %PortfolioItem{
                   average_price: "189.0000",
                   instrument: %{isin: "US19260Q1076", title: "COINBASE GLOBAL INC."},
                   latest_total_value: "189.0000",
                   quantity: 1
                 },
                 %PortfolioItem{
                   average_price: "117.2240",
                   instrument: %{isin: "US0090661010", title: "AIRBNB INC."},
                   latest_total_value: "581.4000",
                   quantity: 5
                 }
               ]
             }
           } = Spaces.get_portfolio(@client)
  end

  test "get_portfolio_transactions/2 successfully returns the spaces portfolio transactions" do
    assert {
             :ok,
             %{
               next: nil,
               previous: nil,
               results: [
                 %PortfolioTransaction{
                   average_price: "116.2800",
                   instrument: %{isin: "US0090661010", title: "AIRBNB INC."},
                   order_id: "0f91b8f4-8524-4692-a26c-586a800570ae",
                   quantity: 1,
                   side: "buy",
                   uuid: "c8e8dc01-3e73-4980-baa8-af44c3f47a5f"
                 },
                 %PortfolioTransaction{
                   average_price: "189.0000",
                   instrument: %{isin: "US19260Q1076", title: "COINBASE GLOBAL INC."},
                   order_id: "e194f0fc-98e5-47e9-8c4b-c37e1c3d64b4",
                   quantity: 1,
                   side: "buy",
                   uuid: "2712215b-8ed1-445f-a78d-917b46785616"
                 },
                 %PortfolioTransaction{
                   average_price: "117.4600",
                   instrument: %{isin: "US0090661010", title: "AIRBNB INC."},
                   order_id: "f4515dd5-bb80-4fb2-8e76-43e1b63dfe91",
                   quantity: 4,
                   side: "buy",
                   uuid: "6c43c560-087a-40e6-987b-e234939a7da5"
                 }
               ]
             }
           } = Spaces.get_portfolio_transactions(@client)
  end

  test "get_transactions/2 successfully returns all the spaces transactions" do
    assert {
             :ok,
             %{
               next: nil,
               previous: nil,
               results: [
                 %Transaction{
                   amount: "-10000.0000",
                   created_at: 1_627_041_962.22977,
                   order: nil,
                   type: "pay_out",
                   uuid: "506339d0-0a0d-489d-96ed-d0970ac28c8c"
                 },
                 %Transaction{
                   amount: "10000.0000",
                   created_at: 1_627_041_953.6241,
                   order: nil,
                   type: "pay_in",
                   uuid: "d20ddd76-79c9-46a2-91f0-a576708865ca"
                 },
                 %Transaction{
                   amount: "-10000.0000",
                   created_at: 1_627_041_844.729101,
                   order: nil,
                   type: "pay_out",
                   uuid: "c67c8cbb-3dd6-4285-810a-ec8a5875ccca"
                 },
                 %Transaction{
                   amount: "10000.0000",
                   created_at: 1_627_041_818.517731,
                   order: nil,
                   type: "pay_in",
                   uuid: "759c3ef4-7382-4468-8639-5ea11a6e1f20"
                 },
                 %Transaction{
                   amount: "-116.2800",
                   created_at: 1_626_809_113.719907,
                   order: %{
                     average_price: "116.2800",
                     instrument: %{isin: "US0090661010", title: "AIRBNB INC."},
                     processed_quantity: 1,
                     uuid: "0f91b8f4-8524-4692-a26c-586a800570ae"
                   },
                   type: "order_buy",
                   uuid: "5318faa7-5c02-4de4-9ef8-e7b02346e5bc"
                 },
                 %Transaction{
                   amount: "-189.0000",
                   created_at: 1_626_692_210.910907,
                   order: %{
                     average_price: "189.0000",
                     instrument: %{isin: "US19260Q1076", title: "COINBASE GLOBAL INC."},
                     processed_quantity: 1,
                     uuid: "e194f0fc-98e5-47e9-8c4b-c37e1c3d64b4"
                   },
                   type: "order_buy",
                   uuid: "25667e11-11bc-49fa-9e9b-f3aaf2e7108c"
                 },
                 %Transaction{
                   amount: "-469.8400",
                   created_at: 1_626_444_133.788213,
                   order: %{
                     average_price: "117.4600",
                     instrument: %{isin: "US0090661010", title: "AIRBNB INC."},
                     processed_quantity: 4,
                     uuid: "f4515dd5-bb80-4fb2-8e76-43e1b63dfe91"
                   },
                   type: "order_buy",
                   uuid: "64261e0a-ef90-4e07-8f5a-ecd3feac9411"
                 },
                 %Transaction{
                   amount: "10000.0000",
                   created_at: 1_626_443_926.119588,
                   order: nil,
                   type: "pay_in",
                   uuid: "30cfa9d1-6389-4347-8368-4667adad3e8c"
                 }
               ]
             }
           } = Spaces.get_transactions(@client)
  end

  test "get_transaction/2 successfully returns a single transaction" do
    assert {:ok,
            %LemonMarketsEx.Transaction{
              amount: "-10000.0000",
              created_at: 1_627_041_962.22977,
              order: nil,
              type: "pay_out",
              uuid: "506339d0-0a0d-489d-96ed-d0970ac28c8c"
            }} = Spaces.get_transaction(@client, "506339d0-0a0d-489d-96ed-d0970ac28c8c")
  end
end
