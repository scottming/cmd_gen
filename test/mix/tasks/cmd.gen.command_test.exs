Code.require_file("../../support/mix_helper.exs", __DIR__)

defmodule Mix.Tasks.Cmd.Gen.CommandTest do
  import MixHelper
  use ExUnit.Case
  alias Mix.Commanded.{Command, Event}
  alias Mix.Tasks.Cmd.Gen

  setup do
    Mix.Task.clear()
    :ok
  end

  test "build" do
    in_tmp_project("build", fn ->
      {command, event} = Gen.Command.build(~w(Accounts User CreateUser name:string email:string), [])

      assert %Command{
               aggregate_singular: "user",
               context_app: :cmd_gen,
               alias: CreateUser,
               module: CmdGen.Accounts.Commands.CreateUser,
               human_singular: "Create user",
               singular: "create_user",
               attrs: [name: :string, email: :string],
               types: %{name: :string, email: :string}
             } = command

      assert %Event{
               context_app: :cmd_gen,
               aggregate_singular: "user",
               alias: UserCreated,
               module: CmdGen.Accounts.Events.UserCreated,
               human_singular: "User created",
               singular: "user_created"
             } = event

      assert String.ends_with?(command.file, "lib/cmd_gen/accounts/commands/create_user.ex")
      assert String.ends_with?(event.file, "lib/cmd_gen/accounts/events/user_created.ex")
    end)
  end
end
