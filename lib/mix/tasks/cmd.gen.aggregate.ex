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

    # overwrite if needed
    # prompt_for_conflicts(aggregate)
    prompt_for_code_injection(aggregate)

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
    inject_commands_and_events_accesses(aggregate, paths, binding)

    aggregate
  end

  @doc false
  def ensure_context_file_exists(%Aggregate{file: file} = aggregate, paths, binding) do
    unless Aggregate.pre_existing?(aggregate) do
      Mix.Generator.create_file(
        file,
        Mix.Commanded.eval_from(paths, "priv/templates/cmd.gen.aggregate/aggregate.ex", binding)
      )
    end
  end

  defp inject_commands_and_events_accesses(%Aggregate{file: file} = aggregate, paths, binding) do
    ensure_context_file_exists(aggregate, paths, binding)

    paths
    |> Mix.Commanded.eval_from(
      "priv/templates/cmd.gen.aggregate/commands_and_events_accesses.ex",
      binding
    )
    |> inject_eex_before_final_end(file, binding)
  end

  defp inject_eex_before_final_end(content_to_inject, file_path, binding) do
    file = File.read!(file_path)

    if String.contains?(file, content_to_inject) do
      :ok
    else
      Mix.shell().info([:green, "* injecting ", :reset, Path.relative_to_cwd(file_path)])

      file
      |> String.trim_trailing()
      |> String.trim_trailing("end")
      |> EEx.eval_string(binding)
      |> Kernel.<>(content_to_inject)
      |> Kernel.<>("end\n")
      |> write_file(file_path)
    end
  end

  defp write_file(content, file) do
    File.write!(file, content)
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

  def prompt_for_code_injection(%Aggregate{} = aggregate) do
    if Aggregate.pre_existing?(aggregate) && !merge_with_existing_aggregate?(aggregate) do
      System.halt()
    end
  end

  defp merge_with_existing_aggregate?(%Aggregate{} = aggregate) do
    Keyword.get_lazy(aggregate.opts, :merge_with_existing_aggregate, fn ->
      # function_count = Aggregate.function_count(aggregate)
      # file_count = Aggregate.file_count(aggregate)
      # {inspect(aggregate.module)} aggregate currently has #{singularize(function_count, "functions")} and \
      # The
      # {singularize(file_count, "files")} in its directory.

      Mix.shell().info("""
      You are generating into an existing aggregate.

      TODO: count the file

        * It's OK to have multiple resources in the same aggregate as \
      long as they are closely related. But if a aggregate grows too \
      large, consider breaking it apart

        * If they are not closely related, another aggregate probably works better

      The fact two entities are related in the database does not mean they belong \
      to the same aggregate.

      If you are not sure, prefer creating a new aggregate over adding to the existing one.
      """)

      Mix.shell().yes?("Would you like to proceed?")
    end)
  end
end
