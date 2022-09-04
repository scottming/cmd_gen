defmodule CmdGen.Accounts.Events.UserCreated do
  @moduledoc """
  User created event
  """

  alias __MODULE__

  @type t :: %UserCreated{
    user_id: String.t(),
    version: pos_integer()
  }

  @derive Jason.Encoder
  defstruct [
    :user_id,
    version: 1
  ]

  defimpl Commanded.Serialization.JsonDecoder do
    def decode(%UserCreated{} = event), do: event
  end

  defimpl Commanded.Event.Upcaster do
    def upcast(%UserCreated{version: 1} = event, _metadata), do: event
  end
end
