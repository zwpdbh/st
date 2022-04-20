defmodule STTest do
  use ExUnit.Case
  doctest ST

  test "greets the world" do
    assert ST.hello() == :world
  end
end
