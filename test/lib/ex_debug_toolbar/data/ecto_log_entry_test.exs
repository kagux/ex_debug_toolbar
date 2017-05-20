defmodule ExDebugToolbar.Data.EctoLogTest do
  use ExUnit.Case, async: true
  alias ExDebugToolbar.Data.{Collectable}

  test "implements collectable protocol" do
    assert Collectable.init_collection(%Ecto.LogEntry{}) == []
  end
end

