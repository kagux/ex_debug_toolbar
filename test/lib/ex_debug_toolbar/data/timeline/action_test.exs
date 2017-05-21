defmodule ExDebugToolbar.Data.Timeline.ActionTest do
  use ExUnit.Case, async: true
  alias ExDebugToolbar.Data.{Collectable, Timeline.Action, Timeline}

  describe "collectable protocol" do
    test "init_protocol/1 returns a timeline" do
      assert Collectable.init_collection(%Action{}) == %Timeline{}
    end

    test "encode returns action itself" do
      action = %Action{action: :foo}
      assert Collectable.encode(action) == action
    end
  end
end
