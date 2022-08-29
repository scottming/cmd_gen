defmodule CmdGenTest do
  use ExUnit.Case
  doctest CmdGen

  test "greets the world" do
    assert CmdGen.hello() == :world
  end
end
