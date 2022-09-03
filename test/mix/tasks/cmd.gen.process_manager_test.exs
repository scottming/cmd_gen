Code.require_file("../../support/mix_helper.exs", __DIR__)

defmodule Mix.Tasks.Cmd.Gen.ProcessManagerTest do
  import MixHelper
  use ExUnit.Case
  alias Mix.Commanded.ProcessManager
  alias Mix.Tasks.Cmd.Gen

  setup do
    Mix.Task.clear()
    :ok
  end

  test "build" do
    in_tmp_project("build", fn ->
      process_manager = Gen.ProcessManager.build(~w(Execution Transfer amount:string status:string), [])

      assert %ProcessManager{
               context_module: CmdGen.Execution,
               event_application_module: CmdGen.Application,
               events: [],
               alias: Transfer,
               file: "lib/cmd_gen/execution/process_managers/transfer.ex",
               human_singular: "Transfer",
               module: CmdGen.Execution.ProcessManagers.Transfer,
               opts: [],
               singular: "transfer",
               attrs: [amount: :string, status: :string],
               types: %{amount: :string, status: :string}
             } = process_manager

      assert String.ends_with?(process_manager.file, "lib/cmd_gen/execution/process_managers/transfer.ex")
    end)
  end
end
