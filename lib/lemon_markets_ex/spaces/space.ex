defmodule LemonMarketsEx.Space do
  defstruct [:uuid, :name, :state, :type]
  use ExConstructor

  import LemonMarketsEx.Utils

  @type t() :: %__MODULE__{
          uuid: String.t(),
          name: String.t(),
          state: %{
            balance: String.t(),
            cash_to_invest: String.t()
          },
          type: String.t()
        }

  @spec from_body(map()) :: __MODULE__.t()
  def from_body(result) do
    space = new(result)
    %{space | state: map_from_result(space.state)}
  end
end
