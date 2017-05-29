defmodule ExDebugToolbar.Data.LogsTest do
  use ExUnit.Case, async: true
  alias ExDebugToolbar.Data.{Collection, Logs}

  describe "collection protocol" do
    setup do
      entry = %Logs.Entry{
        level: "debug",
        message: "hey",
        timestamp: {{2015, 4, 29}, {2, 44, 0, 0}}
      }
      {:ok, entry: entry}
    end

    test "format_item/2 formats log entry into map", context do
      assert %{level: "debug"} = Collection.format_item(%Logs{}, context.entry)
    end

    test "format_item/2 formats log entry message into string", context do
      entry = %{context.entry | message: ["he", "y"]}
      assert %{message: "hey"} = Collection.format_item(%Logs{}, entry)
    end

    test "format_item/2 formats log entry timestamp into string", context do
      assert %{timestamp: "2015-04-29 02:44:00"} = Collection.format_item(%Logs{}, context.entry)
    end

    test "add/2 adds log entry to a list of logs" do
      collection = %Logs{entries: [:entry]} |> Collection.add(%{level: "debug"})
      assert collection.entries |> hd == %{level: "debug"}
    end
  end
end

