defmodule Mix.Commanded.ProcessManager do
  alias __MODULE__

  defstruct module: nil,
            context_module: nil,
            alias: nil,
            singular: nil,
            human_singular: nil,
            file: nil,
            context_app: nil,
            event_application_module: nil,
            generate?: true,
            opts: [],
            events: []

  def new([context_name, aggregate_name], _attrs, opts) do
    aggregate_module = inspect(Module.concat([context_name, ProcessManagers, aggregate_name]))
    ctx_app = opts[:context_app] || Mix.Commanded.context_app()
    otp_app = Mix.Commanded.otp_app()
    opts = Keyword.merge(Application.get_env(otp_app, :generators, []), opts)
    base = Mix.Commanded.context_base(ctx_app)
    basename = CmdGen.Naming.underscore(aggregate_module)
    event_application_module = Module.concat([base, "Application"])
    module = Module.concat([base, aggregate_module])
    file = Mix.Commanded.context_lib_path(ctx_app, basename <> ".ex")

    events =
      for e <- pick(opts, [:event]) do
        new_event(context_name, e, opts)
      end

    singular =
      module
      |> Module.split()
      |> List.last()
      |> CmdGen.Naming.underscore()

    %ProcessManager{
      opts: opts,
      module: module,
      context_module: context_module(module),
      singular: singular,
      human_singular: CmdGen.Naming.humanize(singular),
      alias: module |> Module.split() |> List.last() |> Module.concat(nil),
      file: file,
      context_app: ctx_app,
      event_application_module: event_application_module,
      events: events
    }
    |> dbg()
  end

  def valid?(schema) do
    schema =~ ~r/^[A-Z]\w*(\.[A-Z]\w*)*$/
  end

  defp pick(keyword, keys) do
    keyword |> Keyword.take(keys) |> Keyword.values()
  end

  defp new_event(context_name, command, opts) when is_binary(command) do
    command_name = command |> CmdGen.Naming.camelize()
    Mix.Commanded.Event.new([context_name, command_name], opts)
  end

  defp context_module(aggregate_module) do
    {module_list, _} = Module.split(aggregate_module) |> Enum.split(2)
    module_list |> Module.concat()
  end
end
