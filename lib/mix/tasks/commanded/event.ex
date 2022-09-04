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

  def new_from_command([context_name, aggregate_name, command_name], fields, opts) do
    event_name = event_name_from(command_name)
    aggregate_singular = CmdGen.Naming.underscore(aggregate_name)

    event = new([context_name, event_name], fields, opts)
    %{event | aggregate_singular: aggregate_singular}
  end

  defp event_name_from(command_name) do
    [verb, entity] =
      command_name
      |> CmdGen.Naming.underscore()
      |> String.split("_", parts: 2)
      |> dbg

    past_tense =
      verb
      |> Verbs.conjugate(%{:tense => "past", :person => "third", :plurality => "singular"})

    CmdGen.Naming.camelize(entity <> "_" <> past_tense)
  end
end
