defmodule ExDebugToolbar.Breakpoints.UUIDTest do
  use ExUnit.Case, async: true
  alias ExDebugToolbar.Breakpoint.UUID

  test "serializing and unserializing uuid returns the same value" do
    uuid = %UUID{request_id: "asdaf", breakpoint_id: 5}
    {:ok, unserialized} = UUID.from_string(to_string(uuid))
    assert uuid == unserialized
  end

  test "returns error when it cannot be unserialized" do
    assert {:error, _} = UUID.from_string("invalid")
  end
end
