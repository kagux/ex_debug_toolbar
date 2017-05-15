defmodule ExDebugToolbar.Data.TimelineTest do
  use ExUnit.Case, async: true
  alias ExDebugToolbar.Data.Timeline
  alias ExDebugToolbar.Data.Timeline.Event

  describe "start_event/2" do
    test "adds new event and records started_at time" do
      timeline = %Timeline{} |> Timeline.start_event("name")
      assert timeline.events |> length == 1
      event = timeline.events |> List.first
      assert %Event{name: "name", started_at: %DateTime{}} = event 
    end
  end

  describe "finish_event/2" do
    test "finishes current event" do
      existing_event = %Event{name: "event", started_at: DateTime.utc_now()}
      timeline = %Timeline{events: [existing_event]} |> Timeline.finish_event("event")
      assert timeline.events |> length == 1
      event = timeline.events |> List.first
      assert event.duration > 0
    end

    test "raises unless name matches" do
      # todo
    end

    test "raises if timeline has no events" do
    end
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
