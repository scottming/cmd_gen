defmodule <%= inspect aggregate.module %> do
  @moduledoc """
  <%= aggregate.human_singular %> aggregate.
  """

  alias __MODULE__

  <%= if aggregate.types do %>
  defstruct [
    :<%= aggregate.singular %>_id,
    <%= (for {k, _t} <- aggregate.types, do: inspect k) |> Enum.join(",\n    ")%>,
  ]
  <% end %>
end
