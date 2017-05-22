defmodule ExDebugToolbar.Data.LogEntryTest do
  use ExUnit.Case, async: true
  alias ExDebugToolbar.Data.{Collectable, LogEntry}

  describe "collectable protocol" do
    setup do
      entry = %LogEntry{
        level: "debug",
        message: "hey",
        timestamp: {{2015, 4, 29}, {2, 44, 0, 0}}
      }
      {:ok, entry: entry}
    end

    test "format/1 formats into map", context do
      assert %{level: "debug"} = Collectable.format(context.entry)
    end

    test "format/1 formats message into string", context do
      entry = %{context.entry | message: ["he", "y"]}
      assert %{message: "hey"} = Collectable.format(entry)
    end

    test "format/1 formats timestamp into string", context do
      assert %{timestamp: "2015-04-29 02:44:00"} = Collectable.format(context.entry)
    end
  end
end
