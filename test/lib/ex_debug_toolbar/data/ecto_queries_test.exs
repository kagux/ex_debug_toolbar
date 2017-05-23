defmodule ExDebugToolbar.Data.EctoQueriesTest do
  use ExUnit.Case, async: true
  alias ExDebugToolbar.Data.{Collection, EctoQueries}

  describe "collection protocol" do
    setup do
      entry = %Ecto.LogEntry{
        decode_time: 5,
        query_time: 10,
        queue_time: 15,
        query: "select * from users"
      }
      {:ok, entry: entry}
    end

    test "format_item/2 formats logs entry into map", context do
      assert %{
        decode_time: 5,
        query_time: 10,
        queue_time: 15,
        query: "select * from users"
      } = Collection.format_item(%EctoQueries{}, context.entry)
    end

    test "format_item/2 adds total time to map", context do
      assert %{total_time: 30} = Collection.format_item(%EctoQueries{}, context.entry)
    end

    test "add/2 adds log entry to logs list" do
      collection = %EctoQueries{queries: [:foo]} |> Collection.add(%{query: "select"})
      assert collection.queries |> hd == %{query: "select"}
    end
  end
end
