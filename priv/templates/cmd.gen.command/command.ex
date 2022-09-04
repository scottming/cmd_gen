defmodule <%= inspect command.module %> do
  @moduledoc """
  <%= command.human_singular %> command.
  """

  alias __MODULE__

  defstruct [
    :<%= command.aggregate_singular %>_id,
    <%= (for {f, _t}<- command.types, do: inspect f) |> Enum.join(",\n    ") %>
  ]
end
