defmodule Mix.Tasks.Cmd.Gen.ProcessManager do
  @shortdoc "Generates an Ecto process_manager and migration file"

  @moduledoc """
  Generates an Ecto process_manager and migration.

      $ mix cmd.gen.process_manager Blog.Post blog_posts title:string views:integer

  The first argument is the process_manager module followed by its plural
  name (used as the table name).

  The generated process_manager above will contain:

    * a process_manager file in `lib/my_app/blog/post.ex`, with a `blog_posts` table
    * a migration file for the repository

  The generated migration can be skipped with `--no-migration`.

  ## Contexts

  Your aggregates can be generated and added to a separate OTP app.
  Make sure your configuration is properly setup or manually
  specify the context app with the `--context-app` option with
  the CLI.

  Via config:

      config :marketing_web, :generators, context_app: :marketing

  Via CLI:

      $ mix cmd.gen.process_manager Blog.Post blog_posts title:string views:integer --context-app marketing

  ## Attributes

  The resource fields are given using `name:type` syntax
  where type are the types supported by Ecto. Omitting
  the type makes it default to `:string`:

      $ mix cmd.gen.process_manager Blog.Post blog_posts title views:integer

  The following types are supported:

    * `:datetime` - An alias for `:naive_datetime`

  The generator also supports references, which we will properly
  associate the given column to the primary key column of the
  referenced table:

      $ mix cmd.gen.process_manager Blog.Post blog_posts title user_id:references:users

  This will result in a migration with an `:integer` column
  of `:user_id` and create an index.

  Furthermore an array type can also be given if it is
  supported by your database, although it requires the
  type of the underlying array element to be given too:

      $ mix cmd.gen.process_manager Blog.Post blog_posts tags:array:string

  Unique columns can be automatically generated by using:

      $ mix cmd.gen.process_manager Blog.Post blog_posts title:unique unique_int:integer:unique

  Redact columns can be automatically generated by using:

      $ mix cmd.gen.process_manager Accounts.Superhero superheroes secret_identity:redact password:string:redact

  Ecto.Enum fields can be generated by using:

      $ mix cmd.gen.process_manager Blog.Post blog_posts title status:enum:unpublished:published:deleted

  If no data type is given, it defaults to a string.

  ## table

  By default, the table name for the migration and process_manager will be
  the plural name provided for the resource. To customize this value,
  a `--table` option may be provided. For example:

      $ mix cmd.gen.process_manager Blog.Post posts --table cms_posts


  """
  use Mix.Task

  alias Mix.Commanded.ProcessManager

  @switches [
    context_app: :string,
    event: :keep
  ]

  @doc false
  def run(args) do
    if Mix.Project.umbrella?() do
      Mix.raise("mix cmd.gen.process_manager must be invoked from within your *_web application root directory")
    end

    process_manager = build(args, [])
    paths = Mix.Commanded.generator_paths()

    prompt_for_conflicts(process_manager)

    process_manager
    |> copy_new_files(paths, process_manager: process_manager)
  end

  defp prompt_for_conflicts(process_manager) do
    process_manager
    |> files_to_be_generated()
    |> Mix.Commanded.prompt_for_conflicts()
  end

  @doc false
  def build(args, parent_opts, help \\ __MODULE__) do
    {aggregate_opts, parsed, _} = OptionParser.parse(args, switches: @switches)
    [aggregate_name, attrs] = validate_args!(parsed, help)

    opts =
      parent_opts
      |> Keyword.merge(aggregate_opts)
      |> put_context_app(aggregate_opts[:context_app])

    # NOTE: split it to [context_name, aggregate_name]
    aggregate_module = String.split(aggregate_name, ".")
    process_manager = ProcessManager.new(aggregate_module, attrs, opts)

    process_manager
  end

  defp put_context_app(opts, nil), do: opts

  defp put_context_app(opts, string) do
    Keyword.put(opts, :context_app, String.to_atom(string))
  end

  @doc false
  def files_to_be_generated(%ProcessManager{} = process_manager) do
    [{:eex, "process_manager.ex", process_manager.file}]
  end

  @doc false
  def copy_new_files(%ProcessManager{context_app: _ctx_app} = process_manager, paths, binding) do
    files = files_to_be_generated(process_manager)
    Mix.Commanded.copy_from(paths, "priv/templates/cmd.gen.process_manager", binding, files)
    process_manager
  end

  @doc false
  def validate_args!([process_manager | _] = args, help) do
    cond do
      not ProcessManager.valid?(process_manager) ->
        help.raise_with_help(
          "Expected the process_manager argument, #{inspect(process_manager)}, to be a valid module name"
        )

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

    mix cmd.gen.process_manager expects both a module name and
    the plural of the generated resource followed by
    any number of attributes:

        mix cmd.gen.process_manager Blog.Post blog_posts title:string
    """)
  end
end