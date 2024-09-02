defmodule SongappTest do
  use ExUnit.Case
  doctest Songapp

  test "greets the world" do
    assert Songapp.hello() == :world
  end

  test "Search Song" do
    assert Songapp.search_song() == :world
  end
end
