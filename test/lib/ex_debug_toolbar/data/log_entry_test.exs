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

    test "init_collection/1 returns a list" do
      assert Collectable.init_collection(%LogEntry{}) == []
    end

    test "encode/1 encodes into map", context do
      assert %{level: "debug"} = Collectable.encode(context.entry)
    end

    test "encode/1 encodes message into string", context do
      entry = %{context.entry | message: ["he", "y"]}
      assert %{message: "hey"} = Collectable.encode(entry)
    end

    test "encode/1 encodes timestamp into string", context do
      assert %{timestamp: "2015-04-29 02:44:00"} = Collectable.encode(context.entry)
    end
  end
end
