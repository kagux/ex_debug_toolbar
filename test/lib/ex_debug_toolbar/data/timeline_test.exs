defmodule ExDebugToolbar.Data.TimelineTest do
  use ExUnit.Case, async: true
  alias ExDebugToolbar.Data.Timeline
  alias ExDebugToolbar.Data.Timeline.Event

  test "adds new event and records started_at time" do
    timeline =
      %Timeline{}
      |> Timeline.start_event("name")
      |> Timeline.finish_event("name")

    assert timeline.events |> length == 1
    event = timeline.events |> List.first

    assert %Event{name: "name", started_at: %DateTime{}} = event
    assert event.duration > 0
  end

  test "accepts nested events" do
    timeline =
      %Timeline{}
      |> Timeline.start_event("outsider")
      |> Timeline.start_event("nested")
      |> Timeline.finish_event("nested")
      |> Timeline.finish_event("outsider")

    assert timeline.events |> length == 1
    outsider_event = timeline.events |> List.first
    assert %Event{name: "outsider"} = outsider_event

    assert outsider_event.events |> length == 1
    nested_event = outsider_event.events |> List.first
    assert %Event{name: "nested"} = nested_event
  end

  test "raises unless name matches" do
    # todo
  end

  test "raises if timeline has no events" do
  end

  describe "duration/1" do
    test "retuns total duration of all events" do
      timeline = %Timeline{events: [%Event{duration: 5}, %Event{duration: 1}]}
      assert timeline |> Timeline.duration == 6
    end

    test "it ignores unfinished events" do
      timeline = %Timeline{events: [%Event{duration: 5}, %Event{}]}
      assert timeline |> Timeline.duration == 5
    end
  end
end
