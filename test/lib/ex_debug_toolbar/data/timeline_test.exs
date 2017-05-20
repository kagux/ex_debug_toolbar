defmodule ExDebugToolbar.Data.TimelineTest do
  use ExUnit.Case, async: true
  alias ExDebugToolbar.Data.Timeline.{Event, Action}
  alias ExDebugToolbar.Data.{Timeline, Collection}

  describe "events management" do
    test "tracks events and computes duration" do
      timeline =
        %Timeline{}
        |> Timeline.start_event("name")
        |> Timeline.finish_event("name")

      assert timeline.events |> length == 1
      event = timeline.events |> List.first

      assert %Event{} = event
      assert event.name == "name"
      assert is_integer(event.started_at)
      assert event.duration > 0
    end

    test "accepts nested events" do
      timeline =
        %Timeline{}
        |> Timeline.start_event("A")
        |> Timeline.start_event("A-B")
        |> Timeline.finish_event("A-B")
        |> Timeline.start_event("A-B")
        |> Timeline.finish_event("A-B")
        |> Timeline.finish_event("A")
        |> Timeline.start_event("C")
        |> Timeline.start_event("C-D")
        |> Timeline.finish_event("C-D")
        |> Timeline.start_event("C-E")
        |> Timeline.finish_event("C-E")
        |> Timeline.finish_event("C")

      [first_event, second_event] = timeline.events
      assert first_event.name == "C"
      assert first_event.events |> Enum.at(0) |> Map.fetch!(:name) == "C-E"
      assert first_event.events |> Enum.at(1) |> Map.fetch!(:name) == "C-D"

      assert second_event.name == "A"
      assert second_event.events |> Enum.at(0) |> Map.fetch!(:name) == "A-B"
      assert second_event.events |> Enum.at(1) |> Map.fetch!(:name) == "A-B"
    end

    test "raises an error when closing an event that is not open" do
      assert_raise RuntimeError, fn ->
        %Timeline{}
        |> Timeline.start_event("A")
        |> Timeline.finish_event("B")
      end
      assert_raise RuntimeError, fn ->
        %Timeline{}
        |> Timeline.start_event("A")
        |> Timeline.start_event("B")
        |> Timeline.finish_event("C")
      end
    end

    test "raises an error when closing an event that is not the last one opened" do
      assert_raise RuntimeError, fn ->
        %Timeline{}
        |> Timeline.start_event("A")
        |> Timeline.start_event("C")
        |> Timeline.finish_event("A")
      end
    end

    test "optionally accepts precalculated event duration" do
      timeline = %Timeline{}
      |> Timeline.start_event("A")
      |> Timeline.finish_event("A", duration: 1000)
      assert timeline.duration == 1000
    end

    test "adds an event that already happened" do
      timeline = %Timeline{} |> Timeline.add_event("A", 5000)
      assert timeline.events |> length == 1
      assert %Event{name: "A"} = timeline.events |> hd
      assert timeline.duration == 5000
    end
  end

  describe "collection protocol" do
    test "passing :start_event action change/2 starts new event" do
      timeline = %Timeline{}
      |> Collection.change(%Action{action: :start_event, event_name: "event"})
      |> Timeline.finish_event("event")

      assert timeline.events |> length == 1
      assert %Event{name: "event"} = timeline.events |> hd
    end

    test "passing :finish_event action change/2 finishes event" do
      timeline = %Timeline{}
      |> Timeline.start_event("event")
      |> Collection.change(%Action{action: :finish_event, event_name: "event", duration: 5})

      assert timeline.events |> length == 1
      assert %Event{name: "event", duration: 5} = timeline.events |> hd
    end

    test "passing :add_event action change/2 adds event" do
      timeline = %Timeline{}
      |> Collection.change(%Action{action: :add_event, event_name: "event", duration: 5})

      assert timeline.events |> length == 1
      assert %Event{name: "event", duration: 5} = timeline.events |> hd
    end
  end
end
