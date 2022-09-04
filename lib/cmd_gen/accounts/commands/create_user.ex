defmodule CmdGen.Accounts.Commands.CreateUser do
  @moduledoc """
  Create user command.
  """

  alias __MODULE__

  defstruct [
    :user_id,
    :email,
    :name
  ]
end
