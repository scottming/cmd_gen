defmodule Mix.Commanded.Aggregate do
  alias __MODULE__

  defstruct [:module, :alias, :file, :context_app, :prefix, opts: []]

  def new(aggregate_name, opts) do
    ctx_app = opts[:context_app] || Mix.Commanded.context_app()
    otp_app = Mix.Commanded.otp_app()
    opts = Keyword.merge(Application.get_env(otp_app, :generators, []), opts)
    base = Mix.Commanded.context_base(ctx_app)
    basename = CmdGen.Naming.underscore(aggregate_name)
    module = Module.concat([base, aggregate_name])
    file = Mix.Commanded.context_lib_path(ctx_app, basename <> ".ex")

    %Aggregate{
      opts: opts,
      module: module,
      alias: module |> Module.split() |> List.last() |> Module.concat(nil),
      file: file,
      context_app: ctx_app,
      prefix: opts[:prefix]
    }
  end
end
