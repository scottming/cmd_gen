defmodule <%= inspect event.module %> do
  @moduledoc """
  <%= inspect event.module %> event
  """

  alias __MODULE__

  @type t :: %<%= inspect event.alias %>{
    <%= event.aggregate_singular %>_id: String.t(),
    version: pos_integer()
  }

  @derive Jason.Encoder
  defstruct [
    :<%= event.aggregate_singular %>_id,
    version: 1
  ]

  defimpl Commanded.Serialization.JsonDecoder do
    def decode(%<%= inspect event.alias %>{} = event), do: event
  end

  defimpl Commanded.Event.Upcaster do
    def upcast(%<%= inspect event.alias %>{version: 1} = event, _metadata), do: event
  end
end
