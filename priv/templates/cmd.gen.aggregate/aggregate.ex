defmodule <%= inspect aggregate.module %> do
  @moduledoc """
  <%= aggregate.human_singular %> aggregate.
  """

  alias __MODULE__
  alias <%= inspect aggregate.context_module %>.Commands.{<%= (for c <- aggregate.commands, do: inspect c.alias) |> Enum.join(", ") %>}
  alias <%= inspect aggregate.context_module %>.Events.{<%= (for e <- aggregate.events, do: inspect e.alias) |> Enum.join(", ") %>}


  defstruct [
    :<%= aggregate.singular %>_id,
    <%= (for {k, _t} <- aggregate.types, do: inspect k) |> Enum.join(",\n    ")%>,
  ]

  <%= for command <- aggregate.commands do %>
  def execute(%<%= inspect aggregate.alias %>{}, %<%= inspect command.alias %>{}) do
    :ok
  end
  <% end %>
  # State mutators
  <%= for event <- aggregate.events do %>
  def apply(%<%= inspect aggregate.alias %>{} = state, %<%= inspect event.alias %>{}) do
    state
  end
  <% end %>
end
