defmodule ExDebugToolbar.Data.EctoLogTest do
  use ExUnit.Case, async: true
  alias ExDebugToolbar.Data.{Collectable}

  describe "collectable protocol" do
    test "change/2 returns a list" do
      assert Collectable.init_collection(%Ecto.LogEntry{}) == []
    end

    test "encode/1 encodes into map" do
      entry = %Ecto.LogEntry{
        decode_time: 5,
        query_time: 10,
        queue_time: 15,
        query: "select * from users"
      }
      assert Collectable.encode(entry) == %{
        decode_time: 5,
        query_time: 10,
        queue_time: 15,
        query: "select * from users"
      }
    end
  end
end
