defmodule ExDebugToolbar.Data.Timeline.ActionTest do
  use ExUnit.Case, async: true
  alias ExDebugToolbar.Data.{Collectable, Timeline.Action, Timeline}

  test "implements collectable protocol" do
    assert Collectable.init_collection(%Action{}) == %Timeline{}
  end
end
