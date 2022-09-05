defmodule Mix.Tasks.Cmd.Gen.Aggregate do
  @shortdoc "Generates an aggregate"

  use Mix.Task

  alias Mix.Commanded.Aggregate

  @switches [
    context_app: :string,
    command: :keep
  ]

  @doc false
  def run(args) do
    if Mix.Project.umbrella?() do
      Mix.raise("mix cmd.gen.aggregate must be invoked from within your *_web application root directory")
    end

    aggregate = build(args, [])
    paths = Mix.Commanded.generator_paths()

    prompt_for_conflicts(aggregate)

    aggregate
    |> copy_new_files(paths, aggregate: aggregate)
  end

  defp prompt_for_conflicts(aggregate) do
    aggregate
    |> files_to_be_generated()
    |> Mix.Commanded.prompt_for_conflicts()
  end

  @doc false
  def build(args, parent_opts, help \\ __MODULE__) do
    {aggregate_opts, parsed, _} = OptionParser.parse(args, switches: @switches)
    [context_name, aggregate_name | attrs] = validate_args!(parsed, help)

    opts =
      parent_opts
      |> Keyword.merge(aggregate_opts)
      |> put_context_app(aggregate_opts[:context_app])

    aggregate = Aggregate.new([context_name, aggregate_name], attrs, opts)
    aggregate
  end

  defp put_context_app(opts, nil), do: opts

  defp put_context_app(opts, string) do
    Keyword.put(opts, :context_app, String.to_atom(string))
  end

  @doc false
  def files_to_be_generated(%Aggregate{} = aggregate) do
    [{:eex, "aggregate.ex", aggregate.file}]
  end

  @doc false
  def copy_new_files(%Aggregate{context_app: _ctx_app} = aggregate, paths, binding) do
    files = files_to_be_generated(aggregate)
    Mix.Commanded.copy_from(paths, "priv/templates/cmd.gen.aggregate", binding, files)
    aggregate
  end

  @doc false
  def validate_args!([aggregate | _] = args, help) do
    cond do
      not Aggregate.valid?(aggregate) ->
        help.raise_with_help("Expected the aggregate argument, #{inspect(aggregate)}, to be a valid module name")

      true ->
        args
    end
  end

  def validate_args!(_, help) do
    help.raise_with_help("Invalid arguments")
  end

  @doc false
  @spec raise_with_help(String.t()) :: no_return()
  def raise_with_help(msg) do
    Mix.raise("""
    #{msg}

    mix cmd.gen.aggregate expects both a module name and
    the plural of the generated resource followed by
    any number of attributes:

        mix cmd.gen.aggregate Blog Post title:string --command 'CreatePost -> PostCreated'
    """)
  end
end
