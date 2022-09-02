defmodule <%= inspect process_manager.module %> do
  @moduledoc """
  <%= inspect process_manager.human_singular %> process_manager.
  """
  use Commanded.ProcessManagers.ProcessManager,
    application: <%= inspect process_manager.event_application_module %>,
    name: __MODULE__,
    start_from: :origin

  alias __MODULE__

  alias <%= inspect process_manager.context_module %>.Events.{<%= (for e <- process_manager.events, do: inspect e.alias) |> Enum.join(", ") %>}

  @derive Jason.Encoder
  defstruct [
    :process_uuid
  ]

  # TODO: {:start, process_uuid} | {:continue, process_uuid} | {:stop, process_uuid}
  @impl true<%= for event <- process_manager.events do %>
  def interested?(%<%= inspect event.alias %>{}) do
  end
  <% end %>

  @impl true<%= for event <- process_manager.events do %>
  def handle(%<%= inspect process_manager.alias %>{}, %<%= inspect event.alias %>{}) do
    []
  end
  <% end %>

  @impl true<%= for event <- process_manager.events do %>
  def apply(%<%= inspect process_manager.alias %>{} = state, %<%= inspect event.alias %>{}) do
    state
  end
  <% end %>

  @impl true
  def error(_error, _failure_source, _failure_context) do
    :skip
  end
end

