defmodule ExDebugToolbar.Data.EventTest do
  use ExUnit.Case, async: true
  alias ExDebugToolbar.Data.{Collectable, Event, Timeline}

  test "implements collecable protocol" do
    event = %Event{name: "test"}
    assert Collectable.init_container(event) == %Timeline{}
    assert %Timeline{events: [%Event{name: "test"}]} = Collectable.put(event, %Timeline{})
  end
end

