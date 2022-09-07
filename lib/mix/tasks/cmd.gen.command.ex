defmodule Mix.Tasks.Cmd.Gen.Command do
  @shortdoc "Generates an command file"

  use Mix.Task

  alias Mix.Commanded.{Command, Event}

  @switches [
    context_app: :string,
    no_event: :boolean
  ]

  @doc false
  def run(args) do
    if Mix.Project.umbrella?() do
      Mix.raise("mix cmd.gen.command must be invoked from within your *_web application root directory")
    end

    {command, event} = build(args, [])
    bindings = [command: command, event: event]
    paths = Mix.Commanded.generator_paths()

    prompt_for_conflicts(command)

    command
    |> copy_new_files(paths, bindings)
  end

  defp prompt_for_conflicts(command) do
    command
    |> files_to_be_generated()
    |> Mix.Commanded.prompt_for_conflicts()
  end

  @doc false
  def build(args, parent_opts, help \\ __MODULE__) do
    {command_opts, parsed, _} = OptionParser.parse(args, switches: @switches)
    [context_name, aggregate_name, command_name | attrs] = validate_args!(parsed, help)

    opts =
      parent_opts
      |> Keyword.merge(command_opts)
      |> put_context_app(command_opts[:context_app])

    command = Command.new([context_name, aggregate_name, command_name], attrs, opts)

    event =
      if not opts[:no_event] do
        Event.new_from_command([context_name, aggregate_name, command_name], attrs, opts)
      end

    {command, event}
  end

  defp put_context_app(opts, nil), do: opts

  defp put_context_app(opts, string) do
    Keyword.put(opts, :context_app, String.to_atom(string))
  end

  @doc false
  def files_to_be_generated(%Command{} = command) do
    [{:eex, "command.ex", command.file}]
  end

  @doc false
  def copy_new_files(%Command{context_app: _ctx_app} = command, paths, binding) do
    files = files_to_be_generated(command)
    Mix.Commanded.copy_from(paths, "priv/templates/cmd.gen.command", binding, files)

    if event = binding[:event] do
      files = [{:eex, "event.ex", event.file}]
      Mix.Commanded.copy_from(paths, "priv/templates/cmd.gen.command", [event: event], files)
    end
  end

  @doc false
  def validate_args!([command | _] = args, help) do
    cond do
      not Command.valid?(command) ->
        help.raise_with_help("Expected the command argument, #{inspect(command)}, to be a valid module name")

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

    mix cmd.gen.command expects both a module name and
    the plural of the generated resource followed by
    any number of attributes:

        mix cmd.gen.command Account User CreateUser
    """)
  end
end
