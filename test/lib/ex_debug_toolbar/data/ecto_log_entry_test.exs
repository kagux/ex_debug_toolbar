defmodule ExDebugToolbar.Data.EctoLogTest do
  use ExUnit.Case, async: true
  alias ExDebugToolbar.Data.{Collectable}

  describe "collectable protocol" do
    setup do
      entry = %Ecto.LogEntry{
        decode_time: 5,
        query_time: 10,
        queue_time: 15,
        query: "select * from users"
      }
      {:ok, entry: entry}
    end

    test "format/1 formats into map", context do
      assert %{
        decode_time: 5,
        query_time: 10,
        queue_time: 15,
        query: "select * from users"
      } = Collectable.format(context.entry)
    end

    test "format/1 adds total time", context do
      assert %{total_time: 30} = Collectable.format(context.entry)
    end
  end
end
