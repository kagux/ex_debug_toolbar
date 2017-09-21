defmodule ExDebugToolbar.Data.BreakpointsTest do
  use ExUnit.Case, async: true
  alias ExDebugToolbar.Data.{BreakpointCollection, Collection}
  alias ExDebugToolbar.Breakpoint

  describe "collection protocol" do
    test "adding breakpoints" do
      collection = %BreakpointCollection{}
        |> Collection.add(%Breakpoint{})

      assert collection.count == 1
      assert collection.entries |> Map.keys |> length == 1
    end

    test "it ignores breakpoints above the threshold" do
      collection = Enum.reduce(
        1..4,
        %BreakpointCollection{},
        fn(id, acc) -> Collection.add(acc, %Breakpoint{id: id}) end
      )

      assert collection.count == 3
      assert collection.entries |> Map.keys |> length == 3
    end
  end
end
