defmodule ExDebugToolbar.Data.ListTest do
  use ExUnit.Case, async: true
  alias ExDebugToolbar.Data.{Collection}

  test "implements collection protocol" do
    assert Collection.change([], :item) == [:item]
  end

  test "it appends items to the list" do
    assert [:a, :b] == Collection.change([:a], :b)
  end
end
