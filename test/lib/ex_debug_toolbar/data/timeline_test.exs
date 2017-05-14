defmodule ExDebugToolbar.Data.TimelineTest do
  use ExUnit.Case, async: true
  alias ExDebugToolbar.Data.{Event, Timeline}

  describe "upsert_event/2" do
    test "it adds new event to timeline when last event has different name and is finished" do
      timeline = %Timeline{events: [%Event{name: "event", duration: 50}]}
      |> Timeline.upsert_event(%Event{name: "test"})
      assert timeline.events |> length == 2
      event = timeline.events |> List.first
      assert %Event{name: "test", started_at: %DateTime{}} = event
    end

    test "it adds new event to empty timeline" do
      timeline = %Timeline{} |> Timeline.upsert_event(%Event{name: "test"})
      assert timeline.events |> length == 1
    end

    test "it sets duration for last event with same name that has been started" do
      event = %Event{name: "event", started_at: DateTime.utc_now()}
      timeline = %Timeline{events: [event]} |> Timeline.upsert_event(%Event{name: "event"})
      assert timeline.events |> length == 1
      event = timeline.events |> List.first
      assert event.duration > 0
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
