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

    test "change/2 returns a list" do
      assert Collectable.init_collection(%Ecto.LogEntry{}) == []
    end

    test "encode/1 encodes into map", context do
      assert %{
        decode_time: 5,
        query_time: 10,
        queue_time: 15,
        query: "select * from users"
      } = Collectable.encode(context.entry)
    end

    test "encode/1 adds total time", context do
      assert %{total_time: 30} = Collectable.encode(context.entry)
    end
  end
end
