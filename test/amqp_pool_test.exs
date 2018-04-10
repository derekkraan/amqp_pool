defmodule AMQPPoolTest do
  use ExUnit.Case
  doctest AMQPPool

  test "greets the world" do
    assert AMQPPool.hello() == :world
  end
end
