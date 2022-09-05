defmodule Mix.Commanded.Command do
  defstruct opts: [],
            module: nil,
            singular: nil,
            human_singular: nil,
            alias: nil,
            file: nil,
            context_app: nil,
            aggregate_singular: nil,
            attrs: [],
            types: %{}

  alias __MODULE__

  def new(args, fields \\ [], opts \\ [])

  def new([context_name, aggregate_name, command_name], cli_attrs, opts) do
    aggregate_singular = CmdGen.Naming.underscore(aggregate_name)
    %{new([context_name, command_name], cli_attrs, opts) | aggregate_singular: aggregate_singular}
  end

  def new([context_name, command_name], cli_attrs, opts) do
    command_module = inspect(Module.concat([context_name, Commands, command_name]))
    ctx_app = opts[:context_app] || Mix.Commanded.context_app()
    otp_app = Mix.Commanded.otp_app()
    opts = Keyword.merge(Application.get_env(otp_app, :generators, []), opts)

    base = Mix.Commanded.context_base(ctx_app)
    basename = CmdGen.Naming.underscore(command_module)
    module = Module.concat([base, command_module])

    file = Mix.Commanded.context_lib_path(ctx_app, basename <> ".ex")
    attrs = extract_attr_flags(cli_attrs)
    types = types(attrs)

    singular =
      module
      |> Module.split()
      |> List.last()
      |> CmdGen.Naming.underscore()

    %Command{
      opts: opts,
      context_app: ctx_app,
      module: module,
      singular: singular,
      human_singular: CmdGen.Naming.humanize(singular),
      alias: module |> Module.split() |> List.last() |> Module.concat(nil),
      file: file,
      attrs: attrs,
      types: types
    }
  end

  def new_from_aggregate([context_name, command_to_event], cli_attrs, opts) when is_list(cli_attrs) do
    command_name = String.split(command_to_event, "->") |> List.first() |> String.trim()
    new([context_name, command_name], cli_attrs, opts)
  end

  defp extract_attr_flags(cli_attrs) do
    for a <- cli_attrs, is_binary(a) do
      [field, type] = String.split(a, ":")
      {String.to_atom(field), String.to_atom(type)}
    end
  end

  defp types(attrs) do
    Map.new(attrs)
  end

  def valid?(schema) do
    schema =~ ~r/^[A-Z]\w*(\.[A-Z]\w*)*$/
  end
end
