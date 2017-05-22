defmodule ExDebugToolbar.Data.Timeline.ActionTest do
  use ExUnit.Case, async: true
  alias ExDebugToolbar.Data.{Collectable, Timeline.Action}

  describe "collectable protocol" do
    test "encode returns action itself" do
      action = %Action{action: :foo}
      assert Collectable.encode(action) == action
    end
  end
end
