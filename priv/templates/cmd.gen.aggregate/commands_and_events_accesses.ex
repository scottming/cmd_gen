  <%= aggregate.command_with_events && "alias #{inspect aggregate.context_module}.Commands.{#{(for {c, _} <- aggregate.command_with_events, do: inspect c.alias) |> Enum.join(~s(, ))}}"%>
  <%= (for {_, e} <- aggregate.command_with_events, not is_nil(e), do: e) != [] && "alias #{inspect aggregate.context_module}.Events.{#{(for {_, e} <- aggregate.command_with_events, do: inspect e.alias) |> Enum.join(~s(, ))}}"%>

  <%= for {command, event} <- aggregate.command_with_events do %>
  def execute(%<%= inspect aggregate.alias %>{}, %<%= inspect command.alias %>{}) do
    <%= if event, do: "{:ok, %#{inspect event.alias}{}}", else: :ok %>
  end
  <% end %>
  <%= for {_, event} <- aggregate.command_with_events, not is_nil(event) do %>
  def apply(%<%= inspect aggregate.alias %>{} = state, %<%= inspect event.alias %>{}) do
    state
  end
  <% end %>

