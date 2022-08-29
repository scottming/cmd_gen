defmodule Mix.Commanded.Event do
  defstruct opts: [],
            module: nil,
            singular: nil,
            human_singular: nil,
            alias: nil,
            file: nil,
            context_app: nil,
            aggregate_singular: nil

  alias __MODULE__

  def new([context_name, event_name], _fields \\ [], opts \\ []) do
    command_module = inspect(Module.concat([context_name, Events, event_name]))
    ctx_app = opts[:context_app] || Mix.Commanded.context_app()
    otp_app = Mix.Commanded.otp_app()
    opts = Keyword.merge(Application.get_env(otp_app, :generators, []), opts)

    base = Mix.Commanded.context_base(ctx_app)
    basename = CmdGen.Naming.underscore(command_module)
    module = Module.concat([base, command_module])

    file = Mix.Commanded.context_lib_path(ctx_app, basename <> ".ex")

    singular =
      module
      |> Module.split()
      |> List.last()
      |> CmdGen.Naming.underscore()

    %Event{
      opts: opts,
      context_app: ctx_app,
      module: module,
      singular: singular,
      human_singular: CmdGen.Naming.humanize(singular),
      alias: module |> Module.split() |> List.last() |> Module.concat(nil),
      file: file
    }
  end
end
