defmodule <%= inspect command.module %> do
  @moduledoc """
  <%= inspect command.module %> command.
  """

  alias __MODULE__

  @type t :: %<%= inspect command.alias %>{
    <%= command.aggregate_singular %>_id: String.t()
  }

  defstruct [
    :<%= command.aggregate_singular %>_id
  ]
end

