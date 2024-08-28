defmodule SongappTest do
  use ExUnit.Case
  doctest Songapp

  test "greets the world" do
    assert Songapp.hello() == :world
  end
end
