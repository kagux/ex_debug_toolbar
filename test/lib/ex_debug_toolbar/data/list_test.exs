defmodule ExDebugToolbar.Data.ListTest do
  use ExUnit.Case, async: true
  alias ExDebugToolbar.Data.Collection

  describe "collection protocol" do
    test "add/2 prepands values to the collection" do
      assert Collection.add([:bar], :foo) == [:foo, :bar]
    end

    test "format_item/2 returns same value" do
      assert Collection.format_item([], :foo) == :foo
    end
  end
end
