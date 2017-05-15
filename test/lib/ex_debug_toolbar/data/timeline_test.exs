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
      |> Timeline.start_event("A")
      |> Timeline.start_event("B")
      |> Timeline.finish_event("B")
      |> Timeline.start_event("B")
      |> Timeline.finish_event("B")
      |> Timeline.finish_event("A")
      |> Timeline.start_event("C")
      |> Timeline.start_event("D")
      |> Timeline.finish_event("D")
      |> Timeline.start_event("E")
      |> Timeline.finish_event("E")
      |> Timeline.finish_event("C")

    [first_event, second_event] = timeline.events
    assert first_event.name == "C"
    assert first_event.events |> Enum.at(0) |> Map.fetch!(:name) == "E"
    assert first_event.events |> Enum.at(1) |> Map.fetch!(:name) == "D"

    assert second_event.name == "A"
    assert second_event.events |> Enum.at(0) |> Map.fetch!(:name) == "B"
    assert second_event.events |> Enum.at(1) |> Map.fetch!(:name) == "B"
  end

  test "raises an error when closing an event that is not open" do
    assert_raise RuntimeError, fn ->
      %Timeline{}
      |> Timeline.start_event("outsider")
      |> Timeline.finish_event("nested")
    end
    assert_raise RuntimeError, fn ->
      %Timeline{}
      |> Timeline.start_event("outsider")
      |> Timeline.start_event("another")
      |> Timeline.finish_event("nested")
    end
  end

  describe "duration/1" do
    test "retuns total duration of all events" do
      timeline =
        %Timeline{}
        |> Timeline.start_event("outsider")
        |> Timeline.finish_event("outsider")
        |> Timeline.start_event("nested")
        |> Timeline.finish_event("nested")
      assert Timeline.duration(timeline) == Enum.reduce(timeline.events, 0, fn(e, acc) -> acc + e.duration end)
    end

    test "it ignores unfinished events" do
      timeline =
        %Timeline{}
        |> Timeline.start_event("outsider")
      assert timeline |> Timeline.duration == 0
    end
  end
end
