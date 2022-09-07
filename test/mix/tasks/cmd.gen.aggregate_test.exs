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
      aggregate =
        Gen.Aggregate.build(~w(Accounts User name:string email:string --command CreateUser->UserRegistered), [])

      assert %Aggregate{
               module: CmdGen.Accounts.Aggregates.User,
               context_module: CmdGen.Accounts,
               alias: User,
               singular: "user",
               human_singular: "User",
               file: "lib/cmd_gen/accounts/aggregates/user.ex",
               context_app: :cmd_gen,
               generate?: true,
               opts: [command: "CreateUser->UserRegistered"],
               command_with_events: [
                 {%Command{
                    opts: [command: "CreateUser->UserRegistered"],
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
                    module: CmdGen.Accounts.Events.UserRegistered,
                    singular: "user_registered",
                    human_singular: "User registered",
                    alias: UserRegistered,
                    file: "lib/cmd_gen/accounts/events/user_registered.ex",
                    context_app: :cmd_gen,
                    aggregate_singular: nil
                  }}
               ],
               attrs: [name: :string, email: :string],
               types: %{email: :string, name: :string}
             } == aggregate
    end)
  end

  test "handle existing aggregate" do
    in_tmp_project("build", fn ->
      aggregate = Gen.Aggregate.run(~w(Accounts User name:string email:string --command CreateUser->UserRegistered))

      assert_file("lib/cmd_gen/accounts/aggregates/user.ex", fn file ->
        assert file =~ "def execute(%User{}, %CreateUser{}) "
        assert file =~ "def apply(%User{} = state, %UserRegistered{}) "
      end)

      send(self(), {:mix_shell_input, :yes?, true})
      Gen.Aggregate.run(~w(Accounts User name:string email:string --command Rename->UserRenamed))
      assert_received {:mix_shell, :info, ["You are generating into an existing aggregate" <> notice]}
      # TODO: count the commands and events
      assert_received {:mix_shell, :yes?, ["Would you like to proceed?"]}

      assert_file("lib/cmd_gen/accounts/aggregates/user.ex", fn file ->
        assert file =~ "def execute(%User{}, %CreateUser{}) "
        assert file =~ "def apply(%User{} = state, %UserRegistered{}) "

        # new command -> event
        assert file =~ "def execute(%User{}, %Rename{}) "
        assert file =~ "def apply(%User{} = state, %UserRenamed{}) "
      end)
    end)
  end
end
