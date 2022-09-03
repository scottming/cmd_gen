Code.require_file "../../support/mix_helper.exs", __DIR__

defmodule Mix.Tasks.Phx.Gen.ContextTest do
  # import MixHelper
  use ExUnit.Case
  alias Mix.Commanded.Aggregate
  alias Mix.Commanded.NewContext, as: Context

  setup do
    Mix.Task.clear()
    :ok
  end

  test "new context" do
    aggregate = Aggregate.new(["Blog", "Post"], [], [])
    context = Context.new("Blog", aggregate, [])

    assert %Context{
             alias: Blog,
             base_module: CmdGen,
             basename: "blog",
             module: CmdGen.Blog,
             aggregate: %Mix.Commanded.Aggregate{
               alias: Post,
               human_singular: "Post",
               module: CmdGen.Blog.Aggregates.Post,
               singular: "post"
             }
           } = context

    assert String.ends_with?(context.dir, "lib/cmd_gen/blog")
    assert String.ends_with?(context.file, "lib/cmd_gen/blog.ex")
    assert String.ends_with?(context.test_file, "test/cmd_gen/blog_test.exs")
    assert String.ends_with?(context.aggregate.file, "lib/cmd_gen/blog/aggregates/post.ex")
  end

  test "new nested context" do
    aggregate = Aggregate.new(["Site.Blog", "Post"], [], [])
    context = Context.new("Site.Blog", aggregate, [])

    assert %Context{
             alias: Blog,
             base_module: CmdGen,
             basename: "blog",
             module: CmdGen.Site.Blog,
             aggregate: %Mix.Commanded.Aggregate{
               alias: Post,
               human_singular: "Post",
               module: CmdGen.Site.Blog.Aggregates.Post,
               singular: "post"
             }
           } = context

    assert String.ends_with?(context.dir, "lib/cmd_gen/site/blog")
    assert String.ends_with?(context.file, "lib/cmd_gen/site/blog.ex")
    assert String.ends_with?(context.test_file, "test/cmd_gen/site/blog_test.exs")
    assert String.ends_with?(context.aggregate.file, "lib/cmd_gen/site/blog/aggregates/post.ex")
  end
end
