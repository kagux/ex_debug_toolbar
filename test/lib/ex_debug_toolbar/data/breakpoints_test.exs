defmodule ExDebugToolbar.Data.BreakpointsTest do
  use ExUnit.Case, async: true
  alias ExDebugToolbar.Data.{Breakpoints, Collection}
  alias ExDebugToolbar.Breakpoint

  describe "collection protocol" do
    test "adding breakpoints" do
      collection = %Breakpoints{}
        |> Collection.add(%Breakpoint{})

      assert collection.count == 1
      assert length(collection.collection) == 1
    end

    test "it ignores breakpoints above the threshold" do
      collection = Enum.reduce(
        1..20,
        %Breakpoints{},
        fn(_, acc) -> Collection.add(acc, %Breakpoint{}) end
      )

      assert collection.count == 3
      assert length(collection.collection) == 3
    end
  end
end
