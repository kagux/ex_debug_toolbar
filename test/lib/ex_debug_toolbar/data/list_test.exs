defmodule ExDebugToolbar.Data.ListTest do
  use ExUnit.Case, async: true
  alias ExDebugToolbar.Data.{Collection}

  test "implements collection protocol" do
    assert Collection.change([], :item) == [:item]
  end

  test "it prepands items to the list" do
    assert [:b, :a] == Collection.change([:a], :b)
  end
end
