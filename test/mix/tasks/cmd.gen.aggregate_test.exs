Code.require_file("../../support/mix_helper.exs", __DIR__)

defmodule Mix.Tasks.Cmd.Gen.AggregateTest do
  import MixHelper
  use ExUnit.Case
  alias Mix.Commanded.{Aggregate, Command, Event}
  alias Mix.Tasks.Cmd.Gen

  setup do
    Mix.Task.clear()
    :ok
  end

  test "build" do
    in_tmp_project("build", fn ->
      aggregate = Gen.Aggregate.build(~w(Accounts User name:string email:string --command CreateUser->UserCreated), [])

      %Aggregate{
        module: CmdGen.Accounts.Aggregates.User,
        context_module: CmdGen.Accounts,
        alias: User,
        singular: "user",
        human_singular: "User",
        file: "lib/cmd_gen/accounts/aggregates/user.ex",
        context_app: :cmd_gen,
        generate?: true,
        opts: [command: "CreateUser->UserCreated"],
        command_with_events: [
          {%Command{
             opts: [command: "CreateUser->UserCreated"],
             module: CmdGen.Accounts.Commands.CreateUser,
             singular: "create_user",
             human_singular: "Create user",
             alias: CreateUser,
             file: "lib/cmd_gen/accounts/commands/create_user.ex",
             context_app: :cmd_gen,
             aggregate_singular: nil,
             attrs: [],
             types: %{}
           },
           %Event{
             opts: [],
             module: CmdGen.Accounts.Events.UserCreated,
             singular: "user_created",
             human_singular: "User created",
             alias: UserCreated,
             file: "lib/cmd_gen/accounts/events/user_created.ex",
             context_app: :cmd_gen,
             aggregate_singular: nil
           }}
        ],
        attrs: [name: :string, email: :string],
        types: %{email: :string, name: :string}
      } == aggregate
    end)
  end
end
