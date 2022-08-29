defmodule Mix.Tasks.Cmd do
  use Mix.Task

  @shortdoc "Prints Commanded help information"

  @moduledoc """
  Prints Commanded tasks and their information.

      $ mix cmd

  To print the Commanded version, pass `-v` or `--version`, for example:

      $ mix cmd --version

  """

  @version Mix.Project.config()[:version]

  @impl true
  @doc false
  def run([version]) when version in ~w(-v --version) do
    Mix.shell().info("Commanded v#{@version}")
  end

  def run(args) do
    case args do
      [] -> general()
      _ -> Mix.raise "Invalid arguments, expected: mix cmd"
    end
  end

  defp general() do
    Application.ensure_all_started(:commanded)
    Mix.shell().info "Commanded v#{Application.spec(:commanded, :vsn)}"
    Mix.shell().info "Peace of mind from prototype to production"
    Mix.shell().info "\n## Options\n"
    Mix.shell().info "-v, --version        # Prints Commanded version\n"
    Mix.Tasks.Help.run(["--search", "cmd."])
  end
end
