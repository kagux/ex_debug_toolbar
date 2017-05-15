defmodule ExDebugToolbar.Data.LogEntryTest do
  use ExUnit.Case, async: true
  alias ExDebugToolbar.Data.{Collectable, LogEntry}

  test "implements collecable protocol" do
    assert Collectable.init_collection(%LogEntry{}) == []
  end
end
